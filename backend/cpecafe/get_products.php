<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'config/dbcon.php';

// Check if connection exists
if (!$conn) {
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed'
    ]);
    exit;
}

try {
    // Modify the query to dynamically generate the image path
    $query = "SELECT id, name, category, large_price, small_price, stock,
              CONCAT('images/', REPLACE(LOWER(name), ' ', '_'), '_', REPLACE(LOWER(category), ' ', '_'), '.png') AS image
              FROM products ORDER BY category, name";
    
    $result = $conn->query($query);
    
    if ($result) {
        $products = [];
        while ($row = $result->fetch_assoc()) {
            $products[] = $row;
        }
        
        echo json_encode([
            'success' => true,
            'products' => $products
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Query failed: ' . $conn->error
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}

if ($conn) {
    $conn->close();
}
?>