import 'package:flutter/material.dart';

class VoucherDetailsScreen extends StatelessWidget {
  final String title;
  final String description;
  final String detailedDescription;
  final String imageUrl;
  final String location;
  final int value;

  VoucherDetailsScreen({
    required this.title,
    required this.description,
    required this.detailedDescription,
    required this.imageUrl,
    required this.location,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundal imagine
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              AppBar(
                title: Text(title, style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.black.withOpacity(0.8),
                elevation: 0,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Imaginea voucherului
                      imageUrl.isNotEmpty
                          ? Image.network(imageUrl, width: double.infinity, height: 250, fit: BoxFit.cover)
                          : SizedBox.shrink(),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              description,
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "📍 Locație: $location",
                              style: TextStyle(color: Colors.amber, fontSize: 18),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "💰 Valoare: $value RON",
                              style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Divider(color: Colors.white54),
                            SizedBox(height: 10),
                            Text(
                              "📖 Descriere detaliată:",
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              detailedDescription,
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            SizedBox(height: 20),
                            // 🔴 Caseta de avertizare
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 6,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.warning, color: Colors.white, size: 30),
                                  SizedBox(height: 8),
                                  Text(
                                    "⚠️ ATENȚIE! ⚠️",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Voucherele NU vor fi ascunse în locuri periculoase! Nu căutați pe străzi, în copaci, la înălțime sau în alte locuri care ar putea cauza accidente.\n\n"
                                    "Scopul acestui joc este să vă distrați și să câștigați premii, nu să vă puneți în pericol! Fiți atenți și respectați regulile de siguranță! 😊",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back),
                                label: Text("Înapoi"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
