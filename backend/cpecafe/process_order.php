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

if (!$input || !isset($input['items']) || !isset($input['total'])) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid input data'
    ]);
    exit;
}

try {
    $conn->begin_transaction();
    
    // Create order
    $total = $input['total'];
    $order_query = "INSERT INTO orders (total, created_at) VALUES (?, NOW())";
    $order_stmt = $conn->prepare($order_query);
    $order_stmt->bind_param('d', $total);
    
    if (!$order_stmt->execute()) {
        throw new Exception('Failed to create order');
    }
    
    $order_id = $conn->insert_id;
    
    // Process each item
    foreach ($input['items'] as $item) {
        $product_id = $item['product_id'];
        $quantity = $item['quantity'];
        $size = $item['size'];
        $price = $item['price'];
        
        // Check stock
        $stock_query = "SELECT stock FROM products WHERE id = ?";
        $stock_stmt = $conn->prepare($stock_query);
        $stock_stmt->bind_param('i', $product_id);
        $stock_stmt->execute();
        $stock_result = $stock_stmt->get_result();
        
        if ($stock_result->num_rows === 0) {
            throw new Exception('Product not found');
        }
        
        $current_stock = $stock_result->fetch_assoc()['stock'];
        
        if ($current_stock < $quantity) {
            throw new Exception('Insufficient stock for product ID: ' . $product_id);
        }
        
        // Insert order item
        $item_query = "INSERT INTO order_items (order_id, product_id, quantity, size, price) VALUES (?, ?, ?, ?, ?)";
        $item_stmt = $conn->prepare($item_query);
        $item_stmt->bind_param('iiisd', $order_id, $product_id, $quantity, $size, $price);
        
        if (!$item_stmt->execute()) {
            throw new Exception('Failed to insert order item');
        }
        
        // Update stock
        $new_stock = $current_stock - $quantity;
        $update_query = "UPDATE products SET stock = ? WHERE id = ?";
        $update_stmt = $conn->prepare($update_query);
        $update_stmt->bind_param('ii', $new_stock, $product_id);
        
        if (!$update_stmt->execute()) {
            throw new Exception('Failed to update stock');
        }
    }
    
    $conn->commit();
    
    echo json_encode([
        'success' => true,
        'message' => 'Order processed successfully',
        'order_id' => $order_id
    ]);
    
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}

$conn->close();
?>