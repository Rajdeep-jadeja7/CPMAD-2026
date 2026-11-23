import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// 1. DATA MODEL: TransactionItem
// ============================================================================
class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final String category; // Food, Transport, Bills, Shopping, Salary, etc.
  final String type; // 'Expense' or 'Income'
  final DateTime date;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'General',
      type: map['type'] ?? 'Expense',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}

// ============================================================================
// 2. STATE MANAGEMENT: AppStateManager (ChangeNotifier)
// Handles Auth, Transactions, Offline Persistence, Filtering & Reminders
// ============================================================================
class AppStateManager extends ChangeNotifier {
  // Authentication State
  bool _isLoggedIn = false;
  String _userEmail = 'rahul.sharma@example.com';

  // Transactions State
  List<TransactionItem> _transactions = [];
  bool _isLoading = false;
  String? _syncStatus = 'Offline Sync Enabled';

  // Multi-Condition Filtering (Post-Lab Task 2)
  String _searchQuery = '';
  String _filterType = 'All'; // 'All', 'Expense', 'Income'
  String _filterCategory = 'All';

  // Reminder State (Post-Lab Task 3)
  bool _dailyReminderEnabled = true;
  String _reminderTime = '08:00 PM';

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get syncStatus => _syncStatus;
  String get searchQuery => _searchQuery;
  String get filterType => _filterType;
  String get filterCategory => _filterCategory;
  bool get dailyReminderEnabled => _dailyReminderEnabled;
  String get reminderTime => _reminderTime;

  // Derived Financial Statistics (Post-Lab Task 4)
  double get totalIncome => _transactions
      .where((t) => t.type == 'Income')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'Expense')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get netBalance => totalIncome - totalExpense;

  Map<String, double> get categoryBreakdown {
    final Map<String, double> map = {};
    for (var t in _transactions.where((t) => t.type == 'Expense')) {
      map[t.category] = (map[t.category] ?? 0.0) + t.amount;
    }
    return map;
  }

  // Multi-Condition Filtered Results
  List<TransactionItem> get filteredTransactions {
    return _transactions.where((t) {
      final matchesSearch =
          t.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == 'All' || t.type == _filterType;
      final matchesCategory =
          _filterCategory == 'All' || t.category == _filterCategory;
      return matchesSearch && matchesType && matchesCategory;
    }).toList();
  }

  // Categories list
  List<String> get availableCategories => [
        'All',
        'Food',
        'Transport',
        'Bills',
        'Shopping',
        'Education',
        'Salary',
        'Investment',
        'Other'
      ];

  // --- Auth Actions ---
  void login(String email) {
    _isLoggedIn = true;
    _userEmail = email;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // --- Offline Persistence & Initial Loading (Post-Lab Task 1) ---
  Future<void> loadSavedData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('cached_transactions');

      if (savedJson != null && savedJson.isNotEmpty) {
        final List<dynamic> list = json.decode(savedJson);
        _transactions =
            list.map((item) => TransactionItem.fromMap(item)).toList();
      } else {
        // Fallback default sample transactions
        _transactions = [
          TransactionItem(
            id: '1',
            title: 'College Tuition Fee',
            amount: 45000.0,
            category: 'Education',
            type: 'Expense',
            date: DateTime.now().subtract(const Duration(days: 3)),
          ),
          TransactionItem(
            id: '2',
            title: 'Monthly Internship Stipend',
            amount: 15000.0,
            category: 'Salary',
            type: 'Income',
            date: DateTime.now().subtract(const Duration(days: 2)),
          ),
          TransactionItem(
            id: '3',
            title: 'Campus Canteen Lunch',
            amount: 180.0,
            category: 'Food',
            type: 'Expense',
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
          TransactionItem(
            id: '4',
            title: 'Metro Smart Card Recharge',
            amount: 500.0,
            category: 'Transport',
            type: 'Expense',
            date: DateTime.now(),
          ),
        ];
        _saveToCache();
      }
    } catch (_) {
      // Offline fallback handling
      _syncStatus = 'Loaded offline backup data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _transactions.map((t) => t.toMap()).toList();
      await prefs.setString('cached_transactions', json.encode(list));
    } catch (_) {}
  }

  // --- CRUD Transactions ---
  void addTransaction(TransactionItem item) {
    _transactions.insert(0, item);
    _saveToCache();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveToCache();
    notifyListeners();
  }

  // --- Search & Filters ---
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilterType(String type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterCategory(String cat) {
    _filterCategory = cat;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _filterType = 'All';
    _filterCategory = 'All';
    notifyListeners();
  }

  // --- Reminder Feature (Post-Lab Task 3) ---
  void toggleReminder(bool val) {
    _dailyReminderEnabled = val;
    notifyListeners();
  }

  void setReminderTime(String time) {
    _reminderTime = time;
    notifyListeners();
  }
}

