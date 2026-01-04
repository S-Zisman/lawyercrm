<?php
require_once 'db-config.php';

$conn = getDbConnection();

$query = "SELECT dimension, COUNT(*) as count FROM case_subcategories GROUP BY dimension ORDER BY dimension";
$result = pg_query($conn, $query);

echo "Categories by dimension:\n";
while ($row = pg_fetch_assoc($result)) {
    echo "{$row['dimension']}: {$row['count']} categories\n";
}

echo "\nOTHER categories:\n";
$otherQuery = "SELECT name_ru, name_he FROM case_subcategories WHERE dimension = 'OTHER'";
$otherResult = pg_query($conn, $otherQuery);

while ($row = pg_fetch_assoc($otherResult)) {
    echo "- {$row['name_ru']} / {$row['name_he']}\n";
}

pg_close($conn);
?>
