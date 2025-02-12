import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class VoucherTrackerScreen extends StatefulWidget {
  final double voucherLatitude;
  final double voucherLongitude;

  VoucherTrackerScreen({required this.voucherLatitude, required this.voucherLongitude});

  @override
  _VoucherTrackerScreenState createState() => _VoucherTrackerScreenState();
}

class _VoucherTrackerScreenState extends State<VoucherTrackerScreen> {
  Position? _currentPosition;
  double _distance = 1000; // Inițial, setăm o distanță mare
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    setState(() {
      _currentPosition = position;
      _distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.voucherLatitude,
        widget.voucherLongitude,
      );
    });
  }

  Color _getDistanceColor() {
    if (_distance <= 5) return Colors.green; // 5m - Verde
    if (_distance <= 10) return Colors.yellow; // 10m - Galben
    if (_distance <= 20) return Colors.orangeAccent; // 20m - Portocaliu deschis
    if (_distance <= 30) return Colors.orange; // 30m - Portocaliu
    if (_distance <= 40) return Colors.redAccent; // 40m - Roșu deschis
    return Colors.red; // Peste 50m - Roșu intens
  }

  String _getDistanceMessage() {
    if (_distance <= 5) return "📍 Ești extrem de aproape! Caută în jurul tău.";
    if (_distance <= 10) return "🔍 Aproape acolo! Mai ai doar câțiva metri.";
    if (_distance <= 20) return "📡 Ești la doar 20m distanță!";
    if (_distance <= 30) return "🧭 Ești la 30m! Mai aproape...";
    if (_distance <= 40) return "📶 Ești la 40m, continuă!";
    return "📍 Ești la ${_distance.toStringAsFixed(1)}m distanță.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tracker Voucher")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Distanța până la voucher:",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getDistanceColor(),
              ),
              child: Center(
                child: Text(
                  "${_distance.toStringAsFixed(1)}m",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _getDistanceMessage(),
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            if (_distance <= 1) // Afișează butonul doar dacă ești la 1m
              ElevatedButton(
                onPressed: () {
                  // Aici urmează implementarea pentru scanarea QR
                },
                child: Text("📸 Scanează codul QR"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
