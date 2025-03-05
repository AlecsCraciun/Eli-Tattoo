import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class RateTBIScreen extends StatelessWidget {
  const RateTBIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Rate TBI", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🔹 Fundal luxury
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),

          // 🔹 Conținut Scrollabil
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Titlu principal
                const Text(
                  "💳 Plătește în Rate prin TBI Bank!",
                  style: TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // 🔹 Descriere serviciu
                _buildInfoCard(
                  "Verifică eligibilitatea și bucură-te de tatuajul dorit fără griji financiare. "
                  "Cu TBI Bank, ai acces rapid la finanțare, fără bătăi de cap!",
                ),

                const SizedBox(height: 20),

                // 🔹 Avantaje Rate TBI
                _buildInfoCard(
                  "✅ Aplicație rapidă și ușoară\n"
                  "✅ Răspuns în câteva minute\n"
                  "✅ Rate flexibile și avantajoase\n"
                  "✅ Disponibil pentru orice serviciu de tatuaj sau piercing",
                ),

                const SizedBox(height: 20),

                // 🔹 Banner TBI
                GlassContainer(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset("assets/images/tbi_banner.png", fit: BoxFit.cover),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Buton contact
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, "/chat"),
                  icon: const Icon(Icons.message, color: Colors.black),
                  label: const Text("Contactează-ne", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),

                const SizedBox(height: 30), // 🔹 Spațiu extra pentru siguranță
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Card glossy cu informații
  Widget _buildInfoCard(String text) {
    return GlassContainer(
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
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
