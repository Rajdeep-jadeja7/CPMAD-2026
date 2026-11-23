import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MultilingualApp());
}

// -------------------------------------------------------------
// TRANSLATION STRINGS MAP (English, Hindi, Gujarati)
// -------------------------------------------------------------
final Map<String, Map<String, String>> appTranslations = {
  'en': {
    'title': 'Student Information',
    'lang_label': 'Language',
    'student_name': 'Rahul Sharma',
    'enrollment': 'Enrollment: 210120110035',
    'course': 'Course: B.Tech Computer Engineering',
    'fees_paid': 'Fees Paid',
    'admission_date': 'Admission Date',
    'attendance': 'Attendance',
    'save_btn': 'Save Information',
    'saved_msg': 'Student information saved successfully!',
    'calc_title': 'Multilingual Calculator',
    'num1': 'First Number',
    'num2': 'Second Number',
    'add': 'Add',
    'subtract': 'Subtract',
    'result': 'Result',
    'tab_student': 'Student',
    'tab_calc': 'Calculator',
  },
  'hi': {
    'title': 'छात्र सूचना पोर्टल',
    'lang_label': 'भाषा',
    'student_name': 'राहुल शर्मा',
    'enrollment': 'नामांकन: 210120110035',
    'course': 'पाठ्यक्रम: बी.टेक कंप्यूटर इंजीनियरिंग',
    'fees_paid': 'भुगतान की गई फीस',
    'admission_date': 'प्रवेश तिथि',
    'attendance': 'उपस्थिति',
    'save_btn': 'जानकारी सहेजें',
    'saved_msg': 'छात्र की जानकारी सफलतापूर्वक सहेजी गई!',
    'calc_title': 'बहुभाषी कैलकुलेटर',
    'num1': 'पहली संख्या',
    'num2': 'दूसरी संख्या',
    'add': 'जोड़ें',
    'subtract': 'घटाएं',
    'result': 'परिणाम',
    'tab_student': 'छात्र',
    'tab_calc': 'कैलकुलेटर',
  },
  'gu': {
    'title': 'વિદ્યાર્થી માહિતી પોર્ટલ',
    'lang_label': 'ભાષા',
    'student_name': 'રાહુલ શર્મા',
    'enrollment': 'નોંધણી નંબર: 210120110035',
    'course': 'અભ્યાસક્રમ: બી.ટેક કમ્પ્યુટર એન્જિનિયરિંગ',
    'fees_paid': 'ચૂકવેલ ફી',
    'admission_date': 'પ્રવેશ તારીખ',
    'attendance': 'હાજરી',
    'save_btn': 'માહિતી સાચવો',
    'saved_msg': 'વિદ્યાર્થીની માહિતી સફળતાપૂર્વક સચવાઈ ગઈ!',
    'calc_title': 'બહુભાષી કેલ્ક્યુલેટર',
    'num1': 'પ્રથમ નંબર',
    'num2': 'બીજો નંબર',
    'add': 'સરવાળો',
    'subtract': 'બાદબાકી',
    'result': 'પરિણામ',
    'tab_student': 'વિદ્યાર્થી',
    'tab_calc': 'કેલ્ક્યુલેટર',
  },
};

class MultilingualApp extends StatefulWidget {
  const MultilingualApp({super.key});

  @override
  State<MultilingualApp> createState() => _MultilingualAppState();
}

class _MultilingualAppState extends State<MultilingualApp> {
  String _currentLocale = 'en';

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage(); // Restore language preference on start
  }

  // Restore persisted language
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocale = prefs.getString('saved_lang') ?? 'en';
    });
  }

  // Change & Persist language
  Future<void> _changeLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_lang', langCode);
    setState(() {
      _currentLocale = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Multilingual Student App',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: MainNavigationScreen(
        currentLocale: _currentLocale,
        onLanguageChanged: _changeLanguage,
      ),
    );
  }
}

// -------------------------------------------------------------
// MAIN NAVIGATION (Student Info Screen & Calculator Screen)
// -------------------------------------------------------------
class MainNavigationScreen extends StatefulWidget {
  final String currentLocale;
  final Function(String) onLanguageChanged;

