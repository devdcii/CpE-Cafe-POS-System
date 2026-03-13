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

if (!$input || !isset($input['product_id']) || !isset($input['stock'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid input data'
    ]);
    exit;
}

try {
    $product_id = $input['product_id'];
    $stock = $input['stock'];
    
    // Validate that stock is not negative
    if ($stock < 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Stock quantity cannot be negative. Please enter a value of 0 or greater.'
        ]);
        exit;
    }
    
    $query = "UPDATE products SET stock = ? WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('ii', $stock, $product_id);
    
    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode([
                'success' => true,
                'message' => 'Stock updated successfully'
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Product not found or no changes made'
            ]);
        }
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Failed to update stock'
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