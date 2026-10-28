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
  final String _currentRoute = "KLCC ➔ TRX (via SMART Tunnel)";
  final double _estimatedTollRM = 3.00;

  // মালয়েশিয়ার হাইওয়ের ডামি AES ক্যামেরা ও স্পিড লিমিট ডাটাবেস
  final List<Map<String, dynamic>> _aesCamerasList = [
    {"location": "PLUS Highway (KM 301.6 Northbound)", "limit": 110, "distanceKm": 0.4},
    {"location": "MEX Highway (Salak Tinggi)", "limit": 90, "distanceKm": 1.2},
    {"location": "LDP (Kelana Jaya)", "limit": 80, "distanceKm": 0.2}, // ক্লোজ প্রক্সিমিটি অ্যালার্ট ট্রিগার করার জন্য
  ];

  @override
  void initState() {
    super.initState();
    // অ্যাপ চালু হওয়ার সাথে সাথে কাছাকাছি স্পিড ক্যামেরা চেক করার লজিক
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNearbySpeedCameras();
    });
  }

  // প্রক্সিমিটি ও স্পিড ক্যামেরা অ্যালার্ট লজিক
  void _checkNearbySpeedCameras() {
    for (var cam in _aesCamerasList) {
      double distance = cam["distanceKm"];
      if (distance <= 0.5) {
        _showSpeedAlertPopup(cam["location"], cam["limit"], distance);
        break;
      }
    }
  }

  void _showSpeedAlertPopup(String location, int limit, double distance) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('AES Camera Ahead!', style: TextStyle(fontSize: 18, color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: $location', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Distance: ${(distance * 1000).toInt()} meters'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Speed Limit: $limit km/h\nPlease slow down!',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () => Navigator.pop(context),
            child: const Text('Acknowledged', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // কমিউনিটি রিপোর্ট ট্রিগার
  void _triggerHazardReport(String type) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('⚠️ Reported "$type" to nearby Malaysian drivers!'),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  // রিপোর্ট বটম শিট
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
                              subtitle: Text('Limit: ${cam["limit"]} km/h'),
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
          // ম্যাপ ব্যাকগ্রাউন্ড প্লেসহোল্ডার
          Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 100, color: Colors.indigoAccent),
                  SizedBox(height: 10),
                  Text('Mapbox Live View Area', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
          ),

          // রুট এবং টোল ইনফো ব্যানার
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

          // কমিউনিটি রিপোর্ট করার ফ্লোটিং বাটন
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
