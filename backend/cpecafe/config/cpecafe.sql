-- CPE Cafe Database Setup
-- Run this in your phpMyAdmin or MySQL command line

-- Create database
CREATE DATABASE IF NOT EXISTS cpecafe;
USE cpecafe;

-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    large_price DECIMAL(10,2) NOT NULL,
    small_price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    image VARCHAR(255) DEFAULT 'assets/images/bgcafe.jfif',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create orders table
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create order_items table
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    size VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Insert sample products based on the menu image
INSERT INTO products (name, category, large_price, small_price, stock) VALUES
-- Frappe Non-Coffee
('Taro', 'FRAPPE NON-COFFEE', 89, 69, 50),
('Matcha', 'FRAPPE NON-COFFEE', 89, 69, 45),
('Chocolate', 'FRAPPE NON-COFFEE', 89, 69, 60),
('Red Velvet', 'FRAPPE NON-COFFEE', 89, 69, 30),
('Choco Chip', 'FRAPPE NON-COFFEE', 89, 69, 40),
('Strawberry', 'FRAPPE NON-COFFEE', 89, 69, 35),
('Cookies n Cream', 'FRAPPE NON-COFFEE', 89, 69, 25),
('Cheesecake', 'FRAPPE NON-COFFEE', 89, 69, 20),
('Dark Chocolate', 'FRAPPE NON-COFFEE', 89, 69, 55),
('Blueberry', 'FRAPPE NON-COFFEE', 89, 69, 30),

-- Frappuccino
('Vanilla', 'FRAPPUCCINO', 79, 59, 40),
('Caramel Macchiato', 'FRAPPUCCINO', 79, 59, 35),
('Almond', 'FRAPPUCCINO', 79, 59, 25),
('Salted Caramel', 'FRAPPUCCINO', 79, 59, 30),
('Hazelnut', 'FRAPPUCCINO', 79, 59, 45),
('White Chocolate', 'FRAPPUCCINO', 79, 59, 40),
('Triple Mocha', 'FRAPPUCCINO', 89, 69, 20),
('Dark Mocha', 'FRAPPUCCINO', 89, 79, 25),

-- Cheesecake Series
('Mango', 'CHEESECAKE', 49, 39, 15),
('Taro', 'CHEESECAKE', 49, 39, 20),
('Chocolate', 'CHEESECAKE', 49, 39, 25),
('Blueberry', 'CHEESECAKE', 49, 39, 18),
('Strawberry', 'CHEESECAKE', 49, 39, 22),
('Red Velvet', 'CHEESECAKE', 49, 39, 12),

-- Milktea
('Original', 'MILKTEA', 49, 39, 60),
('Taro', 'MILKTEA', 49, 39, 55),
('Chocolate', 'MILKTEA', 49, 39, 50),
('Okinawa', 'MILKTEA', 59, 49, 40),
('Wintermelon', 'MILKTEA', 49, 39, 35),
('Brown Sugar', 'MILKTEA', 59, 49, 45),
('Cookies n Cream', 'MILKTEA', 49, 39, 30),
('Matcha', 'MILKTEA', 49, 39, 25),

-- Special Milktea
('Matcha', 'SPECIAL MILKTEA', 59, 49, 20),
('Red Velvet', 'SPECIAL MILKTEA', 59, 49, 18),
('Salted Caramel', 'SPECIAL MILKTEA', 59, 49, 25),
('Strawberry Cream', 'SPECIAL MILKTEA', 59, 49, 15),
('Chocolate Hazel', 'SPECIAL MILKTEA', 59, 49, 22),
('Banana Overload', 'SPECIAL MILKTEA', 59, 49, 20),
('Choco Cookies', 'SPECIAL MILKTEA', 59, 49, 18),
('Dark Chocolate', 'SPECIAL MILKTEA', 59, 49, 15),

