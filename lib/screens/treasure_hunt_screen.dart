import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
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
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _locationError = true);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() => _currentPosition = position);
    } catch (e) {
      setState(() => _locationError = true);
    }
  }

  double _calculateDistance(double lat, double lon) {
    if (_currentPosition == null) return -1;
    return Geolocator.distanceBetween(
        _currentPosition!.latitude, _currentPosition!.longitude, lat, lon);
  }

  void _openMap(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Treasure Hunt", style: TextStyle(color: Colors.amber)),
        backgroundColor: Colors.black,
        elevation: 2,
      ),
      body: _locationError
          ? _buildLocationError()
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('treasure_hunt_rewards')
                  .snapshots(),
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
                    String imageUrl = voucher['image_url'] ??
                        "https://firebasestorage.googleapis.com/v0/b/elitattoo-app-c7763.firebasestorage.app/o/voucher_fantana.jpg?alt=media&token=2920ee76-f1d8-4a6d-8574-0b2d0bd2dba0";
                    double latitude = voucher['latitude'] ?? 0.0;
                    double longitude = voucher['longitude'] ?? 0.0;
                    int value = voucher['value'] ?? 0;

                    double distance = _calculateDistance(latitude, longitude);
                    String distanceText = (distance < 0)
                        ? "Locație necunoscută"
                        : "${distance.toStringAsFixed(2)} metri";

                    return Card(
                      color: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.amber.shade700, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(color: Colors.amber),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              style: TextStyle(
                                  color: Colors.amber.shade700,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Distanță: $distanceText",
                              style: const TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "$value RON",
                              style: const TextStyle(
                                  color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _openMap(latitude, longitude),
                                  icon: const Icon(Icons.map, color: Colors.black),
                                  label: const Text("Vezi pe hartă",
                                      style: TextStyle(color: Colors.black)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
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
                                  },
                                  icon: const Icon(Icons.info, color: Colors.black),
                                  label: const Text("Detalii",
                                      style: TextStyle(color: Colors.black)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildLocationError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("❌ GPS dezactivat sau permisiuni refuzate!",
              style: TextStyle(color: Colors.redAccent, fontSize: 18)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: const Text("Reîncercă"),
          ),
        ],
      ),
    );
  }
}