  const MainNavigationScreen({
    super.key,
    required this.currentLocale,
    required this.onLanguageChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = appTranslations[widget.currentLocale]!;

    final screens = [
      StudentInfoScreen(
        locale: widget.currentLocale,
        onLangChange: widget.onLanguageChanged,
      ),
      MultilingualCalculatorScreen(
        locale: widget.currentLocale,
      ),
    ];

    return Scaffold(
      body: screens[_tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        selectedItemColor: Colors.indigo,
        onTap: (index) => setState(() => _tabIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.school),
            label: t['tab_student']!,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calculate),
            label: t['tab_calc']!,
          ),
        ],
      ),
    );
  }
}

// =============================================================
// 1. MAIN TASK: STUDENT INFORMATION SCREEN
// Date/Number formatting, Locale switching, Persistence
// =============================================================
class StudentInfoScreen extends StatelessWidget {
  final String locale;
  final Function(String) onLangChange;

  const StudentInfoScreen({
    super.key,
    required this.locale,
    required this.onLangChange,
  });

  // Number and Date formatting helpers according to selected locale
  String _formatNumber(num value, String lang) {
    if (lang == 'hi') {
      return NumberFormat.currency(locale: 'hi_IN', symbol: '₹').format(value);
    } else if (lang == 'gu') {
      return NumberFormat.currency(locale: 'gu_IN', symbol: '₹').format(value);
    }
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(value);
  }

  String _formatDate(DateTime date, String lang) {
    if (lang == 'hi') {
      return DateFormat('dd MMMM yyyy', 'hi').format(date);
    } else if (lang == 'gu') {
      return DateFormat('dd MMMM yyyy', 'gu').format(date);
    }
    return DateFormat('dd MMMM yyyy', 'en').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final t = appTranslations[locale]!;
    final DateTime admissionDate = DateTime(2023, 8, 16);
    const double feesAmount = 75000.0;
    const double attendancePercent = 94.5;

    return Scaffold(
      appBar: AppBar(
        title: Text(t['title']!),
        actions: [
          // Language selector dropdown in AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButton<String>(
              dropdownColor: Colors.indigo,
              underline: const SizedBox(),
              value: locale,
              icon: const Icon(Icons.language, color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'hi', child: Text('हिंदी (Hindi)', style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'gu', child: Text('ગુજરાતી (Gujarati)', style: TextStyle(color: Colors.white))),
              ],
              onChanged: (val) {
                if (val != null) onLangChange(val);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Student Profile Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t['student_name']!,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(t['enrollment']!, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                    Text(t['course']!, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Localized Details Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildRow(Icons.calendar_today, t['admission_date']!, _formatDate(admissionDate, locale)),
                    const Divider(),
                    _buildRow(Icons.currency_rupee, t['fees_paid']!, _formatNumber(feesAmount, locale)),
                    const Divider(),
                    _buildRow(Icons.pie_chart, t['attendance']!, '$attendancePercent%'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Button with Localized Message
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.save),
                label: Text(t['save_btn']!),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t['saved_msg']!)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}

// =============================================================
// POST-LAB TASK 1: MULTILINGUAL CALCULATOR
// Labels, buttons, and messages adapt dynamically to selected language
// =============================================================
class MultilingualCalculatorScreen extends StatefulWidget {
  final String locale;

  const MultilingualCalculatorScreen({super.key, required this.locale});

  @override
  State<MultilingualCalculatorScreen> createState() => _MultilingualCalculatorScreenState();
}

class _MultilingualCalculatorScreenState extends State<MultilingualCalculatorScreen> {
  final _num1Controller = TextEditingController();
  final _num2Controller = TextEditingController();
  double? _result;

  @override
  void dispose() {
    _num1Controller.dispose();
    _num2Controller.dispose();
    super.dispose();
  }

  void _calculate(bool isAdd) {
    final double? n1 = double.tryParse(_num1Controller.text);
    final double? n2 = double.tryParse(_num2Controller.text);
    if (n1 == null || n2 == null) return;

    setState(() {
      _result = isAdd ? (n1 + n2) : (n1 - n2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = appTranslations[widget.locale]!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t['calc_title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _num1Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t['num1']!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _num2Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t['num2']!,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    onPressed: () => _calculate(true),
                    child: Text(t['add']!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    onPressed: () => _calculate(false),
                    child: Text(t['subtract']!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_result != null)
              Card(
                color: Colors.indigo.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${t['result']!}: ${_result!.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
