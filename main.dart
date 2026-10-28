import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MalaysiaNavApp());
}

class MalaysiaNavApp extends StatelessWidget {
  const MalaysiaNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MY Nav - Waze Alternative',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapHomeScreen(),
    );
  }
}

class MapHomeScreen extends StatefulWidget {
  const MapHomeScreen({super.key});

  @override
  State<MapHomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<MapHomeScreen> {
  // ডামি নেভিগেশন স্টেট
  bool _isNavigating = false;
  String _currentRoute = "KLCC ➔ TRX (via SMART Tunnel)";
  double _estimatedTollRM = 3.00; // Touch 'n Go toll fee
  int _speedLimitKm h = 90;
  
  // ডামি AES স্পিড ক্যামেরা কোঅর্ডিনেট ডাটা
  final List<Map<String, String>> _aesCamerasList = [
    {"location": "PLUS Highway (KM 301.6 Northbound)", "limit": "110 km/h"},
    {"location": "MEX Highway (Salak Tinggi)", "limit": "90 km/h"},
    {"location": "LDP (Kelana Jaya)", "limit": "80 km/h"},
  ];

  void _triggerHazardReport(String type) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ Reported "$type" to nearby Malaysian drivers!'),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  void _showReportBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Report Hazard / Roadblock',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildReportItem(Icons.local_police, 'Police / Ops', Colors.blue),
                  _buildReportItem(Icons.camera_alt, 'AES Trap', Colors.red),
                  _buildReportItem(Icons.warning_amber, 'Traffic / Accident', Colors.amber),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportItem(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () => _triggerHazardReport(label),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('MY Nav', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Active AES Cameras Nearby'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _aesCamerasList
                        .map((cam) => ListTile(
                              leading: const Icon(Icons.camera_alt, color: Colors.red),
                              title: Text(cam["location"]!),
                              subtitle: Text('Limit: ${cam["limit"]}'),
                            ))
                        .toList(),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // ম্যাপ ব্যাকগ্রাউন্ড ভিউ (Placeholder)
          Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 100, color: Colors.indigoAccent),
                  SizedBox(height: 10),
                  Text('Mapbox Live View Area', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          ),

          // ওপরের কাস্টম রুট এবং টোল ইনফো ব্যানার
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car, color: Colors.indigo, size: 35),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_currentRoute, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('Est. Toll: RM ${_estimatedTollRM.toStringAsFixed(2)} (TnG / RFID)', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // নিচ থেকে কমিউনিটি রিপোর্ট বাটন
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton.extended(
              onPressed: _showReportBottomSheet,
              backgroundColor: Colors.deepOrange,
              icon: const Icon(Icons.add_location_alt, color: Colors.white),
              label: const Text('Report Hazard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
