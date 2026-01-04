<?php
// ==========================================
// Dashboard Upcoming Deadlines API
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

    $query = "SELECT
                d.title,
                d.deadline_date,
                d.priority,
                c.dimension
              FROM deadlines d
              LEFT JOIN cases c ON d.case_id = c.id
              WHERE d.user_id = $1
              AND d.is_completed = false
              AND d.deadline_date >= CURRENT_DATE
              ORDER BY d.deadline_date ASC
              LIMIT $2";

    $result = pg_query_params($conn, $query, [$userId, $limit]);

    $deadlines = [];
    while ($row = pg_fetch_assoc($result)) {
        $deadlines[] = $row;
    }

    pg_close($conn);

    echo json_encode([
        'success' => true,
        'deadlines' => $deadlines
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
