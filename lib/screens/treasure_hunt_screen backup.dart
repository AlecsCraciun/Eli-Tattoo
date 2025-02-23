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
      print("❌ GPS dezactivat!");
      setState(() => _locationError = true);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        print("🚫 Permisiunea este blocată permanent!");
        setState(() => _locationError = true);
        return;
      } else if (permission == LocationPermission.denied) {
        print("⚠️ Permisiunea a fost refuzată!");
        setState(() => _locationError = true);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("📍 Locația actuală: ${position.latitude}, ${position.longitude}");
      setState(() => _currentPosition = position);
    } catch (e) {
      print("⚠️ Eroare la obținerea locației: $e");
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
    } else {
      print("❌ Nu s-a putut deschide harta!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Treasure Hunt"),
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
      ),
      body: _locationError
          ? _buildLocationError()
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('treasure_hunt_rewards')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("❌ Eroare Firestore: ${snapshot.error}");
                  return const Center(
                    child: Text("Eroare la încărcarea voucherelor."),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print("⚠️ Firestore nu returnează date.");
                  return const Center(
                    child: Text(
                      "Nu sunt vouchere disponibile acum.",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                var vouchers = snapshot.data!.docs;
                print("✅ Firestore a returnat ${vouchers.length} vouchere");

                return ListView.builder(
                  itemCount: vouchers.length,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemBuilder: (context, index) {
                    var voucher = vouchers[index].data() as Map<String, dynamic>?;

                    if (voucher == null) return const SizedBox();

                    String title = voucher['title'] ?? "Voucher";
                    String description =
                        voucher['description'] ?? "Descriere indisponibilă";
                    String detailedDescription =
                        voucher['detailed_description'] ?? "Nicio descriere detaliată.";
                    String imageUrl = voucher['image_url'] ?? "";
                    double latitude = voucher['latitude'] ?? 0.0;
                    double longitude = voucher['longitude'] ?? 0.0;
                    int value = voucher['value'] ?? 0;

                    double distance = _calculateDistance(latitude, longitude);
                    String distanceText = (distance < 0)
                        ? "Locație necunoscută"
                        : "${distance.toStringAsFixed(2)} metri";

                    print("🎯 Voucher ${index + 1}: $title, Distanță: $distanceText");

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Card(
                        color: Colors.grey.shade900,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white, width: 1)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: imageUrl.isNotEmpty
                                      ? Image.network(
                                          imageUrl,
                                          width: double.infinity,
                                          height: MediaQuery.of(context).size.width * 2 / 5,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, progress) {
                                            if (progress == null) return child;
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          'assets/images/placeholder.png',
                                          width: double.infinity,
                                          height: MediaQuery.of(context).size.width * 2 / 5,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ListTile(
                                title: Text(title,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 20)),
                                subtitle: Text(
                                  "Distanță: $distanceText",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Text("$value RON",
                                    style: const TextStyle(
                                        color: Colors.amber, fontSize: 18)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _openMap(latitude, longitude),
                                    icon: const Icon(Icons.map),
                                    label: const Text("Vezi pe hartă"),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue),
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
                                    icon: const Icon(Icons.info),
                                    label: const Text("Vezi voucherul"),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent),
                                  ),
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
