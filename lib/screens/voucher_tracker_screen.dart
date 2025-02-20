import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'qr_scanner_screen.dart';

class VoucherTrackerScreen extends StatefulWidget {
  final String title;
  final double latitude;
  final double longitude;
  final int value; // ✅ Adăugat value

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
    if (_distance > 40) return Colors.redAccent;
    if (_distance > 30) return Colors.orange;
    if (_distance > 20) return Colors.orangeAccent;
    if (_distance > 10) return Colors.yellow;
    if (_distance > 5) return Colors.green;
    return Colors.greenAccent.shade700;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "📍 Distanță până la voucher: ${_distance.toStringAsFixed(2)} metri",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 20),
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
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
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
                child: Text("📸 Scanează Codul QR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _distance <= 1 ? Colors.green : Colors.grey.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
