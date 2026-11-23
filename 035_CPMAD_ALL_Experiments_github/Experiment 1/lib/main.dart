import 'package:flutter/material.dart';

// -------------------------------------------------------------
// STUDENT CLASS (OOP, Properties, Methods, Result Calculation)
// -------------------------------------------------------------
class Student {
  String name;
  String rollNo;
  Map<String, double> marks;

  Student({required this.name, required this.rollNo, required this.marks});

  double calculateTotal() {
    double total = 0.0;
    for (var m in marks.values) {
      total += m;
    }
    return total;
  }

  double calculatePercentage() {
    return calculateTotal() / 5;
  }

  String calculateGrade() {
    double p = calculatePercentage();
    if (p >= 80) return 'A';
    if (p >= 60) return 'B';
    if (p >= 40) return 'C';
    return 'Fail';
  }
}

void main() {
  runApp(const StudentResultApp());
}

class StudentResultApp extends StatelessWidget {
  const StudentResultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Result & Utility Calculator'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Result'),
              Tab(text: 'Salary'),
              Tab(text: 'Number'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ResultTab(),
            SalaryTab(),
            NumberTab(),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 1: Student Result Calculator (Main Requirement)
// -------------------------------------------------------------
class ResultTab extends StatefulWidget {
  const ResultTab({super.key});

  @override
  State<ResultTab> createState() => _ResultTabState();
}

class _ResultTabState extends State<ResultTab> {
  final _nameCtrl = TextEditingController(text: 'Rahul');
  final _rollCtrl = TextEditingController(text: '101');
  final List<TextEditingController> _controllers =
      List.generate(5, (_) => TextEditingController(text: '70'));

  bool _loading = false;
  Student? _student;

  Future<void> _calculateResult() async {
    setState(() => _loading = true);

    // Simulate async loading
    await Future.delayed(const Duration(seconds: 1));

    Map<String, double> subjectMarks = {};
    for (int i = 0; i < 5; i++) {
      subjectMarks['Subject ${i + 1}'] =
          double.tryParse(_controllers[i].text) ?? 0.0;
    }

    setState(() {
      _student = Student(
        name: _nameCtrl.text,
        rollNo: _rollCtrl.text,
        marks: subjectMarks,
      );
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rollCtrl.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Student Name'),
          ),
          TextField(
            controller: _rollCtrl,
            decoration: const InputDecoration(labelText: 'Roll Number'),
          ),
          const SizedBox(height: 12),
          const Text('Enter 5 Subject Marks:'),
          for (int i = 0; i < 5; i++)
            TextField(
              controller: _controllers[i],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Subject ${i + 1} Marks'),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _calculateResult,
            child: Text(_loading ? 'Calculating...' : 'Calculate Result'),
          ),
          const SizedBox(height: 16),
          if (_student != null) ...[
            Text('Name: ${_student!.name}'),
            Text('Roll No: ${_student!.rollNo}'),
            Text('Total Marks: ${_student!.calculateTotal()} / 500'),
            Text(
                'Percentage: ${_student!.calculatePercentage().toStringAsFixed(1)}%'),
            Text('Grade: ${_student!.calculateGrade()}'),
          ],
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 2: Post-Lab Task 1 (Employee Salary Calculator)
// -------------------------------------------------------------
class SalaryTab extends StatefulWidget {
  const SalaryTab({super.key});

  @override
  State<SalaryTab> createState() => _SalaryTabState();
}

class _SalaryTabState extends State<SalaryTab> {
  final _basicCtrl = TextEditingController(text: '30000');
  double _hra = 0, _da = 0, _pf = 0, _tax = 0, _net = 0;

  void _calculate() {
    double basic = double.tryParse(_basicCtrl.text) ?? 0.0;
    setState(() {
      _hra = basic * 0.20;
      _da = basic * 0.10;
      _pf = basic * 0.12;
      _tax = basic * 0.05;
      _net = (basic + _hra + _da) - (_pf + _tax);
    });
  }

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _basicCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _basicCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Basic Salary'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _calculate,
            child: const Text('Calculate Salary'),
          ),
          const SizedBox(height: 16),
          Text('Allowances: HRA = $_hra, DA = $_da'),
          Text('Deductions: PF = $_pf, Tax = $_tax'),
          Text('Net Salary = $_net',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 3: Post-Lab Task 2 (Number Properties Checker)
// -------------------------------------------------------------
class NumberTab extends StatefulWidget {
  const NumberTab({super.key});

  @override
  State<NumberTab> createState() => _NumberTabState();
}

class _NumberTabState extends State<NumberTab> {
  final _numCtrl = TextEditingController(text: '153');
  String _evenOdd = '', _prime = '', _palindrome = '', _armstrong = '';

  void _checkNumber() {
    int n = int.tryParse(_numCtrl.text) ?? 0;

    // Even / Odd
    String evenOdd = (n % 2 == 0) ? 'Even' : 'Odd';

    // Prime
    bool isPrime = n > 1;
    for (int i = 2; i * i <= n; i++) {
      if (n % i == 0) {
        isPrime = false;
        break;
      }
    }

    // Palindrome
    String s = n.abs().toString();
    bool isPal = s == s.split('').reversed.join('');

    // Armstrong
    int temp = n.abs(), sum = 0, digits = s.length;
    while (temp > 0) {
      int r = temp % 10;
      int p = 1;
      for (int i = 0; i < digits; i++) {
        p *= r;
      }
      sum += p;
      temp ~/= 10;
    }
    bool isArm = (sum == n.abs());

    setState(() {
      _evenOdd = evenOdd;
      _prime = isPrime ? 'Prime' : 'Not Prime';
      _palindrome = isPal ? 'Palindrome' : 'Not Palindrome';
      _armstrong = isArm ? 'Armstrong' : 'Not Armstrong';
    });
  }

  @override
  void initState() {
    super.initState();
    _checkNumber();
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _numCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter an Integer'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _checkNumber,
            child: const Text('Check Number'),
          ),
          const SizedBox(height: 16),
          Text('Even/Odd: $_evenOdd'),
          Text('Prime Check: $_prime'),
          Text('Palindrome Check: $_palindrome'),
          Text('Armstrong Check: $_armstrong'),
        ],
      ),
    );
  }
}
