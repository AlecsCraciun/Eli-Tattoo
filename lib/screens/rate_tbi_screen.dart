import 'package:flutter/material.dart';

class RateTBIScreen extends StatelessWidget {
  const RateTBIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rate TBI"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Plătește în rate prin TBI Bank!",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Verifică eligibilitatea și bucură-te de tatuajul dorit fără griji financiare. Pentru mai multe detalii, contactează-ne!",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Center(
              child: Image.asset("assets/images/tbi_banner.png"),
            ),
          ],
        ),
      ),
    );
  }
}
