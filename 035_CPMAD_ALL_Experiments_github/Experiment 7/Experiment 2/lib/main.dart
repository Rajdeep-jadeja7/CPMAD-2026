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
      // Application theme with customized colors and text styles
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// Simple Bottom Navigation to switch between Main Task and the 2 Post-Lab Tasks
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DeveloperProfileScreen(),
    StudentProfileScreen(),
    DepartmentInfoScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Developer'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Student'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Department'),
        ],
      ),
    );
  }
}

// ==============================================================
// 1. MAIN TASK: DEVELOPER PROFILE SCREEN
// ==============================================================
class DeveloperProfileScreen extends StatelessWidget {
  const DeveloperProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header Card: Profile Image, Name, Qualification
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.indigo, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/developer.png',
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Rahul Sharma',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'B.Tech in Computer Engineering',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Responsive Metrics Row using Expanded and Flexible
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: const [
                            Icon(Icons.work, color: Colors.indigo),
                            Text('1+ Year', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Experience', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: const [
                            Icon(Icons.code, color: Colors.teal),
                            Text('10+ Apps', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Projects', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: const [
                            Icon(Icons.star, color: Colors.orange),
                            Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Rating', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Skills using Reusable SkillWidget
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Skills',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          SkillWidget(skill: 'Flutter', icon: Icons.flutter_dash),
                          SkillWidget(skill: 'Dart', icon: Icons.code),
                          SkillWidget(skill: 'Firebase', icon: Icons.cloud),
                          SkillWidget(skill: 'Git', icon: Icons.source),
                          SkillWidget(skill: 'REST API', icon: Icons.http),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Contact Info using Reusable ContactWidget
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Contact Information',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      ContactWidget(icon: Icons.email, title: 'Email', value: 'rahul.sharma@example.com'),
                      ContactWidget(icon: Icons.phone, title: 'Phone', value: '+91 98765 43210'),
                      ContactWidget(icon: Icons.location_on, title: 'Location', value: 'Gujarat, India'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================
// 2. POST-LAB TASK 1: STUDENT PROFILE APPLICATION
// ==============================================================
class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green.shade700, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/student.png',
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Rahul Sharma',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Enrollment: 210120110035',
                        style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Department of Computer Engineering',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Academic Stats using Expanded & Flexible
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: const [
                            Icon(Icons.calendar_today, color: Colors.green),
                            Text('6th Sem', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Semester', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: const [
                            Icon(Icons.grade, color: Colors.green),
                            Text('8.85', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('CGPA', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.green),
                            Text('92%', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Attendance', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Academic Skills
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Courses & Grades',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          SkillWidget(skill: 'CPMAD (Flutter)', icon: Icons.phone_android),
                          SkillWidget(skill: 'Cloud Computing', icon: Icons.cloud),
                          SkillWidget(skill: 'Machine Learning', icon: Icons.psychology),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Contact Information
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Contact Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      ContactWidget(icon: Icons.email, title: 'College Email', value: 'rahul.student@college.edu.in'),
                      ContactWidget(icon: Icons.person, title: 'Faculty Mentor', value: 'Prof. A. K. Sharma'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================
// 3. POST-LAB TASK 2: DEPARTMENT INFORMATION SCREEN
// (Faculty, Courses, Facilities, Contact Information)
// ==============================================================
class DepartmentInfoScreen extends StatelessWidget {
  const DepartmentInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Information'),
        backgroundColor: Colors.purple.shade700,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.purple.shade700, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/department.png',
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Computer Engineering',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text('School of Technology', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 1. Faculty Section
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Faculty Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Divider(),
                      ContactWidget(icon: Icons.person, title: 'HOD', value: 'Dr. S. K. Patel (AI & Mobile)'),
                      ContactWidget(icon: Icons.person, title: 'Professor', value: 'Prof. A. K. Sharma (CPMAD)'),
                      ContactWidget(icon: Icons.person, title: 'Asst. Prof', value: 'Prof. N. M. Mehta (Cloud)'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Courses Section
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Courses Offered', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const Divider(),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          SkillWidget(skill: 'B.Tech CSE', icon: Icons.school),
                          SkillWidget(skill: 'B.Tech CPMAD', icon: Icons.phone_android),
                          SkillWidget(skill: 'M.Tech CSE', icon: Icons.workspace_premium),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Facilities Section
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Facilities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Divider(),
                      ContactWidget(icon: Icons.computer, title: 'Labs', value: '12 Computer Labs'),
                      ContactWidget(icon: Icons.devices, title: 'Special Lab', value: 'Apple iOS & Mobile Dev Lab'),
                      ContactWidget(icon: Icons.wifi, title: 'Network', value: 'High-speed Campus Wi-Fi & HPC'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Contact Information Section
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Divider(),
                      ContactWidget(icon: Icons.meeting_room, title: 'Office', value: 'Room 201, Block-C'),
                      ContactWidget(icon: Icons.email, title: 'Email', value: 'hod.ce@university.ac.in'),
                      ContactWidget(icon: Icons.phone, title: 'Phone', value: '+91 (0278) 2512345'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================
// REUSABLE WIDGET 1: SkillWidget
// ==============================================================
class SkillWidget extends StatelessWidget {
  final String skill;
  final IconData icon;

  const SkillWidget({super.key, required this.skill, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.indigo),
          const SizedBox(width: 6),
          Text(skill, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

// ==============================================================
// REUSABLE WIDGET 2: ContactWidget
// ==============================================================
class ContactWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ContactWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.indigo),
          const SizedBox(width: 10),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
