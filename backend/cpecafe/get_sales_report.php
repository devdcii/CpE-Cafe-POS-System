<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

require_once 'config/dbcon.php';

try {
    // Get total sales
    $total_sales_query = "SELECT SUM(total) as total_sales FROM orders";
    $total_sales_result = $conn->query($total_sales_query);
    $total_sales = $total_sales_result->fetch_assoc()['total_sales'] ?? 0;
    
    // Get total orders
    $total_orders_query = "SELECT COUNT(*) as total_orders FROM orders";
    $total_orders_result = $conn->query($total_orders_query);
    $total_orders = $total_orders_result->fetch_assoc()['total_orders'] ?? 0;
    
    // Get recent orders
    $recent_orders_query = "SELECT id, total, DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') as created_at 
                           FROM orders 
                           ORDER BY created_at DESC 
                           LIMIT 10";
    $recent_orders_result = $conn->query($recent_orders_query);
    
    $recent_orders = [];
    while ($row = $recent_orders_result->fetch_assoc()) {
        $recent_orders[] = $row;
    }
    
    // Get daily sales (last 7 days)
    $daily_sales_query = "SELECT DATE(created_at) as date, SUM(total) as daily_total 
                         FROM orders 
                         WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
                         GROUP BY DATE(created_at) 
                         ORDER BY date DESC";
    $daily_sales_result = $conn->query($daily_sales_query);
    
    $daily_sales = [];
    while ($row = $daily_sales_result->fetch_assoc()) {
        $daily_sales[] = $row;
    }
    
    // Get top selling products
    $top_products_query = "SELECT p.name, p.category, SUM(oi.quantity) as total_sold 
                          FROM order_items oi 
                          JOIN products p ON oi.product_id = p.id 
                          GROUP BY p.id, p.name, p.category 
                          ORDER BY total_sold DESC 
                          LIMIT 5";
    $top_products_result = $conn->query($top_products_query);
    
    $top_products = [];
    while ($row = $top_products_result->fetch_assoc()) {
        $top_products[] = $row;
    }
    
    echo json_encode([
        'success' => true,
        'total_sales' => (float)$total_sales,
        'total_orders' => (int)$total_orders,
        'recent_orders' => $recent_orders,
        'daily_sales' => $daily_sales,
        'top_products' => $top_products
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}

$conn->close();
?>