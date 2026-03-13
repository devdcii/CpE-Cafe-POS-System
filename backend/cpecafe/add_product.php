<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once 'config/dbcon.php';

$input = json_decode(file_get_contents('php://input'), true);

if (!$input || !isset($input['name']) || !isset($input['category']) || 
    !isset($input['large_price']) || !isset($input['small_price']) || !isset($input['stock'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing required fields'
    ]);
    exit;
}

try {
    $name = $input['name'];
    $category = $input['category'];
    $large_price = $input['large_price'];
    $small_price = $input['small_price'];
    $stock = $input['stock'];
    $image = $input['image'] ?? 'assets/images/bgcafe.jfif';
    
    $query = "INSERT INTO products (name, category, large_price, small_price, stock, image) 
              VALUES (?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('ssddis', $name, $category, $large_price, $small_price, $stock, $image);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Product added successfully',
            'product_id' => $conn->insert_id
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Failed to add product'
        ]);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}

$conn->close();
?>