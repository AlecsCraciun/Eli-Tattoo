import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class LaserRemovalScreen extends StatelessWidget {
  const LaserRemovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Laser Removal", style: TextStyle(color: Colors.white)),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Titlu mare și elegant
                const Text(
                  "🌟 Îndepărtare Tatuaje cu Tehnologia PICO LASER",
                  style: TextStyle(color: Colors.amber, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // 🔹 Descriere serviciu
                _buildInfoCard(
                  "Ești pregătit pentru o schimbare? La Eli Tattoo folosim tehnologia avansată Pico Laser pentru îndepărtarea sigură și eficientă a tatuajelor nedorite.",
                ),

                const SizedBox(height: 20),

                // 🔹 Beneficii
                _buildInfoCard(
                  "✅ Tehnologie de ultimă generație Pico Laser\n"
                  "✅ Rezultate vizibile încă de la primele ședințe\n"
                  "✅ Procedură sigură și controlată\n"
                  "✅ Personal specializat cu experiență",
                ),

                const SizedBox(height: 20),

                // 🔹 Informații importante
                _buildInfoCard(
                  "📆 Ședințele sunt programate la 6-8 săptămâni distanță\n"
                  "📝 Fiecare tratament este personalizat\n"
                  "💬 Oferim consultație gratuită pentru evaluarea tatuajului",
                ),

                const SizedBox(height: 20),

                // 🔹 Contraindicații
                _buildWarningCard(
                  "⚠️ Contraindicații:\n"
                  "❌ Sarcina sau alăptarea\n"
                  "❌ Afecțiuni canceroase\n"
                  "❌ Epilepsie\n"
                  "❌ Boli hepatice severe\n"
                  "❌ Afecțiuni cardiace grave",
                ),

                const SizedBox(height: 20),

                // 🔹 Buton contact
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, "/chat"),
                    icon: const Icon(Icons.message, color: Colors.black),
                    label: const Text("Trimite Mesaj", style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 30), // 🔹 Spațiu final pentru scroll complet
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

  /// 🔹 Card glossy cu avertismente
  Widget _buildWarningCard(String text) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(15),
      blur: 10,
      border: Border.all(width: 1, color: Colors.red.withOpacity(0.5)),
      gradient: LinearGradient(
        colors: [Colors.red.withOpacity(0.3), Colors.black.withOpacity(0.4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
