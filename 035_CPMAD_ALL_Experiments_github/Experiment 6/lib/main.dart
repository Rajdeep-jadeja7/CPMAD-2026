import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// -------------------------------------------------------------
// PRODUCT MODEL
// -------------------------------------------------------------
class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final IconData icon;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.icon,
  });
}

final List<Product> catalog = [
  const Product(
    id: 'p1',
    name: 'Wireless Headphones',
    price: 2499,
    description: 'Noise-cancelling high bass wireless Bluetooth headphones.',
    icon: Icons.headphones,
  ),
  const Product(
    id: 'p2',
    name: 'Smart Watch',
    price: 3999,
    description: 'Fitness tracker with AMOLED display and heart rate sensor.',
    icon: Icons.watch,
  ),
  const Product(
    id: 'p3',
    name: 'Gaming Mouse',
    price: 1299,
    description: 'RGB ergonomic high precision optical gaming mouse.',
    icon: Icons.mouse,
  ),
  const Product(
    id: 'p4',
    name: 'Portable Speaker',
    price: 1899,
    description: 'Waterproof stereo outdoor wireless Bluetooth speaker.',
    icon: Icons.speaker,
  ),
];

// -------------------------------------------------------------
// APP ENTRY POINT WITH BLUE THEME (NO PURPLE)
// -------------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Animated Product App',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const ProductCatalogueScreen(),
    );
  }
}

// -------------------------------------------------------------
// 1. PRODUCT CATALOGUE SCREEN
// Features: AnimatedContainer, Hero, AnimationController & Tween,
// Animated Favorite Button, and Custom Page Transition
// -------------------------------------------------------------
class ProductCatalogueScreen extends StatefulWidget {
  const ProductCatalogueScreen({super.key});

  @override
  State<ProductCatalogueScreen> createState() => _ProductCatalogueScreenState();
}

class _ProductCatalogueScreenState extends State<ProductCatalogueScreen>
    with SingleTickerProviderStateMixin {
  // Requirement: AnimationController and Tween for Banner Pulse Animation
  late AnimationController _bannerController;
  late Animation<double> _scaleAnimation;

  // Track expanded card for AnimatedContainer
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    // Requirement: AnimationController with Tween & Curves
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _bannerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  // Requirement: Custom Page Transition (Slide & Fade)
  Route _createCustomRoute(Product product) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ProductDetailsScreen(product: product),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic));

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Product Catalog'),
        actions: [
          // Navigates to Post-Lab 1 (Animated Login Screen)
          IconButton(
            icon: const Icon(Icons.login),
            tooltip: 'Animated Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnimatedLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner using AnimationController & ScaleTransition (Tween + Curve)
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Tap cards to expand | Double-tap for details',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),

          // Product List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: catalog.length,
              itemBuilder: (context, index) {
                final product = catalog[index];
                final isSelected = _selectedProductId == product.id;

                // Requirement: Animate product cards using AnimatedContainer
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProductId = isSelected ? null : product.id;
                    });
                  },
                  onDoubleTap: () {
                    // Navigate using Custom Page Transition
                    Navigator.push(context, _createCustomRoute(product));
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.fastOutSlowIn, // Requirement: Animation Curve
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade100 : Colors.white,
                      borderRadius: BorderRadius.circular(isSelected ? 16 : 8),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? Colors.blue.withValues(alpha: 0.2) : Colors.black12,
                          blurRadius: isSelected ? 8 : 3,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Requirement: Hero Animation on Product Icon
                        Hero(
                          tag: product.id,
                          child: CircleAvatar(
                            radius: isSelected ? 30 : 25,
                            backgroundColor: Colors.blue.shade50,
                            child: Icon(product.icon, size: isSelected ? 32 : 26, color: Colors.blue),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 6),
                                Text(
                                  product.description,
                                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Requirement: Animated Favorite Button
                        const AnimatedFavoriteButton(),
                      ],
                    ),
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
// REUSABLE: ANIMATED FAVORITE BUTTON (Scale + Color Animation)
// -------------------------------------------------------------
class AnimatedFavoriteButton extends StatefulWidget {
  const AnimatedFavoriteButton({super.key});

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton> {
  bool _isFav = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isFav = !_isFav),
      child: AnimatedScale(
        scale: _isFav ? 1.25 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.elasticOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(6),
          child: Icon(
            _isFav ? Icons.favorite : Icons.favorite_border,
            color: _isFav ? Colors.red : Colors.grey,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. PRODUCT DETAILS SCREEN (Hero Animation & Add to Cart Animation)
// Post-Lab Task 2: Animation when product is added to cart
// -------------------------------------------------------------
class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _cartController;
  late Animation<double> _cartScaleAnimation;
  bool _isAdded = false;

  @override
  void initState() {
    super.initState();
    _cartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _cartScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _cartController, curve: Curves.bounceOut),
    );
  }

  @override
  void dispose() {
    _cartController.dispose();
    super.dispose();
  }

  void _addToCart() {
    setState(() => _isAdded = true);
    _cartController.forward().then((_) => _cartController.reverse());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.product.name} added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Requirement: Hero Animation matching catalog tag
            Hero(
              tag: widget.product.id,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.product.icon, size: 70, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${widget.product.price.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 16),
            Text(
              widget.product.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const Spacer(),

            // Post-Lab Task 2: Animation when product is added to cart
            ScaleTransition(
              scale: _cartScaleAnimation,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAdded ? Colors.green : Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: Icon(_isAdded ? Icons.check_circle : Icons.shopping_cart),
                  label: Text(_isAdded ? 'Added to Cart' : 'Add to Cart'),
                  onPressed: _addToCart,
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
// POST-LAB TASK 1: ANIMATED LOGIN SCREEN
// Form elements appear sequentially (Slide & Fade stagger)
// -------------------------------------------------------------
class AnimatedLoginScreen extends StatefulWidget {
  const AnimatedLoginScreen({super.key});

  @override
  State<AnimatedLoginScreen> createState() => _AnimatedLoginScreenState();
}

class _AnimatedLoginScreenState extends State<AnimatedLoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _loginController;
  late Animation<double> _titleAnim;
  late Animation<double> _emailAnim;
  late Animation<double> _passAnim;
  late Animation<double> _btnAnim;

  @override
  void initState() {
    super.initState();
    _loginController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Sequential intervals for form elements
    _titleAnim = CurvedAnimation(
      parent: _loginController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _emailAnim = CurvedAnimation(
      parent: _loginController,
      curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
    );
    _passAnim = CurvedAnimation(
      parent: _loginController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
    );
    _btnAnim = CurvedAnimation(
      parent: _loginController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    );

    _loginController.forward();
  }

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  Widget _buildStaggeredItem({required Animation<double> animation, required Widget child}) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStaggeredItem(
              animation: _titleAnim,
              child: const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            _buildStaggeredItem(
              animation: _emailAnim,
              child: const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildStaggeredItem(
              animation: _passAnim,
              child: const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildStaggeredItem(
              animation: _btnAnim,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login button tapped!')),
                    );
                  },
                  child: const Text('LOGIN'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
