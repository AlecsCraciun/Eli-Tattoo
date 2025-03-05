import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'qr_scanner_screen.dart';

class VoucherTrackerScreen extends StatefulWidget {
  final String title;
  final double latitude;
  final double longitude;
  final int value;

  const VoucherTrackerScreen({
    Key? key,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.value,
  }) : super(key: key);

  @override
  _VoucherTrackerScreenState createState() => _VoucherTrackerScreenState();
}

class _VoucherTrackerScreenState extends State<VoucherTrackerScreen> {
  Position? _currentPosition;
  double _distance = double.infinity;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _getCurrentLocation();
  }

  void _initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);
  }

  void _showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'treasure_hunt', 'Treasure Hunt',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      '🎉 Ești aproape de un voucher!',
      'Mai ai doar ${_distance.toStringAsFixed(2)} metri până la premiu!',
      notificationDetails,
    );
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _currentPosition = position;
      _updateDistance();
    });
  }

  void _updateDistance() {
    if (_currentPosition == null) return;
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      widget.latitude,
      widget.longitude,
    );
    setState(() {
      _distance = distance;
    });

    if (_distance <= 50) {
      _showNotification();
    }
  }

  Color _getIndicatorColor() {
    if (_distance > 50) return Colors.red;
    if (_distance > 40) return Colors.orange;
    if (_distance > 30) return Colors.yellow;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🔹 Fundal luxury
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔹 Card cu informații despre voucher
                GlassContainer(
                  borderRadius: BorderRadius.circular(15),
                  blur: 10,
                  border: Border.all(width: 1, color: Colors.white.withOpacity(0.3)),
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.07)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.location_on, color: Colors.amber, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          "📍 Distanță până la voucher:",
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        Text(
                          "${_distance.toStringAsFixed(2)} metri",
                          style: const TextStyle(fontSize: 22, color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Indicator de distanță (cerc colorat)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getIndicatorColor(),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${_distance.toStringAsFixed(1)}m",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 Buton scanare QR
                ElevatedButton.icon(
                  onPressed: _distance <= 1
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRScannerScreen(),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.black),
                  label: const Text("📸 Scanează Codul QR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _distance <= 1 ? Colors.amber : Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
