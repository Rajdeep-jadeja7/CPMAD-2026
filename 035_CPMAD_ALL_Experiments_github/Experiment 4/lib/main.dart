import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expense Manager',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const ExpenseManagerScreen(),
    );
  }
}

class ExpenseManagerScreen extends StatefulWidget {
  const ExpenseManagerScreen({super.key});

  @override
  State<ExpenseManagerScreen> createState() => _ExpenseManagerScreenState();
}

class _ExpenseManagerScreenState extends State<ExpenseManagerScreen> {
  // List to store transactions
  List<Map<String, dynamic>> _transactions = [];

  // Controllers for input form
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _type = 'Expense'; // 'Expense' or 'Income'
  String _category = 'Food';
  DateTime _selectedDate = DateTime.now();

  final List<String> _expenseCategories = ['Food', 'Transport', 'Bills', 'Shopping', 'Entertainment'];
  final List<String> _incomeCategories = ['Salary', 'Freelance', 'Allowance', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadTransactions(); // Load saved transactions on app start
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 1. LOCAL PERSISTENCE: Load from SharedPreferences
  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('transactions_data');
    if (dataString != null) {
      final List<dynamic> decodedList = jsonDecode(dataString);
      setState(() {
        _transactions = decodedList.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  // 2. LOCAL PERSISTENCE: Save to SharedPreferences
  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String dataString = jsonEncode(_transactions);
    await prefs.setString('transactions_data', dataString);
  }

  // 3. CRUD: Add or Edit Transaction
  void _openTransactionDialog({int? editIndex}) {
    final isEditing = editIndex != null;

    if (isEditing) {
      final item = _transactions[editIndex];
      _type = item['type'] ?? 'Expense';
      _amountController.text = item['amount'].toString();
      _descriptionController.text = item['description'];
      _category = item['category'];
      _selectedDate = DateTime.parse(item['date']);
    } else {
      _type = 'Expense';
      _amountController.clear();
      _descriptionController.clear();
      _category = 'Food';
      _selectedDate = DateTime.now();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final categoryList = _type == 'Expense' ? _expenseCategories : _incomeCategories;
            if (!categoryList.contains(_category)) {
              _category = categoryList.first;
            }

            return AlertDialog(
              title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Type Selection: Expense or Income
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Expense'),
                          selected: _type == 'Expense',
                          selectedColor: Colors.red.shade100,
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                _type = 'Expense';
                                _category = _expenseCategories.first;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Income'),
                          selected: _type == 'Income',
                          selectedColor: Colors.green.shade100,
                          onSelected: (val) {
                            if (val) {
                              setDialogState(() {
                                _type = 'Income';
                                _category = _incomeCategories.first;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Amount Field
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount (₹)',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: categoryList.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => _category = val!),
                    ),
                    const SizedBox(height: 12),

                    // Description Field
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.edit_note),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date Picker Tile
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today, color: Colors.teal),
                      title: Text(
                        'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: TextButton(
                        child: const Text('Change'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setDialogState(() => _selectedDate = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: () {
                    final double? amount = double.tryParse(_amountController.text);
                    if (amount == null || amount <= 0) return;

                    final item = {
                      'type': _type,
                      'amount': amount,
                      'category': _category,
                      'description': _descriptionController.text.trim().isEmpty ? _category : _descriptionController.text.trim(),
                      'date': _selectedDate.toIso8601String(),
                    };

                    setState(() {
                      if (isEditing) {
                        _transactions[editIndex] = item;
                      } else {
                        _transactions.insert(0, item);
                      }
                    });

                    _saveTransactions();
                    Navigator.pop(context);
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 4. CRUD: Delete Transaction
  void _deleteTransaction(int index) {
    setState(() {
      _transactions.removeAt(index);
    });
    _saveTransactions();
  }

  // Helper: Calculate Totals
  double get _totalIncome {
    return _transactions
        .where((t) => t['type'] == 'Income')
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
  }

  double get _totalExpense {
    return _transactions
        .where((t) => t['type'] == 'Expense')
        .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
  }

  double get _balance => _totalIncome - _totalExpense;

  // Helper: Get Category Breakdown & Highest Expense Category
  Map<String, double> get _categoryExpenses {
    final Map<String, double> map = {};
    for (var t in _transactions) {
      if (t['type'] == 'Expense') {
        final cat = t['category'] as String;
        final amt = (t['amount'] as num).toDouble();
        map[cat] = (map[cat] ?? 0.0) + amt;
      }
    }
    return map;
  }

  String get _highestExpenseCategory {
    final catMap = _categoryExpenses;
    if (catMap.isEmpty) return 'None';
    var highestCat = catMap.keys.first;
    for (var entry in catMap.entries) {
      if (entry.value > catMap[highestCat]!) {
        highestCat = entry.key;
      }
    }
    return '$highestCat (₹${catMap[highestCat]!.toStringAsFixed(0)})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Expense Manager'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 1. Summary Card: Total Income, Total Expense & Balance
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Income', '₹${_totalIncome.toStringAsFixed(0)}', Colors.green),
                      _buildSummaryItem('Expense', '₹${_totalExpense.toStringAsFixed(0)}', Colors.red),
                      _buildSummaryItem('Balance', '₹${_balance.toStringAsFixed(0)}', _balance >= 0 ? Colors.teal : Colors.red),
                    ],
                  ),
                  const Divider(height: 20),
                  // Highest Expense Category Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.trending_up, size: 18, color: Colors.deepOrange),
                      const SizedBox(width: 6),
                      Text(
                        'Highest Expense: $_highestExpenseCategory',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 2. Transactions List View (CRUD Display)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_transactions.length} items',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions yet!\nTap + below to add one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final item = _transactions[index];
                      final isExpense = item['type'] == 'Expense';
                      final DateTime date = DateTime.parse(item['date']);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isExpense ? Colors.red.shade50 : Colors.green.shade50,
                            child: Icon(
                              isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                              color: isExpense ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text(
                            item['description'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item['category']} • ${date.day}/${date.month}/${date.year}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${isExpense ? "-" : "+"}₹${(item['amount'] as num).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isExpense ? Colors.red : Colors.green,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                                onPressed: () => _openTransactionDialog(editIndex: index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                                onPressed: () => _deleteTransaction(index),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: () => _openTransactionDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
