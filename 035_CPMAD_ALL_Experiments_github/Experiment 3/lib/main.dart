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
      title: 'Experiment 3 - Student Registration App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const MainHomeScreen(),
    );
  }
}

// Simple Bottom Navigation to switch between Main Registration, Login, and Feedback
class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    StudentRegistrationScreen(),
    LoginScreen(),
    FeedbackScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Register'),
          BottomNavigationBarItem(icon: Icon(Icons.login), label: 'Login'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Feedback'),
        ],
      ),
    );
  }
}

// ====================================================================
// 1. MAIN TASK: STUDENT REGISTRATION FORM
// Form, TextField, TextEditingController, Radio, Checkbox, Slider, Switch, Validation, Display Submitted Data
// ====================================================================
class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  // Form Key for Validation
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Radio state: Gender
  String _gender = 'Male';

  // Checkbox state: Courses/Skills
  bool _flutter = true;
  bool _python = false;
  bool _java = false;

  // Slider state: Age / Experience
  double _age = 20;

  // Switch state: Preferences
  bool _hostelNeeded = false;

  // To display submitted details
  Map<String, dynamic>? _submittedData;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Collect selected skills
      List<String> skills = [];
      if (_flutter) skills.add('Flutter');
      if (_python) skills.add('Python');
      if (_java) skills.add('Java');

      setState(() {
        _submittedData = {
          'Name': _nameController.text,
          'Email': _emailController.text,
          'Phone': _phoneController.text,
          'Gender': _gender,
          'Skills': skills.isEmpty ? 'None' : skills.join(', '),
          'Age': _age.round(),
          'Hostel': _hostelNeeded ? 'Yes' : 'No',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Registration'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 12),

              // 2. Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter email';
                  if (!val.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 3. Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter phone number';
                  if (val.length < 10) return 'Phone must be at least 10 digits';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // 4. Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter password';
                  if (val.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 5. Gender Selection (Radio Buttons)
              const Text('Gender:', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio<String>(
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (val) => setState(() => _gender = val!),
                  ),
                  const Text('Male'),
                  Radio<String>(
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (val) => setState(() => _gender = val!),
                  ),
                  const Text('Female'),
                ],
              ),
              const Divider(),

              // 6. Courses/Skills Selection (Checkboxes)
              const Text('Select Courses / Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Checkbox(
                    value: _flutter,
                    onChanged: (val) => setState(() => _flutter = val!),
                  ),
                  const Text('Flutter'),
                  Checkbox(
                    value: _python,
                    onChanged: (val) => setState(() => _python = val!),
                  ),
                  const Text('Python'),
                  Checkbox(
                    value: _java,
                    onChanged: (val) => setState(() => _java = val!),
                  ),
                  const Text('Java'),
                ],
              ),
              const Divider(),

              // 7. Age Selection (Slider)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Age:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${_age.round()} Years', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                ],
              ),
              Slider(
                value: _age,
                min: 16,
                max: 30,
                divisions: 14,
                label: _age.round().toString(),
                onChanged: (val) => setState(() => _age = val),
              ),
              const Divider(),

              // 8. Additional Preferences (Switch)
              SwitchListTile(
                title: const Text('Require Hostel Accommodation?', style: TextStyle(fontWeight: FontWeight.bold)),
                value: _hostelNeeded,
                onChanged: (val) => setState(() => _hostelNeeded = val),
              ),
              const SizedBox(height: 12),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _submitForm,
                  child: const Text('SUBMIT REGISTRATION', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),

              // 9. Display Submitted Information
              if (_submittedData != null) ...[
                Card(
                  color: Colors.indigo.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Submitted Student Information:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                        const Divider(),
                        Text('Name: ${_submittedData!['Name']}'),
                        Text('Email: ${_submittedData!['Email']}'),
                        Text('Phone: ${_submittedData!['Phone']}'),
                        Text('Gender: ${_submittedData!['Gender']}'),
                        Text('Skills: ${_submittedData!['Skills']}'),
                        Text('Age: ${_submittedData!['Age']}'),
                        Text('Hostel: ${_submittedData!['Hostel']}'),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// 2. POST-LAB TASK 1: LOGIN SCREEN
// Email & Password validation with appropriate error messages
// ====================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  String _message = '';

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_loginKey.currentState!.validate()) {
      setState(() {
        _message = 'Login Successful for ${_loginEmailController.text}!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _loginKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _loginEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Email is required';
                  if (!val.contains('@')) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _loginPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Password is required';
                  if (val.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _login,
                  child: const Text('LOGIN'),
                ),
              ),
              const SizedBox(height: 16),
              if (_message.isNotEmpty)
                Text(
                  _message,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// 3. POST-LAB TASK 2: FEEDBACK APPLICATION
// Rating, comments, category, and recommendation fields
// ====================================================================
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _commentController = TextEditingController();
  int _selectedRating = 4;
  String _category = 'Course Content';
  bool _wouldRecommend = true;
  String _status = '';

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_commentController.text.isEmpty) {
      setState(() => _status = 'Please write a comment');
      return;
    }
    setState(() {
      _status = 'Thank you! Submitted $_selectedRating/5 stars for $_category.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Form'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Dropdown
            const Text('Category:', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _category,
              isExpanded: true,
              items: ['Course Content', 'Teaching Quality', 'Lab Facilities']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 16),

            // Interactive Clickable Star Rating (Clean & Comfortable)
            const Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                ...List.generate(5, (index) {
                  final starValue = index + 1;
                  return IconButton(
                    iconSize: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      starValue <= _selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedRating = starValue;
                      });
                    },
                  );
                }),
                const SizedBox(width: 12),
                Text(
                  '$_selectedRating / 5 Stars',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recommendation Switch
            SwitchListTile(
              title: const Text('Would you recommend this course?'),
              value: _wouldRecommend,
              onChanged: (val) => setState(() => _wouldRecommend = val),
            ),
            const SizedBox(height: 12),

            // Comments TextField
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comments',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitFeedback,
                child: const Text('SUBMIT FEEDBACK'),
              ),
            ),
            const SizedBox(height: 16),
            if (_status.isNotEmpty)
              Text(
                _status,
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
