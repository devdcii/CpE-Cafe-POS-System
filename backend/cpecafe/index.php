<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CpE Cafe - Admin Dashboard</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        :root {
            --coffee-dark: #3C2414;
            --coffee-medium: #8B4513;
            --coffee-light: #D2691E;
            --cream: #F5E6D3;
            --accent-gold: #DAA520;
            --bg-light: #FAF7F2;
            --white: #FFFFFF;
            --text-dark: #2C1810;
            --text-medium: #5D4E37;
            --shadow: rgba(60, 36, 20, 0.1);
            --shadow-hover: rgba(60, 36, 20, 0.15);
            --sidebar-width: 240px;
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, var(--bg-light) 0%, var(--cream) 100%);
            min-height: 100vh;
            color: var(--text-dark);
        }

        /* Sidebar Styles */
        .sidebar {
            position: fixed;
            left: 0;
            top: 0;
            width: var(--sidebar-width);
            height: 100vh;
            background: linear-gradient(180deg, var(--coffee-dark) 0%, var(--coffee-medium) 100%);
            z-index: 1000;
            transition: all 0.3s ease;
            box-shadow: 4px 0 20px var(--shadow);
        }

        .sidebar-header {
            padding: 30px 20px;
            text-align: center;
            border-bottom: 1px solid rgba(245, 230, 211, 0.2);
        }

        .sidebar-header h1 {
            color: var(--cream);
            font-size: 1.8rem;
            font-weight: 800;
            margin-bottom: 5px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .sidebar-header p {
            color: var(--cream);
            font-size: 0.9rem;
            opacity: 0.8;
        }

        .sidebar-nav {
            padding: 20px 0;
        }

        .nav-item {
            display: flex;
            align-items: center;
            padding: 18px 25px;
            color: var(--cream);
            text-decoration: none;
            transition: all 0.3s ease;
            border-left: 4px solid transparent;
            font-weight: 500;
            cursor: pointer;
        }

        .nav-item:hover {
            background: rgba(245, 230, 211, 0.1);
            border-left-color: var(--accent-gold);
            transform: translateX(5px);
        }

        .nav-item.active {
            background: rgba(245, 230, 211, 0.15);
            border-left-color: var(--accent-gold);
            color: var(--accent-gold);
        }

        .nav-item i {
            width: 24px;
            margin-right: 15px;
            font-size: 1.1rem;
        }

        .sidebar-footer {
            position: absolute;
            bottom: 20px;
            left: 20px;
            right: 20px;
            text-align: center;
            color: var(--cream);
            opacity: 0.7;
            font-size: 0.8rem;
        }

        /* Main Content */
        .main-content {
            margin-left: var(--sidebar-width);
            min-height: 100vh;
            transition: all 0.3s ease;
        }

        .header {
            background: var(--white);
            padding: 25px 30px;
            box-shadow: 0 2px 20px var(--shadow);
            border-bottom: 1px solid rgba(139, 69, 19, 0.1);
        }

        .header-content {
            display: flex;
            justify-content: between;
            align-items: center;
        }

        .page-title {
            color: var(--coffee-dark);
            font-size: 2rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .refresh-btn {
            background: linear-gradient(135deg, var(--coffee-medium) 0%, var(--coffee-light) 100%);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 0.95rem;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 15px var(--shadow);
            margin-left: auto;
        }

        .refresh-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px var(--shadow-hover);
        }

        .content-area {
            padding: 30px;
            max-width: 100%;
        }

        /* Tab Content */
        .tab-content {
            display: none;
            animation: fadeInUp 0.6s ease-out;
        }

        .tab-content.active {
            display: block;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--white);
            border-radius: 16px;
            padding: 25px;
            text-align: center;
            box-shadow: 0 8px 25px var(--shadow);
            border: 1px solid rgba(218, 165, 32, 0.1);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--coffee-medium), var(--accent-gold));
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px var(--shadow-hover);
        }

        .stat-value {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--coffee-dark);
            margin-bottom: 8px;
            background: linear-gradient(135deg, var(--coffee-dark), var(--coffee-medium));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .stat-label {
            color: var(--text-medium);
            font-size: 0.95rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        /* Charts Grid */
        .charts-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
            margin-bottom: 30px;
        }

        .card {
            background: var(--white);
            border-radius: 16px;
            padding: 25px;
            box-shadow: 0 8px 25px var(--shadow);
            transition: all 0.3s ease;
            border: 1px solid rgba(218, 165, 32, 0.1);
            position: relative;
            overflow: hidden;
        }

        .card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--coffee-medium), var(--accent-gold));
        }

        .card:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 30px var(--shadow-hover);
        }

        .card h2 {
            color: var(--coffee-dark);
            margin-bottom: 20px;
            font-size: 1.3rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 10px;
            padding-bottom: 12px;
            border-bottom: 2px solid var(--cream);
        }

        .chart-container {
            position: relative;
            height: 300px;
            margin: 15px 0;
        }

        /* Orders Table */
        .orders-container {
            background: var(--white);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 8px 25px var(--shadow);
            border: 1px solid rgba(218, 165, 32, 0.1);
        }

        .orders-header {
            background: linear-gradient(135deg, var(--coffee-dark), var(--coffee-medium));
            color: var(--cream);
            padding: 25px 30px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .orders-header h2 {
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0;
        }

        .search-bar {
            background: var(--white);
            border: 1px solid rgba(139, 69, 19, 0.2);
            border-radius: 25px;
            padding: 12px 20px;
            width: 300px;
            margin-left: auto;
            font-size: 0.95rem;
            transition: all 0.3s ease;
        }

        .search-bar:focus {
            outline: none;
            border-color: var(--accent-gold);
            box-shadow: 0 0 15px rgba(218, 165, 32, 0.2);
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 18px 25px;
            text-align: left;
            border-bottom: 1px solid rgba(139, 69, 19, 0.1);
        }

        th {
            background: rgba(139, 69, 19, 0.05);
            color: var(--coffee-dark);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-size: 0.85rem;
        }

        tbody tr {
            transition: all 0.3s ease;
        }

        tbody tr:hover {
            background: rgba(245, 230, 211, 0.3);
            transform: scale(1.01);
        }

        .order-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-completed {
            background: rgba(39, 174, 96, 0.1);
            color: #27ae60;
            border: 1px solid rgba(39, 174, 96, 0.3);
        }

        .status-pending {
            background: rgba(243, 156, 18, 0.1);
            color: #f39c12;
            border: 1px solid rgba(243, 156, 18, 0.3);
        }

        /* Inventory Categories */
        .category-section {
            background: var(--white);
            border-radius: 16px;
            margin-bottom: 25px;
            overflow: hidden;
            box-shadow: 0 8px 25px var(--shadow);
            border: 1px solid rgba(218, 165, 32, 0.1);
        }

        .category-header {
            background: linear-gradient(135deg, var(--coffee-medium), var(--coffee-light));
            color: var(--cream);
            padding: 20px 25px;
            font-size: 1.2rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .stock-status {
            padding: 6px 12px;
            border-radius: 15px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .status-low {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
            box-shadow: 0 2px 8px rgba(231, 76, 60, 0.3);
        }

        .status-medium {
            background: linear-gradient(135deg, #f39c12, #e67e22);
            color: white;
            box-shadow: 0 2px 8px rgba(243, 156, 18, 0.3);
        }

        .status-good {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
            color: white;
            box-shadow: 0 2px 8px rgba(39, 174, 96, 0.3);
        }

        .no-data {
            text-align: center;
            color: var(--text-medium);
            font-style: italic;
            padding: 40px;
            font-size: 1.1rem;
        }

        /* Mobile Responsive */
        .mobile-toggle {
            display: none;
        }

        @media (max-width: 1024px) {
            .charts-grid {
                grid-template-columns: 1fr;
            }
            
            .stats-grid {
                grid-template-columns: repeat(4, 1fr);
                gap: 15px;
            }
            
            .stat-card {
                padding: 20px 15px;
            }
            
            .stat-value {
                font-size: 2rem;
            }
        }

        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }

            .sidebar.open {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0;
            }

            .mobile-toggle {
                display: block;
                background: none;
                border: none;
                color: var(--coffee-dark);
                font-size: 1.5rem;
                cursor: pointer;
                margin-right: 15px;
            }

            .header-content {
                flex-wrap: wrap;
                gap: 15px;
            }

            .search-bar {
                width: 100%;
                max-width: 300px;
            }

            .stats-grid {
                grid-template-columns: repeat(4, 1fr);
                gap: 10px;
            }
            
            .stat-card {
                padding: 15px 10px;
            }
            
            .stat-value {
                font-size: 1.5rem;
            }
            
            .stat-label {
                font-size: 0.8rem;
            }

            th, td {
                padding: 12px 15px;
                font-size: 0.9rem;
            }

            .content-area {
                padding: 20px;
            }
        }

        @media (max-width: 480px) {
            .stats-grid {
                grid-template-columns: repeat(4, 1fr);
                gap: 8px;
            }
            
            .stat-card {
                padding: 12px 8px;
            }
            
            .stat-value {
                font-size: 1.2rem;
            }
            
            .stat-label {
                font-size: 0.7rem;
            }
        }

        /* Loading Animation */
        .loading {
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 3px solid rgba(255,255,255,.3);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 1s ease-in-out infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Pagination */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
            padding: 25px;
            background: var(--white);
        }

        .pagination button {
            padding: 10px 15px;
            border: 1px solid rgba(139, 69, 19, 0.2);
            background: var(--white);
            color: var(--coffee-dark);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .pagination button:hover {
            background: var(--coffee-medium);
            color: white;
        }

        .pagination button.active {
            background: var(--coffee-medium);
            color: white;
        }

        .pagination button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
        <div class="sidebar-header">
            <h1>☕ CpE Cafe</h1>
            <p>Admin Dashboard</p>
        </div>
        
        <nav class="sidebar-nav">
            <a href="#dashboard" class="nav-item active" data-tab="dashboard">
                <i class="fas fa-chart-line"></i>
                Dashboard
            </a>
            <a href="#orders" class="nav-item" data-tab="orders">
                <i class="fas fa-receipt"></i>
                All Orders
            </a>
            <a href="#inventory" class="nav-item" data-tab="inventory">
                <i class="fas fa-boxes"></i>
                Inventory Status
            </a>
        </nav>
        
        <div class="sidebar-footer">
            <p>&copy; 2024 CpE Cafe System</p>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="header">
            <div class="header-content">
                <button class="mobile-toggle" onclick="toggleSidebar()">
                    <i class="fas fa-bars"></i>
                </button>
                <h1 class="page-title" id="pageTitle">
                    <i class="fas fa-chart-line"></i>
                    Dashboard
                </h1>
                <button class="refresh-btn" onclick="refreshData()">
                    <i class="fas fa-sync-alt"></i>
                    Refresh
                </button>
            </div>
        </div>

        <div class="content-area">
            <!-- Dashboard Tab -->
            <div id="dashboard" class="tab-content active">
                <?php
                require_once 'config/dbcon.php';
                
                try {
                    // Get statistics
                    $total_sales_query = "SELECT SUM(total) as total_sales FROM orders";
                    $total_sales_result = $conn->query($total_sales_query);
                    $total_sales = $total_sales_result->fetch_assoc()['total_sales'] ?? 0;
                    
                    $total_orders_query = "SELECT COUNT(*) as total_orders FROM orders";
                    $total_orders_result = $conn->query($total_orders_query);
                    $total_orders = $total_orders_result->fetch_assoc()['total_orders'] ?? 0;
                    
                    $total_products_query = "SELECT COUNT(*) as total_products FROM products";
                    $total_products_result = $conn->query($total_products_query);
                    $total_products = $total_products_result->fetch_assoc()['total_products'] ?? 0;
                    
                    $low_stock_query = "SELECT COUNT(*) as low_stock FROM products WHERE stock <= 10";
                    $low_stock_result = $conn->query($low_stock_query);
                    $low_stock = $low_stock_result->fetch_assoc()['low_stock'] ?? 0;
                    
                    // Get daily sales data for chart
                    $daily_sales_chart_query = "SELECT DATE_FORMAT(created_at, '%M %d') as date, SUM(total) as daily_total FROM orders WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) GROUP BY DATE(created_at) ORDER BY date ASC";
                    $daily_sales_chart_result = $conn->query($daily_sales_chart_query);
                    
                    $chart_labels = [];
                    $chart_data = [];
                    while ($day = $daily_sales_chart_result->fetch_assoc()) {
                        $chart_labels[] = $day['date'];
                        $chart_data[] = floatval($day['daily_total']);
                    }
                    
                    // Get category sales data for pie chart
                    $category_sales_query = "SELECT p.category, SUM(oi.quantity) as category_sales FROM order_items oi JOIN products p ON oi.product_id = p.id GROUP BY p.category ORDER BY category_sales DESC";
                    $category_sales_result = $conn->query($category_sales_query);
                    
                    $category_labels = [];
                    $category_data = [];
                    while ($category = $category_sales_result->fetch_assoc()) {
                        $category_labels[] = $category['category'];
                        $category_data[] = intval($category['category_sales']);
                    }
                ?>
                
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-value">₱<?= number_format($total_sales, 2) ?></div>
                        <div class="stat-label">Total Sales</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><?= $total_orders ?></div>
                        <div class="stat-label">Total Orders</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><?= $total_products ?></div>
                        <div class="stat-label">Total Products</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><?= $low_stock ?></div>
                        <div class="stat-label">Low Stock Alert</div>
                    </div>
                </div>

                <div class="charts-grid">
                    <div class="card">
                        <h2><i class="fas fa-chart-line"></i> Daily Sales Trend</h2>
                        <div class="chart-container">
                            <canvas id="dailySalesChart"></canvas>
                        </div>
                    </div>

                    <div class="card">
                        <h2><i class="fas fa-chart-pie"></i> Category Sales Distribution</h2>
                        <div class="chart-container">
                            <canvas id="categorySalesChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Orders Grid - Side by Side -->
                <div class="charts-grid">
                    <div class="card">
                        <h2><i class="fas fa-receipt"></i> Recent Orders</h2>
                        <?php
                        $recent_orders_query = "SELECT id, total, DATE_FORMAT(created_at, '%b %d, %Y %h:%i %p') as created_at FROM orders ORDER BY created_at DESC LIMIT 10";
                        $recent_orders_result = $conn->query($recent_orders_query);
                        
                        if ($recent_orders_result->num_rows > 0) {
                            echo "<table>";
                            echo "<thead><tr><th>Order</th><th>Total</th><th>Date</th></tr></thead>";
                            echo "<tbody>";
                            while ($order = $recent_orders_result->fetch_assoc()) {
                                echo "<tr>";
                                echo "<td>" . $order['id'] . "</td>";
                                echo "<td>₱" . number_format($order['total'], 2) . "</td>";
                                echo "<td>" . $order['created_at'] . "</td>";
                                echo "</tr>";
                            }
                            echo "</tbody></table>";
                        } else {
                            echo "<div class='no-data'>No orders found</div>";
                        }
                        ?>
                    </div>

                    <div class="card">
                        <h2><i class="fas fa-trophy"></i> Top Selling Products</h2>
                        <?php
                        $top_products_query = "SELECT p.name, p.category, SUM(oi.quantity) as total_sold FROM order_items oi JOIN products p ON oi.product_id = p.id GROUP BY p.id, p.name, p.category ORDER BY total_sold DESC LIMIT 10";
                        $top_products_result = $conn->query($top_products_query);
                        
                        if ($top_products_result->num_rows > 0) {
                            echo "<table>";
                            echo "<thead><tr><th>Rank</th><th>Product</th><th>Sold</th></tr></thead>";
                            echo "<tbody>";
                            $rank = 1;
                            while ($product = $top_products_result->fetch_assoc()) {
                                echo "<tr>";
                                echo "<td>" . $rank . "</td>";
                                echo "<td>" . htmlspecialchars($product['name']) . "</td>";
                                echo "<td>" . $product['total_sold'] . "</td>";
                                echo "</tr>";
                                $rank++;
                            }
                            echo "</tbody></table>";
                        } else {
                            echo "<div class='no-data'>No sales data found</div>";
                        }
                        ?>
                    </div>
                </div>
                
                <?php
                } catch (Exception $e) {
                    echo "<div class='card'>";
                    echo "<h2>❌ Error</h2>";
                    echo "<p style='color: #e74c3c; font-weight: 600;'>Database connection error: " . $e->getMessage() . "</p>";
                    echo "</div>";
                }
                ?>
            </div>

            <!-- Orders Tab -->
            <div id="orders" class="tab-content">
                <div class="orders-container">
                    <div class="orders-header">
                        <i class="fas fa-receipt"></i>
                        <h2>All Orders</h2>
                        <input type="text" class="search-bar" placeholder="Search orders..." id="orderSearch">
                    </div>
                    
                    <table>
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Date & Time</th>
                                <th>Total Amount</th>
                                <th>Items Count</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="ordersTableBody">
                            <?php
                            try {
                                $all_orders_query = "SELECT o.id, o.total, o.created_at, COUNT(oi.id) as items_count 
                                                   FROM orders o 
                                                   LEFT JOIN order_items oi ON o.id = oi.order_id 
                                                   GROUP BY o.id, o.total, o.created_at 
                                                   ORDER BY o.id ASC";
                                $all_orders_result = $conn->query($all_orders_query);
                                
                                if ($all_orders_result->num_rows > 0) {
                                    while ($order = $all_orders_result->fetch_assoc()) {
                                        echo "<tr>";
                                        echo "<td>Order " . $order['id'] . "</td>";
                                        echo "<td>" . date('M j, Y g:i A', strtotime($order['created_at'])) . "</td>";
                                        echo "<td>₱" . number_format($order['total'], 2) . "</td>";
                                        echo "<td>" . $order['items_count'] . " items</td>";
                                        echo "<td><span class='order-status status-completed'>Completed</span></td>";
                                        echo "</tr>";
                                    }
                                } else {
                                    echo "<tr><td colspan='5' class='no-data'>No orders found</td></tr>";
                                }
                            } catch (Exception $e) {
                                echo "<tr><td colspan='5' class='no-data'>Error loading orders: " . $e->getMessage() . "</td></tr>";
                            }
                            ?>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Inventory Tab -->
            <div id="inventory" class="tab-content">
                <?php
                try {
                    // Get all products grouped by category
                    $inventory_query = "SELECT name, category, stock FROM products ORDER BY category, name";
                    $inventory_result = $conn->query($inventory_query);
                    
                    $products_by_category = [];
                    if ($inventory_result->num_rows > 0) {
                        while ($product = $inventory_result->fetch_assoc()) {
                            $products_by_category[$product['category']][] = $product;
                        }
                    }
                    
                    if (empty($products_by_category)): ?>
                        <div class='card'>
                            <div class='no-data'>No products found</div>
                        </div>
                    <?php else: 
                        $category_icons = [
                            'AMERIKANO' => 'fas fa-coffee',
                            'CHEESECAKE' => 'fas fa-birthday-cake',
                            'FRAPPE NON-COFFEE' => 'fas fa-glass-martini',
                            'Default' => 'fas fa-box'
                        ];
                        
                        foreach ($products_by_category as $category => $products): 
                            $icon = $category_icons[$category] ?? $category_icons['Default'];
                    ?>
                        <div class="category-section">
                            <div class="category-header">
                                <i class="<?= $icon ?>"></i>
                                <?= htmlspecialchars($category) ?>
                            </div>
                            <table>
                                <thead>
                                    <tr>
                                        <th>Product Name</th>
                                        <th>Current Stock</th>
                                        <th>Status</th>
                                        <th>Last Updated</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($products as $product): ?>
                                        <?php
                                        $status_class = $product['stock'] <= 10 ? 'status-low' :
                                                        ($product['stock'] <= 20 ? 'status-medium' : 'status-good');
                                        $status_text = $product['stock'] <= 10 ? 'LOW' :
                                                        ($product['stock'] <= 20 ? 'MEDIUM' : 'GOOD');
                                        ?>
                                        <tr>
                                            <td><?= htmlspecialchars($product['name']) ?></td>
                                            <td><?= $product['stock'] ?> units</td>
                                            <td><span class="stock-status <?= $status_class ?>"><?= $status_text ?></span></td>
                                            <td><?= date('M j, Y') ?></td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                    <?php endforeach; ?>
                <?php endif; ?>
                
                <?php
                } catch (Exception $e) {
                    echo "<div class='card'>";
                    echo "<h2>❌ Error</h2>";
                    echo "<p style='color: #e74c3c; font-weight: 600;'>Database connection error: " . $e->getMessage() . "</p>";
                    echo "</div>";
                }
                
                $conn->close();
                ?>
            </div>
        </div>
    </div>

    <script>
        // Navigation functionality
        const navItems = document.querySelectorAll('.nav-item');
        const tabContents = document.querySelectorAll('.tab-content');
        const pageTitle = document.getElementById('pageTitle');

        navItems.forEach(item => {
            item.addEventListener('click', function(e) {
                e.preventDefault();
                
                // Remove active class from all nav items
                navItems.forEach(nav => nav.classList.remove('active'));
                
                // Add active class to clicked item
                this.classList.add('active');
                
                // Hide all tab contents
                tabContents.forEach(content => content.classList.remove('active'));
                
                // Show selected tab content
                const targetTab = this.getAttribute('data-tab');
                document.getElementById(targetTab).classList.add('active');
                
                // Update page title
                const titles = {
                    dashboard: '<i class="fas fa-chart-line"></i> Dashboard',
                    orders: '<i class="fas fa-receipt"></i> All Orders',
                    inventory: '<i class="fas fa-boxes"></i> Inventory Status'
                };
                pageTitle.innerHTML = titles[targetTab];
            });
        });

        // Mobile sidebar toggle
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            sidebar.classList.toggle('open');
        }

        // Close sidebar on mobile when clicking outside
        document.addEventListener('click', function(e) {
            const sidebar = document.getElementById('sidebar');
            const toggle = document.querySelector('.mobile-toggle');
            
            if (window.innerWidth <= 768 && 
                !sidebar.contains(e.target) && 
                !toggle.contains(e.target) && 
                sidebar.classList.contains('open')) {
                sidebar.classList.remove('open');
            }
        });

        // Chart.js configuration
        const chartColors = {
            primary: '#8B4513',
            secondary: '#D2691E',
            accent: '#DAA520',
            gradient: ['#3C2414', '#8B4513', '#D2691E', '#DAA520', '#F5E6D3']
        };

        // Daily Sales Chart
        const dailySalesCtx = document.getElementById('dailySalesChart').getContext('2d');
        const gradient = dailySalesCtx.createLinearGradient(0, 0, 0, 300);
        gradient.addColorStop(0, 'rgba(139, 69, 19, 0.4)');
        gradient.addColorStop(1, 'rgba(139, 69, 19, 0.05)');

        new Chart(dailySalesCtx, {
            type: 'line',
            data: {
                labels: <?= json_encode($chart_labels) ?>,
                datasets: [{
                    label: 'Daily Sales (₱)',
                    data: <?= json_encode($chart_data) ?>,
                    borderColor: chartColors.primary,
                    backgroundColor: gradient,
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: chartColors.accent,
                    pointBorderColor: chartColors.primary,
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(139, 69, 19, 0.1)'
                        },
                        ticks: {
                            color: '#5D4E37',
                            font: { size: 12 },
                            callback: function(value) {
                                return '₱' + value.toLocaleString();
                            }
                        }
                    },
                    x: {
                        grid: {
                            color: 'rgba(139, 69, 19, 0.1)'
                        },
                        ticks: {
                            color: '#5D4E37',
                            font: { size: 12 }
                        }
                    }
                }
            }
        });

        // Category Sales Chart
        const categorySalesCtx = document.getElementById('categorySalesChart').getContext('2d');
        new Chart(categorySalesCtx, {
            type: 'doughnut',
            data: {
                labels: <?= json_encode($category_labels) ?>,
                datasets: [{
                    data: <?= json_encode($category_data) ?>,
                    backgroundColor: chartColors.gradient,
                    borderWidth: 3,
                    borderColor: '#ffffff',
                    hoverBorderWidth: 5
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#5D4E37',
                            padding: 20,
                            font: {
                                size: 12,
                                weight: '600'
                            }
                        }
                    }
                },
                cutout: '60%'
            }
        });

        // Search functionality for orders
        document.getElementById('orderSearch').addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            const tableRows = document.querySelectorAll('#ordersTableBody tr');
            
            tableRows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? '' : 'none';
            });
        });

        // Pagination functions
        function previousPage() {
            const activeBtn = document.querySelector('.pagination button.active');
            const prevBtn = activeBtn.previousElementSibling;
            if (prevBtn && prevBtn.textContent !== '') {
                activeBtn.classList.remove('active');
                prevBtn.classList.add('active');
                loadOrdersPage(parseInt(prevBtn.textContent));
            }
        }

        function nextPage() {
            const activeBtn = document.querySelector('.pagination button.active');
            const nextBtn = activeBtn.nextElementSibling;
            if (nextBtn && nextBtn.textContent !== '') {
                activeBtn.classList.remove('active');
                nextBtn.classList.add('active');
                loadOrdersPage(parseInt(nextBtn.textContent));
            }
        }

        function loadOrdersPage(page) {
            // Implement pagination logic here
            console.log('Loading page:', page);
        }

        // Refresh data function
        function refreshData() {
            const refreshBtn = document.querySelector('.refresh-btn');
            const originalContent = refreshBtn.innerHTML;
            
            refreshBtn.innerHTML = '<div class="loading"></div> Refreshing...';
            refreshBtn.disabled = true;
            
            // Simulate refresh delay
            setTimeout(() => {
                refreshBtn.innerHTML = originalContent;
                refreshBtn.disabled = false;
                
                // Show success message
                showNotification('Data refreshed successfully!', 'success');
            }, 3000);
        }

        // Notification system
        function showNotification(message, type = 'info') {
            const notification = document.createElement('div');
            notification.className = `notification ${type}`;
            notification.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                background: ${type === 'success' ? '#27ae60' : '#8B4513'};
                color: white;
                padding: 15px 25px;
                border-radius: 8px;
                box-shadow: 0 4px 20px rgba(0,0,0,0.2);
                z-index: 10000;
                animation: slideIn 0.3s ease;
            `;
            notification.textContent = message;
            
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.style.animation = 'slideOut 0.3s ease forwards';
                setTimeout(() => notification.remove(), 300);
            }, 3000);
        }

        // Add CSS animations for notifications
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideIn {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
            @keyframes slideOut {
                from { transform: translateX(0); opacity: 1; }
                to { transform: translateX(100%); opacity: 0; }
            }
        `;
        document.head.appendChild(style);

        // Initialize tooltips and animations on load
        document.addEventListener('DOMContentLoaded', function() {
            // Add smooth animations to elements
            const cards = document.querySelectorAll('.card, .stat-card');
            cards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.1}s`;
            });

            // Auto-refresh every 5 minutes
            setInterval(() => {
                if (document.visibilityState === 'visible') {
                    refreshData();
                }
            }, 300000);
        });

        // Handle window resize
        window.addEventListener('resize', function() {
            if (window.innerWidth > 768) {
                document.getElementById('sidebar').classList.remove('open');
            }
        });
		
		function refreshData() {
			location.reload(); // reloads the page
		}
    </script>
</body>
</html>