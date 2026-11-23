import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const DeviceUtilityApp());
}

// -------------------------------------------------------------
// APP ENTRY POINT
// -------------------------------------------------------------
class DeviceUtilityApp extends StatelessWidget {
  const DeviceUtilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mobile Device Utility App',
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
      home: const MainUtilityScreen(),
    );
  }
}

class MainUtilityScreen extends StatefulWidget {
  const MainUtilityScreen({super.key});

  @override
  State<MainUtilityScreen> createState() => _MainUtilityScreenState();
}

class _MainUtilityScreenState extends State<MainUtilityScreen> {
  int _tabIndex = 0;

  final List<Widget> _tabs = const [
    SensorsAndMediaScreen(),
    LocationHistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) => setState(() => _tabIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.perm_device_information), label: 'Sensors & Media'),
          BottomNavigationBarItem(icon: Icon(Icons.location_history), label: 'Location Log'),
        ],
      ),
    );
  }
}

// =============================================================
// SCREEN 1: CAMERA, GALLERY, PERMISSIONS & SENSORS
// =============================================================
class SensorsAndMediaScreen extends StatefulWidget {
  const SensorsAndMediaScreen({super.key});

  @override
  State<SensorsAndMediaScreen> createState() => _SensorsAndMediaScreenState();
}

class _SensorsAndMediaScreenState extends State<SensorsAndMediaScreen> {
  // Image Selection State (Simulating Camera & Gallery capture/selection)
  String? _selectedImageSource;

  // Runtime Permissions State
  bool _cameraPermission = true;
  bool _locationPermission = true;
  String _permissionMessage = '';

  // Accelerometer Sensor State
  double _sensorX = 0.12;
  double _sensorY = 9.81;
  double _sensorZ = 0.45;
  Timer? _sensorTimer;

  // Current GPS Location State
  double _latitude = 21.7645;
  double _longitude = 72.1519;
  String _locationStatus = 'Bhavnagar, Gujarat (GPS Active)';

  @override
  void initState() {
    super.initState();
    // Simulate dynamic accelerometer sensor stream
    _sensorTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted) {
        setState(() {
          _sensorX = double.parse((0.10 + (timer.tick % 5) * 0.08).toStringAsFixed(2));
          _sensorY = double.parse((9.75 + (timer.tick % 4) * 0.05).toStringAsFixed(2));
          _sensorZ = double.parse((0.40 + (timer.tick % 3) * 0.06).toStringAsFixed(2));
        });
      }
    });
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    super.dispose();
  }

  // Camera Capture Action
  void _captureFromCamera() {
    if (!_cameraPermission) {
      setState(() => _permissionMessage = 'Camera permission denied! Please enable it.');
      return;
    }
    setState(() {
      _selectedImageSource = 'Camera (Captured Photo)';
      _permissionMessage = '';
    });
  }

  // Gallery Select Action
  void _selectFromGallery() {
    setState(() {
      _selectedImageSource = 'Gallery (Selected from Album)';
      _permissionMessage = '';
    });
  }

  // Obtain GPS Location
  void _refreshGPSLocation() {
    if (!_locationPermission) {
      setState(() => _permissionMessage = 'GPS Location permission denied by user.');
      return;
    }
    setState(() {
      _latitude += 0.0002;
      _longitude += 0.0003;
      _locationStatus = 'Updated GPS Fix: Lat ${_latitude.toStringAsFixed(4)}, Long ${_longitude.toStringAsFixed(4)}';
      _permissionMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Utility & Sensors'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Profile Photo / Image Display & Replace
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Profile Photo (Camera & Gallery)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          _selectedImageSource == null ? Icons.person : Icons.photo_camera_front,
                          size: 60,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedImageSource ?? 'No custom photo selected',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _captureFromCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _selectFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Accelerometer Sensor Stream
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.sensors, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Accelerometer Sensor Stream', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _sensorValueBox('X-Axis', '$_sensorX m/s²'),
                        _sensorValueBox('Y-Axis', '$_sensorY m/s²'),
                        _sensorValueBox('Z-Axis', '$_sensorZ m/s²'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 3. GPS Location
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.my_location, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Current GPS Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.refresh, color: Colors.blue), onPressed: _refreshGPSLocation),
                      ],
                    ),
                    const Divider(),
                    Text('Status: $_locationStatus', style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Coordinates: ${_latitude.toStringAsFixed(4)}° N, ${_longitude.toStringAsFixed(4)}° E',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Runtime Permissions Simulation
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Runtime Permissions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Camera Permission'),
                      value: _cameraPermission,
                      onChanged: (val) => setState(() => _cameraPermission = val),
                    ),
                    SwitchListTile(
                      title: const Text('GPS Location Permission'),
                      value: _locationPermission,
                      onChanged: (val) => setState(() => _locationPermission = val),
                    ),
                    if (_permissionMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                        child: Text(_permissionMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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

  Widget _sensorValueBox(String axis, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(axis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }
}

// =============================================================
// SCREEN 2 (POST-LAB 2): RECORD LOCATIONS WITH TIMESTAMPS
// =============================================================
class LocationHistoryScreen extends StatefulWidget {
  const LocationHistoryScreen({super.key});

  @override
  State<LocationHistoryScreen> createState() => _LocationHistoryScreenState();
}

class _LocationHistoryScreenState extends State<LocationHistoryScreen> {
  final List<Map<String, String>> _locationLogs = [
    {
      'location': 'University Campus Library (21.7645° N, 72.1519° E)',
      'time': 'Today, 10:30 AM',
    },
    {
      'location': 'Computer Engineering Lab-201 (21.7648° N, 72.1522° E)',
      'time': 'Today, 12:15 PM',
    },
  ];

  void _recordCurrentLocation() {
    final now = DateTime.now();
    setState(() {
      _locationLogs.insert(0, {
        'location': 'Recorded GPS Point (21.7650° N, 72.1525° E)',
        'time': 'Today, ${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Timestamp Logger'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Record Current Location & Time'),
                onPressed: _recordCurrentLocation,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _locationLogs.length,
              itemBuilder: (context, index) {
                final log = _locationLogs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.place, color: Colors.white),
                    ),
                    title: Text(log['location']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: Text('Timestamp: ${log['time']}', style: const TextStyle(fontSize: 12)),
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
