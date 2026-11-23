import 'package:flutter/material.dart';

void main() {
  runApp(const ShoppingApp());
}

// -------------------------------------------------------------
// PRODUCT MODEL
// -------------------------------------------------------------
class Product {
  final String name;
  final String category;
  final double price;
  final String description;
  final IconData icon;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.icon,
  });
}

// Global Cart List to hold added products
List<Product> cartItems = [];

// Sample Products
final List<Product> sampleProducts = [
  const Product(
    name: 'Wireless Headphones',
    category: 'Electronics',
    price: 2499.0,
    description: 'Noise-cancelling over-ear wireless Bluetooth headphones.',
    icon: Icons.headphones,
  ),
  const Product(
    name: 'Smart Watch',
    category: 'Electronics',
    price: 3999.0,
    description: 'Fitness tracker smart watch with heart rate sensor and AMOLED display.',
    icon: Icons.watch,
  ),
  const Product(
    name: 'Cotton T-Shirt',
    category: 'Clothing',
    price: 699.0,
    description: '100% pure combed organic cotton regular fit casual t-shirt.',
    icon: Icons.checkroom,
  ),
  const Product(
    name: 'Denim Jeans',
    category: 'Clothing',
    price: 1499.0,
    description: 'Classic durable stretchable denim jeans for daily comfort.',
    icon: Icons.shopping_bag,
  ),
];

// -------------------------------------------------------------
// APP ENTRY POINT WITH NAMED ROUTES
// -------------------------------------------------------------
class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping Application',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      // Initial Route
      initialRoute: '/',
      // Named Routes
      routes: {
        '/': (context) => const MainHomeScreen(),
        '/details': (context) => const ProductDetailsScreen(),
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}

// -------------------------------------------------------------
// 1. MAIN SCREEN WITH DRAWER & BOTTOM NAVIGATION BAR
// -------------------------------------------------------------
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentBottomIndex = 0;

  final List<Widget> _bottomScreens = const [
    HomeScreen(),
    ProductListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Application'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      // Requirement: Drawer for application navigation
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Rahul Sharma'),
              accountEmail: Text('rahul.sharma@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
              ),
              decoration: BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentBottomIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Products'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentBottomIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentBottomIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Cart'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/cart');
              },
            ),
          ],
        ),
      ),
      // Body displays selected section
      body: _bottomScreens[_currentBottomIndex],
      // Requirement: BottomNavigationBar for major application sections
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: (index) => setState(() => _currentBottomIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. HOME SCREEN (Banner & Featured Highlights)
// -------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Colors.deepPurple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: const [
                  Icon(Icons.local_offer, size: 48, color: Colors.deepPurple),
                  SizedBox(height: 8),
                  Text(
                    'Exclusive Mega Sale! Up to 50% Off',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Tap on Products below or in the menu to start shopping.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Featured Deals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: sampleProducts.length,
              itemBuilder: (context, index) {
                final p = sampleProducts[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade100,
                      child: Icon(p.icon, color: Colors.deepPurple),
                    ),
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('₹${p.price.toStringAsFixed(0)}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate passing route arguments
                      Navigator.pushNamed(context, '/details', arguments: p);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. PRODUCT LIST SCREEN (TabBar & TabBarView for Categories)
// -------------------------------------------------------------
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Requirement: TabBar and TabBarView for categories
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const Material(
            color: Colors.white,
            elevation: 1,
            child: TabBar(
              labelColor: Colors.deepPurple,
              indicatorColor: Colors.deepPurple,
              tabs: [
                Tab(icon: Icon(Icons.devices), text: 'Electronics'),
                Tab(icon: Icon(Icons.checkroom), text: 'Clothing'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCategoryList('Electronics'),
                _buildCategoryList('Clothing'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String category) {
    final filtered = sampleProducts.where((p) => p.category == category).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final product = filtered[index];

        // Requirement: Gestures for product interaction (Tap, LongPress)
        return GestureDetector(
          onTap: () {
            // Requirement: Passing product information using route arguments
            Navigator.pushNamed(context, '/details', arguments: product);
          },
          onLongPress: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Quick Preview: ${product.description}')),
            );
          },
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(product.icon, size: 32, color: Colors.deepPurple),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text(
                          product.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text('₹${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// 4. PRODUCT DETAILS SCREEN (Route Arguments & Add to Cart)
// -------------------------------------------------------------
class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Receiving Product object via route arguments
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(product.icon, size: 80, color: Colors.deepPurple),
            ),
            const SizedBox(height: 20),
            Text(
              product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${product.price.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 14),
            Text(
              product.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart & Checkout'),
                onPressed: () {
                  // Add to global cart list
                  cartItems.add(product);
                  // Pass object forward to Cart screen
                  Navigator.pushNamed(context, '/cart', arguments: product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 5. CART SCREEN (Displays Selected Products Flow)
// -------------------------------------------------------------
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = cartItems.fold(0.0, (sum, p) => sum + p.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty!'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: Icon(item.icon, color: Colors.deepPurple),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Category: ${item.category}'),
                          trailing: Text(
                            '₹${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('₹${total.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// -------------------------------------------------------------
// 6. PROFILE SCREEN
// -------------------------------------------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Rahul Sharma', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('rahul.sharma@example.com', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          const Card(
            child: ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text('+91 98765 43210'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Shipping Address'),
              subtitle: Text('Ahmedabad, Gujarat, India'),
            ),
          ),
        ],
      ),
    );
  }
}
