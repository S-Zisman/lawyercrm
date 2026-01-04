<?php
// ==========================================
// Create First User Script
// Run this once to create Polina's account
// ==========================================

require_once 'db-config.php';

// User details - CHANGE THESE VALUES BEFORE RUNNING
$email = 'your-email@example.com';
$password = 'your-secure-password';
$name = 'Ваше имя';
$role = 'lawyer';

echo "Creating user account...\n";
echo "Email: $email\n";
echo "Name: $name\n\n";

// Hash password
$passwordHash = password_hash($password, PASSWORD_BCRYPT);

// Insert user
$query = "INSERT INTO users (email, password_hash, name, role, is_active)
          VALUES ($1, $2, $3, $4, $5)
          RETURNING id, email, name";

$result = executeQuery($query, [$email, $passwordHash, $name, $role, true]);

if (!$result['success']) {
    die("Error creating user: " . $result['error'] . "\n");
}

echo "✅ User created successfully!\n\n";
echo "Login credentials:\n";
echo "Email: $email\n";
echo "Password: $password\n\n";
echo "⚠️  Please change the password after first login!\n";
?>
