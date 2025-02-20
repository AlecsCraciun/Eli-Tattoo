import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'voucher_tracker_screen.dart';

class VoucherDetailsScreen extends StatelessWidget {
  final String title;
  final String description;
  final String detailedDescription;
  final String imageUrl;
  final String location;
  final double latitude;
  final double longitude;
  final int value;

  const VoucherDetailsScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.detailedDescription,
    required this.imageUrl,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.value,
  }) : super(key: key);

  void _openGoogleMaps() async {
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Nu s-a putut deschide Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black.withOpacity(0.8),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imaginea voucherului
            Image.network(imageUrl, width: double.infinity, height: 250, fit: BoxFit.cover),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Descriere scurtă
                  Text(
                    description,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Descriere detaliată
                  Text(
                    detailedDescription,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // 🟢 Distanta până la voucher
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_walk, color: Colors.green, size: 24),
                        SizedBox(width: 10),
                        Text(
                          "Distanță aproximativă: ~ ${value} metri",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 🗺️ Buton Google Maps
                  ElevatedButton.icon(
                    onPressed: _openGoogleMaps,
                    icon: Icon(Icons.map),
                    label: Text("Vezi pe Google Maps"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 🔍 Buton pentru urmărirea voucherului
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VoucherTrackerScreen(
                            title: title,
                            latitude: latitude,
                            longitude: longitude,
                            value: value,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.track_changes),
                    label: const Text("Urmărește Voucher"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ⚠️ Avertisment de siguranță
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent, width: 1),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.warning, color: Colors.redAccent, size: 30),
                        const SizedBox(height: 5),
                        Text(
                          "⚠️ Voucherele NU vor fi ascunse în locuri periculoase! "
                          "Nu încercați să le căutați în zone nesigure sau greu accesibile. "
                          "Scopul acestui joc este distracția, nu accidentarea!",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
