<?php
// ==========================================
// Dashboard Dimension Statistics API
// ==========================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once '../../db-config.php';

$userId = $_GET['user_id'] ?? null;

if (!$userId) {
    echo json_encode(['success' => false, 'error' => 'User ID is required']);
    exit;
}

try {
    $conn = getDbConnection();

    // Get cases count by dimension
    $dimensionsQuery = "SELECT
                          dimension,
                          COUNT(*) as cases_count
                        FROM cases
                        WHERE user_id = $1
                        GROUP BY dimension";

    $result = pg_query_params($conn, $dimensionsQuery, [$userId]);

    $dimensions = [];
    while ($row = pg_fetch_assoc($result)) {
        $dimensions[$row['dimension']] = [
            'cases_count' => (int)$row['cases_count']
        ];
    }

    // Count active protection orders (1D)
    $ordersQuery = "SELECT COUNT(*) as total
                    FROM protection_orders po
                    JOIN cases c ON po.case_id = c.id
                    WHERE c.user_id = $1
                    AND (po.expiry_date IS NULL OR po.expiry_date >= CURRENT_DATE)";
    $ordersResult = pg_query_params($conn, $ordersQuery, [$userId]);
    $protectionOrders = pg_fetch_assoc($ordersResult)['total'];

    // Count mediation sessions (5D)
    $sessionsQuery = "SELECT COUNT(*) as total
                      FROM mediation_sessions ms
                      JOIN cases c ON ms.case_id = c.id
                      WHERE c.user_id = $1";
    $sessionsResult = pg_query_params($conn, $sessionsQuery, [$userId]);
    $mediationSessions = pg_fetch_assoc($sessionsResult)['total'];

    pg_close($conn);

    echo json_encode([
        'success' => true,
        'dimensions' => $dimensions,
        'protection_orders' => (int)$protectionOrders,
        'mediation_sessions' => (int)$mediationSessions
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
