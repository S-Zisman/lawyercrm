<?php
// ==========================================
// Login API Endpoint
// ==========================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../../db-config.php';

// Only allow POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Method not allowed']);
    exit;
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['email']) || !isset($input['password'])) {
    echo json_encode(['success' => false, 'error' => 'Email and password are required']);
    exit;
}

$email = trim($input['email']);
$password = $input['password'];

// Find user by email
$query = "SELECT id, email, password_hash, name, role, is_active FROM users WHERE email = $1";
$result = executeQuery($query, [$email]);

if (!$result['success']) {
    echo json_encode(['success' => false, 'error' => 'Database error']);
    exit;
}

if (empty($result['data'])) {
    echo json_encode(['success' => false, 'error' => 'Invalid email or password']);
    exit;
}

$user = $result['data'][0];

// Check if user is active
if (!$user['is_active']) {
    echo json_encode(['success' => false, 'error' => 'Account is disabled']);
    exit;
}

// Verify password
if (!password_verify($password, $user['password_hash'])) {
    echo json_encode(['success' => false, 'error' => 'Invalid email or password']);
    exit;
}

// Return user data (without password)
unset($user['password_hash']);

echo json_encode([
    'success' => true,
    'user' => $user,
    'message' => 'Login successful'
]);
?>
