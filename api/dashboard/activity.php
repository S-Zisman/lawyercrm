<?php
// ==========================================
// Dashboard Recent Activity API
// ==========================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once '../../db-config.php';

$userId = $_GET['user_id'] ?? null;
$limit = $_GET['limit'] ?? 10;

if (!$userId) {
    echo json_encode(['success' => false, 'error' => 'User ID is required']);
    exit;
}

try {
    $conn = getDbConnection();

    // For now, return empty activities (will be populated as users work with the system)
    // In production, this would query an activity_log table

    $activities = [];

    // Example: Get recent cases created
    $casesQuery = "SELECT
                     'case_created' as type,
                     'Создано дело: ' || title as title,
                     created_at
                   FROM cases
                   WHERE user_id = $1
                   ORDER BY created_at DESC
                   LIMIT $2";

    $result = pg_query_params($conn, $casesQuery, [$userId, $limit]);

    while ($row = pg_fetch_assoc($result)) {
        $activities[] = $row;
    }

    pg_close($conn);

    echo json_encode([
        'success' => true,
        'activities' => $activities
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