-- Iced Latte
('Original', 'ICED LATTE', 49, 39, 40),
('Vanilla', 'ICED LATTE', 49, 39, 35),
('Chocolate', 'ICED LATTE', 49, 39, 30),
('Hazelnut', 'ICED LATTE', 49, 39, 25),
('White Chocolate', 'ICED LATTE', 49, 39, 20),
('Almond', 'ICED LATTE', 49, 39, 28),
('Butterscotch', 'ICED LATTE', 49, 39, 22),
('Salted Caramel', 'ICED LATTE', 49, 39, 26),
('Caramel Macchiato', 'ICED LATTE', 49, 39, 24),

-- Special Latte
('Matcha', 'SPECIAL LATTE', 59, 49, 15),
('Red Velvet', 'SPECIAL LATTE', 59, 49, 18),
('Cookies n Cream', 'SPECIAL LATTE', 59, 49, 12),
('Dark Mocha', 'SPECIAL LATTE', 59, 49, 20),
('Spanish Latte', 'SPECIAL LATTE', 59, 49, 16),
('Dirty Matcha', 'SPECIAL LATTE', 59, 49, 14),
('Iced Chai Latte', 'SPECIAL LATTE', 59, 49, 10),
('Dark Chocolate', 'SPECIAL LATTE', 59, 49, 13),

-- Fruit Teas
('Blueberry', 'FRUIT TEAS', 49, 39, 30),
('Strawberry', 'FRUIT TEAS', 49, 39, 28),
('Mango', 'FRUIT TEAS', 49, 39, 35),
('Lychee', 'FRUIT TEAS', 49, 39, 25),
('Green Apple', 'FRUIT TEAS', 49, 39, 20),
('Passion Fruit', 'FRUIT TEAS', 49, 39, 22),

-- Lemonade
('Mixed Berries', 'LEMONADE', 59, 49, 25),
('Blueberry', 'LEMONADE', 59, 49, 20),
('Strawberry', 'LEMONADE', 59, 49, 22),
('Mango', 'LEMONADE', 59, 49, 18),
('Lychee', 'LEMONADE', 59, 49, 15),
('Green Apple', 'LEMONADE', 59, 49, 20),
('Passion Fruit', 'LEMONADE', 59, 49, 17),

-- Amerikano
('Original', 'AMERIKANO', 49, 39, 50),
('Vanilla', 'AMERIKANO', 49, 39, 40),
('Hazelnut', 'AMERIKANO', 49, 39, 35),
('Salted Caramel', 'AMERIKANO', 49, 39, 30),
('Almond', 'AMERIKANO', 49, 39, 25),
('Butterscotch', 'AMERIKANO', 49, 39, 28),
('Caramel Macchiato', 'AMERIKANO', 49, 39, 32),

-- Hot Coffee
('Vanilla', 'HOT COFFEE', 49, 39, 45),
('Hazelnut', 'HOT COFFEE', 49, 39, 40),
('Almond', 'HOT COFFEE', 49, 39, 35),
('Butterscotch', 'HOT COFFEE', 49, 39, 30),
('Salted Caramel', 'HOT COFFEE', 49, 39, 25),
('Caramel Macchiato', 'HOT COFFEE', 49, 39, 28),
('White Chocolate', 'HOT COFFEE', 49, 39, 20),
('Chocolate', 'HOT COFFEE', 59, 49, 22);

-- Insert some sample orders for testing
INSERT INTO orders (total) VALUES 
(158.00),
(247.00),
(89.00),
(196.00),
(312.00);

-- Insert sample order items
INSERT INTO order_items (order_id, product_id, quantity, size, price) VALUES
(1, 1, 1, 'Large', 89.00),
(1, 2, 1, 'Small', 69.00),
(2, 5, 2, 'Large', 89.00),
(2, 10, 1, 'Small', 69.00),
(3, 15, 1, 'Large', 89.00),
(4, 20, 2, 'Large', 49.00),
(4, 25, 2, 'Large', 49.00),
(4, 30, 2, 'Large', 49.00),
(5, 35, 3, 'Large', 59.00),
(5, 40, 2, 'Small', 39.00),
(5, 45, 1, 'Large', 59.00);