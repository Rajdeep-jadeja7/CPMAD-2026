import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News & Media Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const MainTabScreen(),
    );
  }
}

// -------------------------------------------------------------
// MAIN TAB NAVIGATION (Dashboard, Profile, Travel)
// -------------------------------------------------------------
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    NewsDashboardScreen(),
    SliverProfileScreen(),
    TravelDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Travel'),
        ],
      ),
    );
  }
}

// =============================================================
// 1. MAIN TASK: NEWS / MEDIA DASHBOARD
// CustomScrollView, SliverAppBar (collapsing), RefreshIndicator,
// Featured Article (Stack), SliverGrid (Categories), SliverList (News Articles)
// =============================================================
class NewsDashboardScreen extends StatefulWidget {
  const NewsDashboardScreen({super.key});

  @override
  State<NewsDashboardScreen> createState() => _NewsDashboardScreenState();
}

class _NewsDashboardScreenState extends State<NewsDashboardScreen> {
  // Sample Data
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Technology', 'icon': Icons.computer, 'color': Colors.blue},
    {'name': 'Business', 'icon': Icons.trending_up, 'color': Colors.green},
    {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.orange},
    {'name': 'Science', 'icon': Icons.science, 'color': Colors.teal},
  ];

  List<String> _articles = [
    'Flutter 3 Released with Major Multi-Platform Performance Upgrades',
    'AI Models Transform Modern Mobile App Architecture and Workflows',
    'Global Tech Summit 2026: The Future of Cloud and Cross-Platform Apps',
    'Electric Vehicles Reach New Milestone in Renewable Battery Efficiency',
    'Space Mission Successfully Deploys Next-Gen Climate Tracking Satellite',
  ];

  // Pull-to-refresh action
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _articles.insert(0, 'Breaking: New Developer Framework Announced Today!');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Requirement: Pull-to-refresh behavior
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        // Requirement: CustomScrollView combining slivers
        slivers: [
          // Requirement: SliverAppBar (Collapsing Header)
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.indigo,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'News & Media Hub',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.public, size: 70, color: Colors.white24),
                ),
              ),
            ),
          ),

          // 1. Requirement: Featured Article section using Stack
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                elevation: 4,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    // Background Container
                    Container(
                      height: 160,
                      width: double.infinity,
                      color: Colors.indigo.shade800,
                      child: const Icon(Icons.newspaper, size: 80, color: Colors.white24),
                    ),
                    // Gradient Overlay & Overlay Text
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Revolutionizing Cross-Platform Mobile Architecture with Flutter',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Categories Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Explore Categories',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 2. Requirement: Category cards using SliverGrid (GridView in Slivers)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = _categories[index];
                  return Card(
                    color: (cat['color'] as Color).withValues(alpha: 0.12),
                    elevation: 1,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat['icon'], color: cat['color'], size: 22),
                          const SizedBox(width: 8),
                          Text(
                            cat['name'],
                            style: TextStyle(fontWeight: FontWeight.bold, color: cat['color']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _categories.length,
              ),
            ),
          ),

          // Latest News Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                'Latest News Articles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 3. Requirement: News articles using SliverList (ListView & ListTile)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final article = _articles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade50,
                      child: const Icon(Icons.article, color: Colors.indigo),
                    ),
                    title: Text(
                      article,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    subtitle: const Text('2 hours ago • Tech World', style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () {},
                  ),
                );
              },
              childCount: _articles.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

// =============================================================
// POST-LAB TASK 1: PROFILE SCREEN
// SliverAppBar and SliverGrid for user posts
// =============================================================
class SliverProfileScreen extends StatelessWidget {
  const SliverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // SliverAppBar with profile details
        SliverAppBar(
          expandedHeight: 190,
          pinned: true,
          backgroundColor: Colors.indigo,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Rahul Sharma', style: TextStyle(color: Colors.white, fontSize: 16)),
            background: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                SizedBox(height: 10),
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 45, color: Colors.indigo),
                ),
                SizedBox(height: 6),
                Text('Mobile Developer & Tech Enthusiast', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ),

        // User Stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _StatItem(count: '42', label: 'Posts'),
                _StatItem(count: '1.2k', label: 'Followers'),
                _StatItem(count: '350', label: 'Following'),
              ],
            ),
          ),
        ),

        // Posts Grid Header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text('Published Posts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),

        // Post-Lab 1 Requirement: SliverGrid for user posts
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.shade100),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo, color: Colors.indigo.shade400),
                      const SizedBox(height: 4),
                      Text('Post #${index + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
              childCount: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

// =============================================================
// POST-LAB TASK 2: TRAVEL DASHBOARD
// Featured locations (Stack), travel categories & destinations (SliverGrid/List)
// =============================================================
class TravelDashboardScreen extends StatelessWidget {
  const TravelDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['Mountains', 'Beaches', 'Historic', 'Forests'];
    final destinations = [
      {'title': 'Manali Highlands', 'state': 'Himachal Pradesh', 'rating': '4.8'},
      {'title': 'Goa Coastline', 'state': 'Goa', 'rating': '4.7'},
      {'title': 'Jaipur Heritage Fort', 'state': 'Rajasthan', 'rating': '4.9'},
      {'title': 'Gir National Park', 'state': 'Gujarat', 'rating': '4.6'},
    ];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 150,
          pinned: true,
          backgroundColor: Colors.teal,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Travel Explorer', style: TextStyle(color: Colors.white, fontSize: 16)),
            background: Container(
              color: Colors.teal.shade700,
              child: const Center(child: Icon(Icons.flight_takeoff, size: 60, color: Colors.white24)),
            ),
          ),
        ),

        // Featured Location (Stack)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Container(height: 140, color: Colors.teal.shade800),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('FEATURED DESTINATION', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('Rann of Kutch - White Desert', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Travel Categories
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Card(
                  color: Colors.teal.shade50,
                  child: Center(
                    child: Text(
                      categories[index],
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                    ),
                  ),
                );
              },
              childCount: categories.length,
            ),
          ),
        ),

        // Top Destinations List
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('Popular Destinations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final dest = destinations[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    child: const Icon(Icons.pin_drop, color: Colors.teal),
                  ),
                  title: Text(dest['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(dest['state']!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(' ${dest['rating']}'),
                    ],
                  ),
                ),
              );
            },
            childCount: destinations.length,
          ),
        ),
      ],
    );
  }
}