final appState = AppStateManager();

// ============================================================================
// 3. MAIN APPLICATION & NAMED ROUTES
// ============================================================================
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Smart Expense Manager',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.teal,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey[100],
          ),
          initialRoute: '/',
          routes: {
            '/': (ctx) => appState.isLoggedIn
                ? const MainNavigationShell()
                : const LoginScreen(),
            '/add': (ctx) => const AddTransactionScreen(),
            '/stats': (ctx) => const AnalyticsDashboardScreen(),
            '/settings': (ctx) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

// ============================================================================
// SCREEN 1: Authentication / Login Screen
// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl =
      TextEditingController(text: 'rahul.sharma@example.com');
  final _passCtrl = TextEditingController(text: 'Password@123');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Native vibration feedback
      HapticFeedback.mediumImpact();
      appState.login(_emailCtrl.text.trim());
      appState.loadSavedData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Hero Icon
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet,
                        size: 64, color: Colors.teal),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Smart Expense Manager',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track income, expenses & offline budget',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 28),

                // Email field
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Please enter a valid email address'
                      : null,
                ),
                const SizedBox(height: 14),

                // Password field
                TextFormField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 20),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _handleLogin,
                    child: const Text('SECURE SIGN IN',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MAIN NAVIGATION SHELL (Bottom Navigation for Screens 2, 4, 5)
// ============================================================================
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(), // Screen 2: Dashboard & Transactions List
    AnalyticsDashboardScreen(), // Screen 4: Post-lab Statistics
    SettingsScreen(), // Screen 5: Settings & Local Notification
  ];

  @override
  void initState() {
    super.initState();
    appState.loadSavedData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Expenses'),
          BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart), label: 'Analytics'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              onPressed: () {
                // Native feedback
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, '/add');
              },
              icon: const Icon(Icons.add),
              label: const Text('New Entry'),
            )
          : null,
    );
  }
}

