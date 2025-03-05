import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Servicii", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🔹 Fundal luxury
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),

          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(15),
        blur: 10,
        border: Border.all(width: 1, color: Colors.white.withOpacity(0.3)),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.07)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(description, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(buttonText, style: const TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 Secțiunea pentru Rate TBI
  Widget _buildTBIBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/rate_tbi'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(15),
          blur: 10,
          border: Border.all(width: 1, color: Colors.amber.withOpacity(0.5)),
          gradient: LinearGradient(
            colors: [Colors.amber.withOpacity(0.3), Colors.black.withOpacity(0.4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset('assets/images/tbi_banner.png', fit: BoxFit.cover),
                ),
                const SizedBox(height: 10),
                const Text(
                  "💳 Plătește în rate prin TBI Bank! Verifică eligibilitatea și bucură-te de tatuajul dorit fără griji financiare.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
