<?php
// ==========================================
// Database Initialization Script
// Run this once to create all tables
// ==========================================

require_once 'db-config.php';

echo "Initializing LawyerCRM database...\n\n";

// Read schema.sql
$schema = file_get_contents(__DIR__ . '/sql-schemas/schema.sql');

if (!$schema) {
    die("Error: Could not read schema.sql file\n");
}

// Connect to database
$conn = getDbConnection();

// Execute schema
echo "Creating tables...\n";
$result = pg_query($conn, $schema);

if (!$result) {
    $error = pg_last_error($conn);
    die("Error creating tables: $error\n");
}

echo "✅ Tables created successfully!\n\n";

// Now seed categories
echo "Seeding initial categories...\n";
$seed = file_get_contents(__DIR__ . '/sql-schemas/seed-categories.sql');

if (!$seed) {
    echo "⚠️  Warning: Could not read seed-categories.sql file\n";
} else {
    $result = pg_query($conn, $seed);

    if (!$result) {
        $error = pg_last_error($conn);
        echo "⚠️  Warning: Could not seed categories: $error\n";
    } else {
        echo "✅ Categories seeded successfully!\n";
    }
}

pg_close($conn);

echo "\n✨ Database initialization complete!\n";
echo "You can now use the LawyerCRM application.\n";
?>
