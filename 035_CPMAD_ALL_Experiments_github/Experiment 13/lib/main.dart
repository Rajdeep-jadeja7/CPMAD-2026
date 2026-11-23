import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// -------------------------------------------------------------
// MODEL: Product
// -------------------------------------------------------------
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      image: json['image'] ?? 'https://via.placeholder.com/150',
      rating: (json['rating'] != null && json['rating']['rate'] != null)
          ? (json['rating']['rate'] as num).toDouble()
          : 4.0,
    );
  }
}

// -------------------------------------------------------------
// MODEL: Cart Item
// -------------------------------------------------------------
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get itemTotal => product.price * quantity;
}

// -------------------------------------------------------------
// STATE MANAGEMENT: AppStateManager (ChangeNotifier)
// Structured shared state for Cart, Wishlist, Compare, and Products
// -------------------------------------------------------------
class AppStateManager extends ChangeNotifier {
  // Products from REST API
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Search & Filter state
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Shared Cart State
  final Map<int, CartItem> _cart = {};

  // Shared Wishlist State (Post-Lab Task 1)
  final Set<int> _wishlistIds = {};

  // Shared Compare State (Post-Lab Task 2)
  final List<Product> _compareList = [];

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  List<CartItem> get cartItems => _cart.values.toList();
  List<Product> get compareList => _compareList;

  // Derived State: Total Quantity, Subtotal, Tax, Final Total
  int get totalCartCount {
    int count = 0;
    for (var item in _cart.values) {
      count += item.quantity;
    }
    return count;
  }

  double get subtotal {
    double sum = 0.0;
    for (var item in _cart.values) {
      sum += item.itemTotal;
    }
    return sum;
  }

  double get tax => subtotal * 0.05; // 5% GST/Tax
  double get grandTotal => subtotal + tax;

  // Available Categories (Derived dynamically)
  List<String> get categories {
    final set = {'All'};
    for (var p in _products) {
      set.add(p.category);
    }
    return set.toList();
  }

