import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Servicii"),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildServiceCard(
            title: "Tatuaje",
            description:
                "Alege dintre artiștii noștri talentați și vezi portofoliile lor. Prețurile variază în funcție de complexitate.",
            buttonText: "Vezi Portofoliu",
            onTap: () => Navigator.pushNamed(context, '/tatuaje'),
          ),
          _buildServiceCard(
            title: "Piercing",
            description:
                "Descoperă lista de prețuri și vezi galeria Blanca pentru pierce-uri realizate de ea. Hobby: Needle Play.",
            buttonText: "Detalii Blanca",
            onTap: () => Navigator.pushNamed(context, '/portofoliu_blanca'),
          ),
          _buildServiceCard(
            title: "Laser Removal",
            description:
                "Scapă de tatuajele vechi cu ajutorul tehnologiei laser! Trimite-ne imagini pentru o evaluare personalizată.",
            buttonText: "Trimite mesaj",
            onTap: () => Navigator.pushNamed(context, '/laser_removal'),
          ),
          _buildTBIBanner(context),
        ],
      ),
    );
  }

  /// 🔹 Card generat pentru fiecare serviciu
  Widget _buildServiceCard({
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(description, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Secțiunea pentru Rate TBI
  Widget _buildTBIBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/rate_tbi'),
      child: Card(
        color: Colors.deepOrange,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset('assets/images/tbi_banner.png', fit: BoxFit.cover),
              const SizedBox(height: 10),
              const Text(
                "Plătește în rate prin TBI Bank! Verifică eligibilitatea și bucură-te de tatuajul dorit fără griji financiare.",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
