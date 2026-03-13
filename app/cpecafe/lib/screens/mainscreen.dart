import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<OrderItem> cart = [];

  // Make this method accessible to child widgets
  void navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _screens => [
    OrderingScreen(
      cart: cart,
      onCartUpdate: (updatedCart) {
        setState(() {
          cart = updatedCart;
        });
      },
      onNavigateToCart: () => navigateToTab(1),
    ),
    CartScreen(
      cart: cart,
      onCartUpdate: (updatedCart) {
        setState(() {
          cart = updatedCart;
        });
      },
    ),
    InventoryScreen(),
    SalesReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CPE Cafe'),
        centerTitle: true,
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.info, color: Colors.white),
          onPressed: _showAboutDialog,
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF8B4513),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.shopping_cart),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '${cart.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('About'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            Text('Developers:'),
            SizedBox(height: 10),
            Text('Canlas, Adrian S.'),
            Text('Cayabyab, Matt Julius M.'),
            Text('Deang, Ronnel O.'),
            Text('Digman, Christian D.'),
            Text('Paragas, John Ian Joseph M.'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String category;
  final double grandePrice;
  final double ventiPrice;
  final int stock;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.grandePrice,
    required this.ventiPrice,
    required this.stock,
    required this.image,
  });

  // Helper method to generate image path based on product name and category
  static String _generateImagePath(String name, String category) {
    // Convert to lowercase and replace spaces with underscores
    String cleanName = name.toLowerCase().replaceAll(' ', '_');
    String cleanCategory = category.toLowerCase().replaceAll(' ', '_');

    // Generate path based on category and name
    return 'assets/images/${cleanName}_$cleanCategory.png';
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    String name = json['name'];
    String category = json['category'];

    return Product(
      id: int.parse(json['id'].toString()),
      name: name,
      category: category,
      grandePrice: double.parse(json['large_price'].toString()),
      ventiPrice: double.parse(json['small_price'].toString()),
      stock: int.parse(json['stock'].toString()),
      image: _generateImagePath(name, category),
    );
  }
}

class OrderItem {
  final Product product;
  final String size;
  int quantity;

  OrderItem({
    required this.product,
    required this.size,
    required this.quantity,
  });

  double get totalPrice {
    double unitPrice = size == 'Venti' ? product.ventiPrice : product.grandePrice;
    return unitPrice * quantity;
  }

  double get unitPrice {
    return size == 'Venti' ? product.ventiPrice : product.grandePrice;
  }
}

class OrderingScreen extends StatefulWidget {
  final List<OrderItem> cart;
  final Function(List<OrderItem>) onCartUpdate;
  final VoidCallback onNavigateToCart;

  OrderingScreen({required this.cart, required this.onCartUpdate, required this.onNavigateToCart});

  @override
  _OrderingScreenState createState() => _OrderingScreenState();
}

