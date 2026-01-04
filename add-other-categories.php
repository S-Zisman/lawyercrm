<?php
// ==========================================
// Add "OTHER" categories to database
// ==========================================

require_once 'db-config.php';

echo "Adding 'OTHER' categories...\n\n";

$categories = [
    ['OTHER', 'Консультация', 'ייעוץ', '💬', '#6B7280'],
    ['OTHER', 'Юридическое мнение', 'חוות דעת משפטית', '📋', '#6B7280'],
    ['OTHER', 'Нотариальные услуги', 'שירותי נוטריון', '✍️', '#6B7280'],
    ['OTHER', 'Апостиль', 'אפוסטיל', '🌐', '#6B7280'],
    ['OTHER', 'Перевод документов', 'תרגום מסמכים', '📄', '#6B7280'],
    ['OTHER', 'Административные обращения', 'פניות מנהליות', '📮', '#6B7280'],
    ['OTHER', 'Сопровождение в госорганы', 'ליווי למוסדות ממשלתיים', '🏛️', '#6B7280'],
    ['OTHER', 'Нестандартный случай', 'מקרה לא סטנדרטי', '❓', '#6B7280']
];

$conn = getDbConnection();

foreach ($categories as $cat) {
    $query = "INSERT INTO case_subcategories (dimension, name_ru, name_he, icon, color)
              VALUES ($1, $2, $3, $4, $5)";

    $result = pg_query_params($conn, $query, $cat);

    if ($result) {
        echo "✅ Added: {$cat[1]} / {$cat[2]}\n";
    } else {
        echo "❌ Error adding {$cat[1]}: " . pg_last_error($conn) . "\n";
    }
}

pg_close($conn);

echo "\n✅ Categories added successfully!\n";
?>
