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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('MY Nav', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // ক্লিন ম্যাপ ব্যাকগ্রাউন্ড প্লেসহোল্ডার
          Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 100, color: Colors.indigoAccent),
                  SizedBox(height: 10),
                  Text('Clean Map View - Ready for Custom Features', style: TextStyle(fontSize: 16, color: Colors.grey)),
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
        ],
      ),
    );
  }
}
