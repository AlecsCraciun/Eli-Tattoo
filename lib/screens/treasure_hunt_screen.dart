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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = position;
    });
  }

  double _calculateDistance(double lat, double lon) {
    if (_currentPosition == null) return 0.0;
    return Geolocator.distanceBetween(
            _currentPosition!.latitude, _currentPosition!.longitude, lat, lon) /
        1000;
  }

  void _openMap(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('❌ Nu s-a putut deschide harta.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Treasure Hunt"),
        backgroundColor: Colors.black.withOpacity(0.8),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('treasure_hunt_rewards')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "Nu sunt vouchere disponibile acum.",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              var vouchers = snapshot.data!.docs;
              print("🔥 Vouchere încărcate: \${vouchers.length}");

              return ListView.builder(
                itemCount: vouchers.length,
                padding: EdgeInsets.only(bottom: 20),
                itemBuilder: (context, index) {
                  var voucher = vouchers[index].data() as Map<String, dynamic>?;

                  if (voucher == null) {
                    return SizedBox();
                  }

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

                  print("🔍 URL Imagine: $imageUrl");

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Card(
                      color: Colors.grey.shade900,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white, width: 1)),
                      child: Padding(
                        padding: EdgeInsets.all(16),
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
                                child: Image.network(
                                  imageUrl,
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.width * 2 / 5,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            ListTile(
                              title: Text(title,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Distanță: \${distance.toStringAsFixed(2)} km",
                                      style: TextStyle(color: Colors.white70)),
                                  Text("Lat: $latitude, Lon: $longitude",
                                      style: TextStyle(color: Colors.white70)),
                                ],
                              ),
                              trailing: Text("\$value RON",
                                  style: TextStyle(
                                      color: Colors.amber, fontSize: 18)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _openMap(latitude, longitude),
                                  icon: Icon(Icons.map),
                                  label: Text("Vezi pe hartă"),
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
                                          detailedDescription:
                                              detailedDescription,
                                          imageUrl: imageUrl,
                                          location:
                                              "Lat: $latitude, Lon: $longitude",
                                          value: value,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.info),
                                  label: Text("Vezi voucherul"),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
