# CpE Cafe
### Point of Sale and Inventory Management System

> A mobile-first cafe ordering system with real-time inventory tracking and sales analytics — built with Flutter and a PHP/MySQL backend.

---

## Overview

CpE Cafe is a POS and inventory management system designed for a cafe offering coffee, frappes, milk teas, cheesecakes, and other beverages. The Flutter mobile app connects to a PHP REST API backend that handles order processing, automatic stock deduction, and sales reporting.

---

## Features

- **Product Menu** — 85+ items across 13 categories with large/small pricing
- **Order Processing** — transaction-safe orders with automatic stock deduction
- **Real-time Inventory** — stock auto-deducted on every order, manual update supported
- **Low Stock Alerts** — visual indicators for low, medium, and good stock levels
- **Sales Analytics** — daily trends, top products, category breakdowns
- **Admin Dashboard** — web-based panel with Chart.js graphs and order history
- **Offline Support** — local session persistence via Hive
- **Onboarding Screen** — carousel intro with session check on launch

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter 3.x (Dart) |
| Local Storage | Hive / hive_flutter |
| Backend API | PHP 7.4+ |
| Database | MySQL 5.7+ |
| Web Server | Apache (XAMPP) |
| Admin Dashboard | PHP + Chart.js |
| Data Format | JSON / REST |

---

## Project Structure

```
cpecafe/
├── app/                          # Flutter Mobile App
│   ├── lib/
│   │   ├── screens/
│   │   │   └── mainscreen.dart
│   │   └── main.dart
│   ├── assets/
│   │   ├── images/
│   │   └── icon/
│   └── pubspec.yaml
│
└── backend/                      # PHP Backend
    ├── index.php                 # Admin Dashboard
    ├── get_products.php          # GET - fetch all products
    ├── process_order.php         # POST - process order + deduct stock
    ├── add_product.php           # POST - add new product
    ├── update_stock.php          # POST - manual stock update
    ├── get_sales_report.php      # GET - sales analytics
    └── config/
        ├── dbcon.php             # Database connection
        └── cpecafe.sql           # Database schema + sample data
```

---

## Database Schema

**Database name:** `cpecafe`

| Table | Key Fields |
|---|---|
| products | id, name, category, large_price, small_price, stock, image |
| orders | id, total, created_at |
| order_items | order_id, product_id, quantity, size, price |

### Menu Categories

FRAPPE NON-COFFEE, FRAPPUCCINO, CHEESECAKE, MILKTEA, AMERIKANO, and more — 85+ products total.

---

## Backend API Reference

Base URL: `http://localhost/cpecafe`

| Endpoint | Method | Description |
|---|---|---|
| `/get_products.php` | GET | Fetch all products with stock levels |
| `/process_order.php` | POST | Process order + auto stock deduction |
| `/add_product.php` | POST | Add new menu item |
| `/update_stock.php` | POST | Manually update product stock |
| `/get_sales_report.php` | GET | Sales stats, top products, daily trends |

All endpoints return JSON. CORS headers are enabled for cross-origin requests.

### Order Processing Flow

```
POST /process_order.php
Body: { items: [{ product_id, quantity, size, price }], total }

1. BEGIN MySQL Transaction
2. INSERT into orders (total)
3. For each item:
   ├── Check stock >= quantity
   ├── INSERT into order_items
   └── UPDATE products.stock -= quantity
4. COMMIT
Response: { success: true, order_id: 123 }
```

### Stock Status Levels

| Status | Condition | Color |
|---|---|---|
| LOW | stock <= 10 | Red |
| MEDIUM | stock <= 20 | Orange |
| GOOD | stock > 20 | Green |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio or VS Code with Flutter extensions
- XAMPP (PHP + MySQL)

### Mobile App Setup

```bash
cd app
flutter pub get
flutter run
```

Update the API base URL in your service/config file to point to your backend:
```dart
const String baseUrl = 'http://YOUR_SERVER_IP/cpecafe';
```

### Backend Setup

1. Start XAMPP and make sure Apache and MySQL are running
2. Copy the `backend/` folder to `C:/xampp/htdocs/cpecafe/`
3. Open phpMyAdmin and create a database named `cpecafe`
4. Import `config/cpecafe.sql`
5. Access admin dashboard at `http://localhost/cpecafe/`

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  hive_flutter: ^1.1.0
  http: ^1.5.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  flutter_launcher_icons: ^0.14.4
```

---

## Color Palette

| Token | Hex | Usage |
|---|---|---|
| Primary Brown | `#8B4513` | Buttons, headers, accents |
| Background | `#FFFFFF` | App background |

---

## Roadmap

- [ ] Authentication for admin and cashier roles
- [ ] Input sanitization and XSS protection
- [ ] HTTPS support
- [ ] Receipt generation / printing
- [ ] Order history per cashier
- [ ] Dark mode
