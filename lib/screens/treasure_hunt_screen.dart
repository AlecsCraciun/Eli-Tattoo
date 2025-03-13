import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'voucher_details_screen.dart';

class TreasureHuntScreen extends StatefulWidget {
  @override
  _TreasureHuntScreenState createState() => _TreasureHuntScreenState();
}

class _TreasureHuntScreenState extends State<TreasureHuntScreen> {
  Position? _currentPosition;
  bool _locationError = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _locationError = false);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationError = true);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationError = true);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _currentPosition = position);
    } catch (e) {
      setState(() => _locationError = true);
    }
  }

  double _calculateDistance(double lat, double lon) {
    if (_currentPosition == null) return -1;
    return Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, lat, lon);
  }

  void _openMap(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Treasure Hunt", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/images/background.png', fit: BoxFit.cover)),
          _locationError
              ? _buildLocationError()
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('treasure_hunt_rewards').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.amber));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "Nu sunt vouchere disponibile acum.",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
                    }

                    var vouchers = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: vouchers.length,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      itemBuilder: (context, index) {
                        var voucher = vouchers[index].data() as Map<String, dynamic>?;

                        if (voucher == null) return const SizedBox();

                        String title = voucher['title'] ?? "Voucher";
                        String description = voucher['description'] ?? "Descriere indisponibilă";
                        String detailedDescription = voucher['detailed_description'] ?? "Fără detalii";
                        String imageUrl = voucher['image_url'] ?? ""; // Verifică imaginea corectă
                        double latitude = voucher['latitude'] ?? 0.0;
                        double longitude = voucher['longitude'] ?? 0.0;
                        int value = voucher['value'] ?? 0;

                        double distance = _calculateDistance(latitude, longitude);
                        String distanceText = (distance < 0) ? "Locație necunoscută" : "${distance.toStringAsFixed(2)} metri";

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: GlassContainer(
                            borderRadius: BorderRadius.circular(15),
                            blur: 12,
                            border: Border.all(width: 1, color: Colors.white.withOpacity(0.3)),
                            gradient: LinearGradient(
                              colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, progress) {
                                              if (progress == null) return child;
                                              return const Center(child: CircularProgressIndicator(color: Colors.amber));
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/voucher_placeholder.png',
                                                width: double.infinity,
                                                height: 200,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'assets/images/voucher_placeholder.png',
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    title,
                                    style: TextStyle(color: Colors.amber.shade700, fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Distanță: $distanceText",
                                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "$value RON",
                                    style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildButton(Icons.map, "Vezi pe hartă", () => _openMap(latitude, longitude)),
                                      _buildButton(Icons.info, "Detalii", () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => VoucherDetailsScreen(
                                              title: title,
                                              description: description,
                                              detailedDescription: detailedDescription,
                                              imageUrl: imageUrl,
                                              latitude: latitude,
                                              longitude: longitude,
                                              value: value,
                                              location: 'Lat: $latitude, Lon: $longitude',
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildLocationError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("❌ GPS dezactivat sau permisiuni refuzate!", style: TextStyle(color: Colors.redAccent, fontSize: 18)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text("Reîncercă", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String text, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black),
      label: Text(text, style: const TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