class _OrderingScreenState extends State<OrderingScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  Map<String, List<Product>> categorizedProducts = {};
  bool isLoading = true;
  String selectedCategory = 'All';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
    searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterProducts() {
    setState(() {
      String query = searchController.text.toLowerCase();
      if (query.isEmpty) {
        filteredProducts = selectedCategory == 'All'
            ? products
            : categorizedProducts[selectedCategory] ?? [];
      } else {
        List<Product> baseProducts = selectedCategory == 'All'
            ? products
            : categorizedProducts[selectedCategory] ?? [];
        filteredProducts = baseProducts
            .where((product) => product.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> loadProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://cpecafe.shop/get_products.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            products = (data['products'] as List)
                .map((item) => Product.fromJson(item))
                .toList();
            categorizeProducts();
            _filterProducts();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to load products: $e');
    }
  }

  void categorizeProducts() {
    categorizedProducts = {'All': products};
    for (var product in products) {
      if (!categorizedProducts.containsKey(product.category)) {
        categorizedProducts[product.category] = [];
      }
      categorizedProducts[product.category]!.add(product);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: TextStyle(color: Color(0xFF8B4513))),
        content: Text(message),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF8B4513))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
        ),
      );
    }

    return Column(
      children: [
        // Header with Search Bar and Cart
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: widget.onNavigateToCart,
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF8B4513),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                        ),
                        if (widget.cart.isNotEmpty)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${widget.cart.length}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Category Chips
              Container(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categorizedProducts.keys.map((category) {
                    bool isSelected = selectedCategory == category;
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = category;
                            _filterProducts();
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xFF8B4513),
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF8B4513),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Best Selling Section
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Best Cafe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.more_horiz, color: Color(0xFF8B4513)),
            ],
          ),
        ),

        // Products Grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 14),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return ModernProductCard(
                product: product,
                onTap: () => _showProductDetail(product),
                onAddToCart: (orderItem) {
                  if (product.stock <= 0) {
                    _showErrorDialog('${product.name} is out of stock!');
                    return;
                  }

                  List<OrderItem> updatedCart = List.from(widget.cart);
                  int existingIndex = updatedCart.indexWhere((item) =>
                  item.product.id == orderItem.product.id &&
                      item.size == orderItem.size);

                  if (existingIndex != -1) {
                    updatedCart[existingIndex].quantity += orderItem.quantity;
                  } else {
                    updatedCart.add(orderItem);
                  }

                  widget.onCartUpdate(updatedCart);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showProductDetail(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailSheet(
        product: product,
        onAddToCart: (orderItem) {
          if (product.stock <= 0) {
            _showErrorDialog('${product.name} is out of stock!');
            return;
          }

          List<OrderItem> updatedCart = List.from(widget.cart);
          int existingIndex = updatedCart.indexWhere((item) =>
          item.product.id == orderItem.product.id &&
              item.size == orderItem.size);

          if (existingIndex != -1) {
            updatedCart[existingIndex].quantity += orderItem.quantity;
          } else {
            updatedCart.add(orderItem);
          }

          widget.onCartUpdate(updatedCart);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class ModernProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final Function(OrderItem) onAddToCart;

  ModernProductCard({
    required this.product,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: AssetImage(product.image),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Fallback to default image if specific image not found
                    },
                  ),
                ),
                child: product.stock <= 0
                    ? Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Text(
                      'OUT OF STOCK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                    : null,
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₱${product.grandePrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Color(0xFF8B4513),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: product.stock <= 0 ? null : () => _showSizeSelection(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8B4513),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Add',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSizeSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Size', style: TextStyle(color: Color(0xFF8B4513))),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Grande - ₱${product.grandePrice.toStringAsFixed(2)}',
                  style: TextStyle(color: Color(0xFF8B4513))),
              onTap: () {
                Navigator.pop(context);
                onAddToCart(OrderItem(
                  product: product,
                  size: 'Grande',
                  quantity: 1,
                ));
              },
            ),
            ListTile(
              title: Text('Venti - ₱${product.ventiPrice.toStringAsFixed(2)}',
                  style: TextStyle(color: Color(0xFF8B4513))),
              onTap: () {
                Navigator.pop(context);
                onAddToCart(OrderItem(
                  product: product,
                  size: 'Venti',
                  quantity: 1,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailSheet extends StatelessWidget {
  final Product product;
  final Function(OrderItem) onAddToCart;

  ProductDetailSheet({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Product Image
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(product.image),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Fallback to default image if specific image not found
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Product Name and Price
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '₱${product.grandePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Delicious ${product.name.toLowerCase()} made with premium ingredients. Perfect for any time of the day. Available in Grande and Venti sizes to suit your preference.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Stock Info
                  Row(
                    children: [
                      Icon(Icons.inventory_2, color: Color(0xFF8B4513), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Stock: ${product.stock} items',
                        style: TextStyle(
                          color: product.stock <= 10 ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Size Selection
                  Text(
                    'Select Size',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSizeButton(
                          context,
                          'Grande',
                          '₱${product.grandePrice.toStringAsFixed(2)}',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildSizeButton(
                          context,
                          'Venti',
                          '₱${product.ventiPrice.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSizeButton(BuildContext context, String size, String price) {
    return ElevatedButton(
      onPressed: product.stock <= 0 ? null : () {
        onAddToCart(OrderItem(
          product: product,
          size: size,
          quantity: 1,
        ));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
      ),
      child: Column(
        children: [
          Text(
            size,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final List<OrderItem> cart;
  final Function(List<OrderItem>) onCartUpdate;

  CartScreen({required this.cart, required this.onCartUpdate});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<void> _processOrder() async {
    if (widget.cart.isEmpty) {
      _showErrorDialog('Cart is empty!');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('https://cpecafe.shop/process_order.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'items': widget.cart.map((item) => {
            'product_id': item.product.id,
            'quantity': item.quantity,
            'size': item.size,
            'price': item.unitPrice,
          }).toList(),
          'total': widget.cart.fold(0.0, (sum, item) => sum + item.totalPrice),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          widget.onCartUpdate([]);
          _showSuccessDialog('Order processed successfully!');
        } else {
          _showErrorDialog(data['message'] ?? 'Failed to process order');
        }
      }
    } catch (e) {
      _showErrorDialog('Failed to process order: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: TextStyle(color: Color(0xFF8B4513))),
        content: Text(message),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF8B4513))),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success', style: TextStyle(color: Color(0xFF8B4513))),
        content: Text(message),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF8B4513))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cart.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add items to get started',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Group cart items by category
    Map<String, List<OrderItem>> categorizedItems = {};
    for (var item in widget.cart) {
      String category = item.product.category;
      if (!categorizedItems.containsKey(category)) {
        categorizedItems[category] = [];
      }
      categorizedItems[category]!.add(item);
    }

    double total = widget.cart.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: categorizedItems.length + categorizedItems.values.expand((items) => items).length,
            itemBuilder: (context, index) {
              // Calculate current position in the categorized structure
              int currentIndex = 0;

              for (String category in categorizedItems.keys) {
                // Category header
                if (index == currentIndex) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    margin: EdgeInsets.only(bottom: 8),
                    child: Text(
                      category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                }
                currentIndex++;

                // Category items
                List<OrderItem> categoryItems = categorizedItems[category]!;
                for (int i = 0; i < categoryItems.length; i++) {
                  if (index == currentIndex) {
                    final item = categoryItems[i];
                    final originalIndex = widget.cart.indexOf(item);

                    return Dismissible(
                      key: Key('${item.product.id}_${item.size}_$originalIndex'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      onDismissed: (direction) {
                        List<OrderItem> updatedCart = List.from(widget.cart);
                        updatedCart.removeAt(originalIndex);
                        widget.onCartUpdate(updatedCart);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Item removed from cart'),
                            backgroundColor: Color(0xFF8B4513),
                          ),
                        );
                      },
                      child: CartItemCard(
                        item: item,
                        onQuantityChanged: (newQuantity) {
                          List<OrderItem> updatedCart = List.from(widget.cart);
                          if (newQuantity <= 0) {
                            updatedCart.removeAt(originalIndex);
                          } else {
                            updatedCart[originalIndex].quantity = newQuantity;
                          }
                          widget.onCartUpdate(updatedCart);
                        },
                      ),
                    );
                  }
                  currentIndex++;
                }
              }

              return Container(); // Fallback
            },
          ),
        ),
        // Cart Summary and Checkout
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '₱${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _processOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CartItemCard extends StatelessWidget {
  final OrderItem item;
  final Function(int) onQuantityChanged;

  CartItemCard({required this.item, required this.onQuantityChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(item.product.image),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Fallback to default image if specific image not found
                  },
                ),
              ),
            ),
            SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Size: ${item.size}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₱${item.unitPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B4513),
                    ),
                  ),
                ],
              ),
            ),
            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => onQuantityChanged(item.quantity - 1),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.remove, size: 16),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => onQuantityChanged(item.quantity + 1),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Color(0xFF8B4513),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '₱${item.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://cpecafe.shop/get_products.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            products = (data['products'] as List)
                .map((item) => Product.fromJson(item))
                .toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateStock(int productId, int newStock) async {
    try {
      final response = await http.post(
        Uri.parse('https://cpecafe.shop/update_stock.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'product_id': productId,
          'stock': newStock,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _showSuccessDialog('Stock updated successfully!');
          loadProducts();
        } else {
          _showErrorDialog(data['message'] ?? 'Failed to update stock');
        }
      } else {
        _showErrorDialog('Server error occurred');
      }
    } catch (e) {
      _showErrorDialog('Failed to update stock: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: TextStyle(color: Color(0xFF8B4513))),
        content: Text(message),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF8B4513))),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success', style: TextStyle(color: Color(0xFF8B4513))),
        content: Text(message),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF8B4513))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(product.image),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    // Fallback to default image if specific image not found
                  },
                ),
              ),
            ),
            title: Text(product.name, style: TextStyle(color: Color(0xFF8B4513))),
            subtitle: Text('${product.category} • Stock: ${product.stock}',
                style: TextStyle(color: Color(0xFF8B4513).withOpacity(0.7))),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.stock <= 10 ? Colors.red :
                    product.stock <= 20 ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.stock <= 10 ? 'LOW' :
                    product.stock <= 20 ? 'MEDIUM' : 'GOOD',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_square, color: Color(0xFF8B4513)),
                  onPressed: () => _showStockUpdateDialog(product),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStockUpdateDialog(Product product) {
    TextEditingController controller = TextEditingController(
      text: product.stock.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock: ${product.name}',
            style: TextStyle(color: Color(0xFF8B4513))),
        backgroundColor: Colors.white,
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Stock Quantity',
            labelStyle: TextStyle(color: Color(0xFF8B4513)),
            helperText: 'Enter a value of 0 or greater',
            helperStyle: TextStyle(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8B4513)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8B4513), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              int? newStock = int.tryParse(controller.text);
              if (newStock == null) {
                _showErrorDialog('Please enter a valid number');
                return;
              }
              if (newStock < 0) {
                _showErrorDialog('Stock quantity cannot be negative.');
                return;
              }
              updateStock(product.id, newStock);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B4513),
              foregroundColor: Colors.white,
            ),
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}

class SalesReportScreen extends StatefulWidget {
  @override
  _SalesReportScreenState createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  Map<String, dynamic> salesData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSalesReport();
  }

  Future<void> loadSalesReport() async {
    try {
      final response = await http.get(
        Uri.parse('https://cpecafe.shop/get_sales_report.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            salesData = data;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Sales',
                  '₱${salesData['total_sales']?.toStringAsFixed(2) ?? '0.00'}',
                  Icons.attach_money,
                  Color(0xFF8B4513),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Orders',
                  '${salesData['total_orders'] ?? 0}',
                  Icons.shopping_cart,
                  Color(0xFF8B4513),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Recent Orders
          Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          SizedBox(height: 8),
          if (salesData['recent_orders'] != null)
            ...((salesData['recent_orders'] as List).map((order) => Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text('Order ${order['id']}',
                    style: TextStyle(color: Color(0xFF8B4513))),
                subtitle: Text('${order['created_at']}',
                    style: TextStyle(color: Color(0xFF8B4513).withOpacity(0.7))),
                trailing: Text('₱${double.parse(order['total']).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Color(0xFF8B4513),
                      fontWeight: FontWeight.bold,
                    )),
              ),
            )).toList()),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}