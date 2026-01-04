<?php
// ==========================================
// Dashboard General Statistics API
// ==========================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require_once '../../db-config.php';

// Get user ID from query parameter
$userId = $_GET['user_id'] ?? null;

if (!$userId) {
    echo json_encode(['success' => false, 'error' => 'User ID is required']);
    exit;
}

try {
    $conn = getDbConnection();

    // Total clients
    $clientsQuery = "SELECT COUNT(*) as total FROM clients WHERE user_id = $1";
    $clientsResult = pg_query_params($conn, $clientsQuery, [$userId]);
    $totalClients = pg_fetch_assoc($clientsResult)['total'];

    // Active cases
    $casesQuery = "SELECT COUNT(*) as total FROM cases WHERE user_id = $1 AND status IN ('active', 'in_progress')";
    $casesResult = pg_query_params($conn, $casesQuery, [$userId]);
    $activeCases = pg_fetch_assoc($casesResult)['total'];

    // Monthly revenue (current month)
    $revenueQuery = "SELECT COALESCE(SUM(amount_ils), 0) as total
                     FROM payments
                     WHERE user_id = $1
                     AND payment_date >= date_trunc('month', CURRENT_DATE)
                     AND payment_date < date_trunc('month', CURRENT_DATE) + interval '1 month'";
    $revenueResult = pg_query_params($conn, $revenueQuery, [$userId]);
    $monthlyRevenue = pg_fetch_assoc($revenueResult)['total'];

    // Upcoming events (next 7 days)
    $eventsQuery = "SELECT COUNT(*) as total
                    FROM events
                    WHERE user_id = $1
                    AND event_date >= CURRENT_DATE
                    AND event_date <= CURRENT_DATE + interval '7 days'";
    $eventsResult = pg_query_params($conn, $eventsQuery, [$userId]);
    $upcomingEvents = pg_fetch_assoc($eventsResult)['total'];

    pg_close($conn);

    echo json_encode([
        'success' => true,
        'stats' => [
            'total_clients' => (int)$totalClients,
            'active_cases' => (int)$activeCases,
            'monthly_revenue' => (float)$monthlyRevenue,
            'upcoming_events' => (int)$upcomingEvents
        ]
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
