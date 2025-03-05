import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
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
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl));
    } else {
      throw 'Nu s-a putut deschide Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🔹 Fundal luxury
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),

          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🏆 Imaginea voucherului
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(imageUrl, width: double.infinity, height: 280, fit: BoxFit.cover),
                ),
                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // 🔹 Descriere scurtă
                      Text(
                        description,
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      // 🔹 Descriere detaliată
                      Text(
                        detailedDescription,
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Distanta până la voucher
                      GlassContainer(
                        borderRadius: BorderRadius.circular(12),
                        blur: 10,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.07)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.directions_walk, color: Colors.amber, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                "Distanță aproximativă: ~ ${value} metri",
                                style: const TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // 🔹 Butoane acțiune
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildButton(Icons.map, "Vezi pe Hartă", _openGoogleMaps),
                          _buildButton(Icons.track_changes, "Urmărește", () {
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
                          }),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Mesaj de siguranță
                      GlassContainer(
                        borderRadius: BorderRadius.circular(12),
                        blur: 10,
                        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 1),
                        gradient: LinearGradient(
                          colors: [Colors.amber.withOpacity(0.3), Colors.black.withOpacity(0.4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.info, color: Colors.amber, size: 30),
                              const SizedBox(height: 5),
                              const Text(
                                "🌟 Hei, vânătorule de comori!",
                                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Înainte să pornești în aventură, câteva detalii importante despre locațiile voucherelor:\n\n"
                                "• Nu le vei găsi pe străzi sau în apropierea traficului\n"
                                "• Nu sunt ascunse la înălțime sau în copaci\n"
                                "• Toate sunt amplasate în locuri 100% sigure și ușor accesibile\n\n"
                                "Ne dorim să te distrezi la maximum, în deplină siguranță! "
                                "Așa că lasă-ți grijile deoparte și bucură-te de vânătoarea de comori. Aventura ta începe acum! 🎯✨",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
