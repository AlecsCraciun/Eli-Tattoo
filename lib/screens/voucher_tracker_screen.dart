import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:math' as math;
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

class _VoucherTrackerScreenState extends State<VoucherTrackerScreen> with SingleTickerProviderStateMixin {
  Position? _currentPosition;
  double _distance = double.infinity;
  double _bearing = 0.0;
  double _direction = 0.0;
  bool _usingBeacon = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  DateTime? _lastFeedbackTime;
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  Stream<RangingResult>? _beaconStream;
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassStream;
  late final Region _region;
  final List<double> _distanceHistory = [];
  final int _filterWindowSize = 5;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initServices();
    _initAnimations();
  }

  Future<void> _initServices() async {
    await _initNotifications();
    await _initLocationTracking();
    await _initCompass();
    await _initBeacon();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviciile de localizare sunt dezactivate.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permisiunile de localizare sunt refuzate');
      }
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
        _updateDistanceAndBearing();
      });
    });
  }

  Future<void> _initCompass() async {
    _compassStream = FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        _direction = event.heading ?? 0;
      });
    });
  }

  Future<void> _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final settings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);
  }

  Future<void> _initBeacon() async {
    try {
      await flutterBeacon.initializeScanning;
      _region = Region(
        identifier: 'EliVoucher',
        proximityUUID: '13CC7F8DF0C84AAAA000AAAAAAAAAAAA',
      );

      _beaconStream = flutterBeacon.ranging([_region]);
      _beaconStream!.listen((RangingResult result) {
        if (result.beacons.isNotEmpty) {
          final beacon = result.beacons.first;
          final rawDistance = beacon.accuracy;
          
          if (_distance <= 50 && mounted) {
            _distanceHistory.add(rawDistance);
            if (_distanceHistory.length > _filterWindowSize) {
              _distanceHistory.removeAt(0);
            }
            final filteredDistance = _distanceHistory.reduce((a, b) => a + b) / _distanceHistory.length;
            
            setState(() {
              _usingBeacon = true;
              _distance = filteredDistance;
            });
            
            _provideFeedback();
          }
        }
      });
    } catch (e) {
      print('Eroare beacon: $e');
    }
  }

  void _updateDistanceAndBearing() {
    if (_currentPosition == null) return;
    
    final lat1 = _currentPosition!.latitude;
    final lon1 = _currentPosition!.longitude;
    final lat2 = widget.latitude;
    final lon2 = widget.longitude;
    
    final gpsDistance = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
    final bearing = _calculateBearing(lat1, lon1, lat2, lon2);
    
    setState(() {
      _bearing = bearing;
      if (!_usingBeacon || gpsDistance > 50) {
        _distance = gpsDistance;
        _usingBeacon = false;
      }
    });

    if (_distance <= 50 && !_usingBeacon) {
      _showNotification();
      _provideFeedback();
    }
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _toRadians(lon2 - lon1);
    final y = math.sin(dLon) * math.cos(_toRadians(lat2));
    final x = math.cos(_toRadians(lat1)) * math.sin(_toRadians(lat2)) -
        math.sin(_toRadians(lat1)) * math.cos(_toRadians(lat2)) * math.cos(dLon);
    return (_toDegrees(math.atan2(y, x)) + 360) % 360;
  }

  double _toRadians(double deg) => deg * math.pi / 180;
  double _toDegrees(double rad) => rad * 180 / math.pi;

  void _showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'treasure_hunt',
      'Treasure Hunt',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      '🎉 Ești aproape de un voucher!',
      'Mai ai doar ${_distance.toStringAsFixed(2)} metri!',
      notificationDetails,
    );
  }

  void _provideFeedback() async {
    if (_lastFeedbackTime != null && 
        DateTime.now().difference(_lastFeedbackTime!) < const Duration(seconds: 2)) {
      return;
    }
    
    _lastFeedbackTime = DateTime.now();

    if (_distance <= 50 && _distance > 30) {
      Vibration.vibrate(duration: 100, amplitude: 50);
      await _audioPlayer.play(AssetSource('sounds/far.mp3'));
    } else if (_distance <= 30 && _distance > 10) {
      Vibration.vibrate(duration: 200, amplitude: 128);
      await _audioPlayer.play(AssetSource('sounds/closer.mp3'));
    } else if (_distance <= 10) {
      Vibration.vibrate(pattern: [100, 100, 100, 100]);
      await _audioPlayer.play(AssetSource('sounds/very_close.mp3'));
    }
  }

  Color _getIndicatorColor() {
    if (_distance > 50) return Colors.red;
    if (_distance > 30) return Colors.orange;
    if (_distance > 10) return Colors.yellow;
    return Colors.green;
  }

  Widget _buildDistanceIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _distance <= 10 ? _pulseAnimation.value : 1.0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getIndicatorColor().withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getIndicatorColor().withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _usingBeacon ? Icons.bluetooth_searching : Icons.location_searching,
                  color: _getIndicatorColor(),
                  size: 40,
                ),
                const SizedBox(height: 15),
                Text(
                  _distance.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getIndicatorColor(),
                  ),
                ),
                const Text(
                  "metri",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompassArrow() {
    final rotationAngle = _direction != 0 ? (_bearing - _direction) : _bearing;
    return AnimatedRotation(
      turns: rotationAngle / 360,
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.5),
          border: Border.all(
            color: _getIndicatorColor(),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.navigation,
          size: 80,
          color: _getIndicatorColor(),
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: _distance <= 1
              ? [Colors.amber, Colors.orange]
              : [Colors.grey.shade700, Colors.grey.shade800],
        ),
        boxShadow: _distance <= 1
            ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: _distance <= 1
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScannerScreen()),
                );
              }
            : null,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text(
          "📸 Scanează Codul QR",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDistanceIndicator(),
              _buildCompassArrow(),
              _buildScanButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _positionStream?.cancel();
    _compassStream?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
