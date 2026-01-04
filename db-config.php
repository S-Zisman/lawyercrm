<?php
// ==========================================
// Database Configuration for LawyerCRM
// DigitalOcean Managed PostgreSQL
// ==========================================

// Load environment variables (create db-config.local.php with actual credentials)
if (file_exists(__DIR__ . '/db-config.local.php')) {
    require_once __DIR__ . '/db-config.local.php';
} else {
    // Default values for reference (override in db-config.local.php)
    $db_config = [
        'host' => 'your-database-host.ondigitalocean.com',
        'port' => '25061',
        'database' => 'lawyercrm',
        'username' => 'your-username',
        'password' => 'your-password',
        'sslmode' => 'require'
    ];
}

// Connection string
$conn_string = sprintf(
    "host=%s port=%s dbname=%s user=%s password=%s sslmode=%s",
    $db_config['host'],
    $db_config['port'],
    $db_config['database'],
    $db_config['username'],
    $db_config['password'],
    $db_config['sslmode']
);

// Create connection
function getDbConnection() {
    global $conn_string;

    $conn = pg_connect($conn_string);

    if (!$conn) {
        die(json_encode([
            'success' => false,
            'error' => 'Database connection failed'
        ]));
    }

    return $conn;
}

// Helper function to execute query
function executeQuery($query, $params = []) {
    $conn = getDbConnection();

    if (empty($params)) {
        $result = pg_query($conn, $query);
    } else {
        $result = pg_query_params($conn, $query, $params);
    }

    if (!$result) {
        $error = pg_last_error($conn);
        pg_close($conn);
        return ['success' => false, 'error' => $error];
    }

    $data = pg_fetch_all($result);
    pg_close($conn);

    return ['success' => true, 'data' => $data ? $data : []];
}

// Helper function to execute insert/update/delete
function executeNonQuery($query, $params = []) {
    $conn = getDbConnection();

    if (empty($params)) {
        $result = pg_query($conn, $query);
    } else {
        $result = pg_query_params($conn, $query, $params);
    }

    if (!$result) {
        $error = pg_last_error($conn);
        pg_close($conn);
        return ['success' => false, 'error' => $error];
    }

    $affected = pg_affected_rows($result);
    pg_close($conn);

    return ['success' => true, 'affected_rows' => $affected];
}
?>
