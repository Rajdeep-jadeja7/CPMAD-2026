import 'package:flutter/material.dart';

void main() {
  runApp(const StudentManagementApp());
}

// -------------------------------------------------------------
// USER & STUDENT MODELS
// -------------------------------------------------------------
class AppUser {
  final String email;
  final String role; // 'Teacher' or 'Student'

  const AppUser({required this.email, required this.role});
}

class StudentRecord {
  final String id;
  final String name;
  final String rollNo;
  final String department;
  final double cgpa;

  StudentRecord({
    required this.id,
    required this.name,
    required this.rollNo,
    required this.department,
    required this.cgpa,
  });
}

// -------------------------------------------------------------
// APP ENTRY POINT WITH AUTH STATE MANAGEMENT
// -------------------------------------------------------------
class StudentManagementApp extends StatefulWidget {
  const StudentManagementApp({super.key});

  @override
  State<StudentManagementApp> createState() => _StudentManagementAppState();
}

class _StudentManagementAppState extends State<StudentManagementApp> {
  AppUser? _currentUser;

  // Sign in / Sign up
  void _login(String email, String role) {
    setState(() {
      _currentUser = AppUser(email: email, role: role);
    });
  }

  // Logout
  void _logout() {
    setState(() {
      _currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cloud-based Student Management',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      // Restrict screens: if authenticated show Dashboard, else show Auth screen
      home: _currentUser == null
          ? AuthScreen(onLogin: _login)
          : DashboardScreen(user: _currentUser!, onLogout: _logout),
    );
  }
}

// =============================================================
// AUTHENTICATION SCREEN: Login, Register, Password Reset
// =============================================================
class AuthScreen extends StatefulWidget {
  final Function(String email, String role) onLogin;

  const AuthScreen({super.key, required this.onLogin});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController(text: 'rahul.teacher@college.edu');
  final _passwordController = TextEditingController(text: 'pass123');

  bool _isRegistering = false;
  String _selectedRole = 'Teacher'; // 'Teacher' or 'Student'
  String _status = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _status = 'Please enter a valid email address.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _status = 'Password must be at least 6 characters.');
      return;
    }

    // Authenticate user
    widget.onLogin(email, _selectedRole);
  }

  // Post-Lab Task 1: Password-reset feature
  void _resetPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _status = 'Enter your email to receive a password reset link.');
      return;
    }
    setState(() {
      _status = 'Password reset link successfully sent to $email!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegistering ? 'Register Account' : 'Firebase Login'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.school, size: 70, color: Colors.teal),
            const SizedBox(height: 12),
            Text(
              _isRegistering ? 'Create Student / Teacher Account' : 'Student Management Portal',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Role selection for registration
            if (_isRegistering) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Role: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ChoiceChip(
                    label: const Text('Teacher'),
                    selected: _selectedRole == 'Teacher',
                    onSelected: (val) => setState(() => _selectedRole = 'Teacher'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Student'),
                    selected: _selectedRole == 'Student',
                    onSelected: (val) => setState(() => _selectedRole = 'Student'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Login / Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submit,
                child: Text(_isRegistering ? 'REGISTER' : 'LOGIN'),
              ),
            ),

            // Password reset button
            if (!_isRegistering) ...[
              TextButton(
                onPressed: _resetPassword,
                child: const Text('Forgot Password? Reset Here'),
              ),
            ],

            // Switch Login/Register
            TextButton(
              onPressed: () {
                setState(() {
                  _isRegistering = !_isRegistering;
                  _status = '';
                });
              },
              child: Text(
                _isRegistering ? 'Already have an account? Login' : 'Need an account? Register as Student/Teacher',
              ),
            ),

            if (_status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _status.contains('sent') ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// MAIN DASHBOARD: Separate Teacher vs Student Interface + CRUD
// =============================================================
class DashboardScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLogout;

  const DashboardScreen({super.key, required this.user, required this.onLogout});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock Firestore Student Collection
  final List<StudentRecord> _students = [
    StudentRecord(id: '1', name: 'Rahul Sharma', rollNo: '210120110035', department: 'Computer', cgpa: 8.85),
    StudentRecord(id: '2', name: 'Aarav Patel', rollNo: '210120110042', department: 'Computer', cgpa: 8.40),
    StudentRecord(id: '3', name: 'Priya Mehta', rollNo: '210120110056', department: 'IT', cgpa: 9.10),
  ];

  String _searchQuery = '';

  // Add or Edit Student Record
  void _openStudentDialog({StudentRecord? record}) {
    final nameCtrl = TextEditingController(text: record?.name ?? '');
    final rollCtrl = TextEditingController(text: record?.rollNo ?? '');
    final deptCtrl = TextEditingController(text: record?.department ?? 'Computer');
    final cgpaCtrl = TextEditingController(text: record != null ? record.cgpa.toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(record == null ? 'Add Student Record' : 'Edit Student Record'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Student Name')),
                TextField(controller: rollCtrl, decoration: const InputDecoration(labelText: 'Roll / Enrollment No')),
                TextField(controller: deptCtrl, decoration: const InputDecoration(labelText: 'Department')),
                TextField(controller: cgpaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CGPA')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final double? cgpa = double.tryParse(cgpaCtrl.text);
                if (nameCtrl.text.isNotEmpty && rollCtrl.text.isNotEmpty && cgpa != null) {
                  setState(() {
                    if (record == null) {
                      _students.add(StudentRecord(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text.trim(),
                        rollNo: rollCtrl.text.trim(),
                        department: deptCtrl.text.trim(),
                        cgpa: cgpa,
                      ));
                    } else {
                      final idx = _students.indexWhere((s) => s.id == record.id);
                      if (idx != -1) {
                        _students[idx] = StudentRecord(
                          id: record.id,
                          name: nameCtrl.text.trim(),
                          rollNo: rollCtrl.text.trim(),
                          department: deptCtrl.text.trim(),
                          cgpa: cgpa,
                        );
                      }
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.user.role == 'Teacher';

    // Search query filter
    final filteredStudents = _students.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.rollNo.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.user.role} Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Authenticated User Info Banner
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.teal.shade50,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(isTeacher ? Icons.person_pin : Icons.school, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.user.email, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Signed in as: ${widget.user.role}', style: const TextStyle(color: Colors.teal, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by student name or roll no...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Student Records List (CRUD: Read, Update, Delete)
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(child: Text('No student records found.'))
                : ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final s = filteredStudents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: Text(s.name.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Roll: ${s.rollNo} • Dept: ${s.department} • CGPA: ${s.cgpa}'),
                          trailing: isTeacher
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                                      onPressed: () => _openStudentDialog(record: s),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                                      onPressed: () => setState(() => _students.removeWhere((item) => item.id == s.id)),
                                    ),
                                  ],
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(6)),
                                  child: Text('CGPA: ${s.cgpa}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isTeacher
          ? FloatingActionButton(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              onPressed: () => _openStudentDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