  // Filtered Products (Derived based on Search & Category)
  List<Product> get filteredProducts {
    return _products.where((item) {
      final matchesSearch =
          item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();
  }

  // --- API Fetching ---
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('https://fakestoreapi.com/products'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _products = data.map((json) => Product.fromJson(json)).toList();
      } else {
        _errorMessage = 'Server error: Status code ${response.statusCode}';
      }
    } catch (e) {
      // Fallback dummy products if offline or network timeout occurs
      _products = [
        Product(
          id: 1,
          title: 'Wireless Bluetooth Headphones',
          price: 59.99,
          description: 'High-fidelity audio with active noise cancellation.',
          category: 'electronics',
          image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300',
          rating: 4.5,
        ),
        Product(
          id: 2,
          title: 'Casual Cotton Crewneck T-Shirt',
          price: 19.99,
          description: '100% breathable organic cotton slim fit t-shirt.',
          category: "men's clothing",
          image: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=300',
          rating: 4.2,
        ),
        Product(
          id: 3,
          title: 'Stainless Steel Water Bottle',
          price: 14.50,
          description: 'Double insulated 750ml flask keeps beverages cold for 24h.',
          category: 'jewelery',
          image: 'https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=300',
          rating: 4.8,
        ),
        Product(
          id: 4,
          title: 'Classic Leather Running Sneakers',
          price: 79.00,
          description: 'Cushioned sole designed for marathon runners and casual walks.',
          category: "men's clothing",
          image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
          rating: 4.7,
        ),
      ];
      _errorMessage = 'Loaded offline sample catalog ($e)';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Search and Category Setters ---
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // --- Cart Actions ---
  void addToCart(Product product) {
    if (_cart.containsKey(product.id)) {
      _cart[product.id]!.quantity += 1;
    } else {
      _cart[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    if (_cart.containsKey(productId)) {
      if (_cart[productId]!.quantity > 1) {
        _cart[productId]!.quantity -= 1;
      } else {
        _cart.remove(productId);
      }
      notifyListeners();
    }
  }

  void deleteFromCart(int productId) {
    _cart.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  int getProductQuantityInCart(int productId) {
    return _cart[productId]?.quantity ?? 0;
  }

  // --- Wishlist Actions (Post-Lab Task 1) ---
  bool isInWishlist(int productId) => _wishlistIds.contains(productId);

  void toggleWishlist(int productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
  }

  List<Product> get wishlistProducts {
    return _products.where((p) => _wishlistIds.contains(p.id)).toList();
  }

  // --- Compare Actions (Post-Lab Task 2) ---
  bool isInCompare(int productId) =>
      _compareList.any((item) => item.id == productId);

  void toggleCompare(Product product) {
    if (isInCompare(product.id)) {
      _compareList.removeWhere((p) => p.id == product.id);
    } else {
      if (_compareList.length >= 4) {
        // limit comparison to 4 items for readability
        _compareList.removeAt(0);
      }
      _compareList.add(product);
    }
    notifyListeners();
  }

  void clearCompare() {
    _compareList.clear();
    notifyListeners();
  }
}

// Global App State Instance
final appState = AppStateManager();

// -------------------------------------------------------------
// MAIN ENTRY POINT
// -------------------------------------------------------------
void main() {
  runApp(const ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        return MaterialApp(
          title: 'API-Driven Shopping Cart',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            scaffoldBackgroundColor: Colors.grey[100],
          ),
          home: const MainCatalogueScreen(),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// SCREEN 1: Main Product Catalogue Screen
// -------------------------------------------------------------
class MainCatalogueScreen extends StatefulWidget {
  const MainCatalogueScreen({super.key});

  @override
  State<MainCatalogueScreen> createState() => _MainCatalogueScreenState();
}

class _MainCatalogueScreenState extends State<MainCatalogueScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    appState.fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = appState.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSmart Catalog'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Wishlist Action
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Wishlist',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
              );
            },
          ),
          // Compare Action
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.compare_arrows),
                tooltip: 'Compare Products',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CompareScreen()),
                  );
                },
              ),
              if (appState.compareList.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.amber,
                    child: Text(
                      '${appState.compareList.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Cart Action with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                tooltip: 'Shopping Cart',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              ),
              if (appState.totalCartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${appState.totalCartCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => appState.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search products by title...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          appState.setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Category Filter Chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: appState.categories.length,
              itemBuilder: (context, index) {
                final category = appState.categories[index];
                final isSelected = category == appState.selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      appState.setSelectedCategory(category);
                    },
                    selectedColor: Colors.indigo.shade100,
                    checkmarkColor: Colors.indigo,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.indigo : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Notification / Error banner if any
          if (appState.errorMessage != null)
            Container(
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appState.errorMessage!,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => appState.fetchProducts(),
                    child: const Text('RETRY', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          // Main Body: Loading / Error / Empty / Grid of Products
          Expanded(
            child: appState.isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Fetching latest products...'),
                      ],
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off,
                                size: 56, color: Colors.grey),
                            const SizedBox(height: 10),
                            const Text('No products found matching criteria.'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                                appState.setSearchQuery('');
                                appState.setSelectedCategory('All');
                              },
                              child: const Text('Reset Filters'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => appState.fetchProducts(),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return ProductCardWidget(product: filtered[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// REUSABLE WIDGET: Product Card
// -------------------------------------------------------------
class ProductCardWidget extends StatelessWidget {
  final Product product;

  const ProductCardWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isInWishlist = appState.isInWishlist(product.id);
    final isInCompare = appState.isInCompare(product.id);
    final inCartCount = appState.getProductQuantityInCart(product.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badges: Wishlist & Compare
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => appState.toggleCompare(product),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isInCompare
                          ? Colors.amber.shade200
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isInCompare ? 'COMPARING' : '+ COMPARE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isInCompare ? Colors.black87 : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => appState.toggleWishlist(product.id),
                  child: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Product Image
            Expanded(
              child: Center(
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Title
            Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),

            // Rating & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      product.rating.toString(),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Add To Cart Button
            SizedBox(
              width: double.infinity,
              height: 32,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      inCartCount > 0 ? Colors.green : Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  appState.addToCart(product);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added "${product.title}" to cart!'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: Icon(
                  inCartCount > 0 ? Icons.check : Icons.add_shopping_cart,
                  size: 16,
                ),
                label: Text(
                  inCartCount > 0 ? 'In Cart ($inCartCount)' : 'Add to Cart',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// SCREEN 2: Shopping Cart Screen (Derived State: Subtotal & Total)
// -------------------------------------------------------------
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = appState.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shopping Cart'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear Cart',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text(
                        'Are you sure you want to remove all items from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('CANCEL'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          appState.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: const Text('CLEAR'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.remove_shopping_cart_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Add some products from the catalog.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Browse Products'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Cart Items List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Image.network(
                                item.product.image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${item.product.price.toStringAsFixed(2)} each',
                                      style:
                                          TextStyle(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                              // Counter Controls
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline,
                                        size: 20),
                                    onPressed: () => appState
                                        .removeFromCart(item.product.id),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline,
                                        size: 20),
                                    onPressed: () =>
                                        appState.addToCart(item.product),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent, size: 20),
                                onPressed: () =>
                                    appState.deleteFromCart(item.product.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Order Summary Card (Derived State)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Items:'),
                          Text('${appState.totalCartCount}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:'),
                          Text('\$${appState.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('GST / Tax (5%):'),
                          Text('\$${appState.tax.toStringAsFixed(2)}'),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Grand Total:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${appState.grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order placed successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            appState.clearCart();
                            Navigator.pop(context);
                          },
                          child: const Text('CHECKOUT NOW'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// -------------------------------------------------------------
// POST-LAB TASK 1: Wishlist Screen
// -------------------------------------------------------------
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = appState.wishlistProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: wishlist.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Your wishlist is empty!'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Image.network(
                      product.image,
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                    title: Text(product.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart,
                              color: Colors.indigo),
                          onPressed: () {
                            appState.addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Moved ${product.title} to cart'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () =>
                              appState.toggleWishlist(product.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// -------------------------------------------------------------
// POST-LAB TASK 2: Product Comparison Screen
// -------------------------------------------------------------
class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final compareList = appState.compareList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Comparison'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          if (compareList.isNotEmpty)
            TextButton(
              onPressed: () => appState.clearCompare(),
              child: const Text('CLEAR ALL',
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: compareList.length < 2
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.compare_arrows,
                        size: 64, color: Colors.indigo),
                    const SizedBox(height: 12),
                    Text(
                      compareList.isEmpty
                          ? 'No products selected for comparison.'
                          : 'Please select at least one more product to compare attributes.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go to Catalog'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor:
                      WidgetStateProperty.all(Colors.indigo.shade50),
                  columns: [
                    const DataColumn(
                      label: Text('Feature',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...compareList.map(
                      (p) => DataColumn(
                        label: SizedBox(
                          width: 140,
                          child: Text(
                            p.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: [
                    // Row 1: Image
                    DataRow(
                      cells: [
                        const DataCell(Text('Preview')),
                        ...compareList.map(
                          (p) => DataCell(
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Image.network(p.image,
                                  width: 50, height: 50, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Row 2: Price
                    DataRow(
                      cells: [
                        const DataCell(Text('Price')),
                        ...compareList.map(
                          (p) => DataCell(
                            Text(
                              '\$${p.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Row 3: Rating
                    DataRow(
                      cells: [
                        const DataCell(Text('Rating')),
                        ...compareList.map(
                          (p) => DataCell(
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text('${p.rating} / 5.0'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Row 4: Category
                    DataRow(
                      cells: [
                        const DataCell(Text('Category')),
                        ...compareList.map(
                          (p) => DataCell(Text(p.category.toUpperCase())),
                        ),
                      ],
                    ),
                    // Row 5: Action
                    DataRow(
                      cells: [
                        const DataCell(Text('Action')),
                        ...compareList.map(
                          (p) => DataCell(
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                appState.addToCart(p);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added ${p.title} to cart'),
                                  ),
                                );
                              },
                              child: const Text('Add to Cart',
                                  style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