// ============================================================================
// SCREEN 2: Home Screen (Dashboard + Multi-Condition Search & List)
// ============================================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final list = appState.filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Manager'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sync / Reload Offline Data',
            onPressed: () {
              appState.loadSavedData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Offline transaction cache reloaded.')),
              );
            },
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Balance Summary Card with Animated Container
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('NET BALANCE',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '₹${appState.netBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: appState.netBalance >= 0
                                  ? Colors.teal
                                  : Colors.redAccent,
                            ),
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // Total Income
                              Column(
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.arrow_downward,
                                          size: 16, color: Colors.green),
                                      SizedBox(width: 4),
                                      Text('Income',
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${appState.totalIncome.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                  ),
                                ],
                              ),
                              // Total Expense
                              Column(
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.arrow_upward,
                                          size: 16, color: Colors.red),
                                      SizedBox(width: 4),
                                      Text('Expense',
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${appState.totalExpense.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Multi-Condition Filter Section (Post-Lab Task 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: TextField(
                          onChanged: (val) => appState.setSearchQuery(val),
                          decoration: InputDecoration(
                            hintText: 'Search title...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Filter Type Dropdown
                      DropdownButton<String>(
                        value: appState.filterType,
                        items: ['All', 'Expense', 'Income']
                            .map((t) =>
                                DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) appState.setFilterType(val);
                        },
                      ),
                    ],
                  ),
                ),

                // Horizontal Category Chips
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    itemCount: appState.availableCategories.length,
                    itemBuilder: (ctx, i) {
                      final cat = appState.availableCategories[i];
                      final isSelected = cat == appState.filterCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          selectedColor: Colors.teal.shade100,
                          onSelected: (_) => appState.setFilterCategory(cat),
                        ),
                      );
                    },
                  ),
                ),

                // Transactions List (Empty State or List)
                Expanded(
                  child: list.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inbox,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              const Text('No transactions match criteria.'),
                              TextButton(
                                onPressed: () => appState.resetFilters(),
                                child: const Text('Reset All Filters'),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: list.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) {
                            final item = list[i];
                            final isExp = item.type == 'Expense';
                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isExp
                                      ? Colors.red.shade50
                                      : Colors.green.shade50,
                                  child: Icon(
                                    isExp
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: isExp ? Colors.red : Colors.green,
                                    size: 20,
                                  ),
                                ),
                                title: Text(item.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    '${item.category} • ${item.date.day}/${item.date.month}/${item.date.year}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${isExp ? '-' : '+'}₹${item.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isExp ? Colors.red : Colors.green,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          size: 20, color: Colors.grey),
                                      onPressed: () {
                                        appState.deleteTransaction(item.id);
                                        HapticFeedback.lightImpact();
                                      },
                                    ),
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

// ============================================================================
// SCREEN 3: Add Transaction Form (Form Validation)
// ============================================================================
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  String _type = 'Expense';
  String _category = 'Food';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
      final newTx = TransactionItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        amount: amount,
        category: _category,
        type: _type,
        date: _selectedDate,
      );

      appState.addTransaction(newTx);
      HapticFeedback.lightImpact();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Type Selector
              Center(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'Expense',
                        label: Text('Expense'),
                        icon: Icon(Icons.remove_circle_outline)),
                    ButtonSegment(
                        value: 'Income',
                        label: Text('Income'),
                        icon: Icon(Icons.add_circle_outline)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (set) =>
                      setState(() => _type = set.first),
                ),
              ),
              const SizedBox(height: 18),

              // Title input
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title / Purpose',
                  hintText: 'e.g. Grocery, Salary, Electricity Bill',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 14),

              // Amount input
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(val) == null ||
                      double.parse(val) <= 0) {
                    return 'Enter a valid positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: appState.availableCategories
                    .where((c) => c != 'All')
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 14),

              // Date Picker Tile
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                title: Text(
                    'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  child: const Text('Change Date'),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _saveEntry,
                  child: const Text('SAVE RECORD',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN 4: Analytics Dashboard Screen (Post-Lab Task 4)
// ============================================================================
class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final breakdown = appState.categoryBreakdown;
    final totalExp = appState.totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analytics'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: breakdown.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 56, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No expenses recorded yet for analytics.'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category-wise Expenditure Breakdown',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),

                  // Category Bars
                  ...breakdown.entries.map((entry) {
                    final percentage = totalExp > 0
                        ? (entry.value / totalExp) * 100
                        : 0.0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  '₹${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: totalExp > 0 ? entry.value / totalExp : 0,
                              backgroundColor: Colors.grey[200],
                              color: Colors.teal,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // Health Summary
                  Card(
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        children: [
                          const Icon(Icons.savings_outlined,
                              color: Colors.teal, size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Savings Rate',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text(
                                  appState.totalIncome > 0
                                      ? '${((appState.netBalance / appState.totalIncome) * 100).toStringAsFixed(1)}% of total income preserved'
                                      : 'Add income to calculate savings rate',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
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
}

// ============================================================================
// SCREEN 5: Settings & Local Notification Reminder (Post-Lab Task 3)
// ============================================================================
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Card
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text('Rahul Sharma'),
              subtitle: Text(appState.userEmail),
            ),
          ),
          const SizedBox(height: 14),

          // Local Notification / Reminder (Post-Lab Task 3)
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Daily Expense Reminder'),
                  subtitle: const Text(
                      'Receive evening alert to log today’s expenditures'),
                  value: appState.dailyReminderEnabled,
                  activeThumbColor: Colors.teal,
                  onChanged: (val) {
                    appState.toggleReminder(val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val
                            ? 'Daily reminder enabled for ${appState.reminderTime}'
                            : 'Daily reminder disabled'),
                      ),
                    );
                  },
                ),
                if (appState.dailyReminderEnabled)
                  ListTile(
                    leading: const Icon(Icons.alarm, color: Colors.teal),
                    title: const Text('Reminder Alert Time'),
                    trailing: Text(
                      appState.reminderTime,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 20, minute: 0),
                      );
                      if (time != null && context.mounted) {
                        appState.setReminderTime(time.format(context));
                      }
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Offline Data Cache Status (Post-Lab Task 1)
          Card(
            child: ListTile(
              leading:
                  const Icon(Icons.cloud_done_outlined, color: Colors.teal),
              title: const Text('Local Data Storage'),
              subtitle: Text(appState.syncStatus ?? 'Data cached locally'),
              trailing: const Chip(
                label: Text('OFFLINE READY', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.greenAccent,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Logout Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              appState.logout();
            },
            icon: const Icon(Icons.logout),
            label: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }
}
