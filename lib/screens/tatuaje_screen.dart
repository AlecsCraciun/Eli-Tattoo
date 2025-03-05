import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class TatuajeScreen extends StatelessWidget {
  const TatuajeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Portofoliu Tatuaje", style: TextStyle(color: Colors.white)),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Titlu principal
                const Text(
                  "✨ Artă. Pasiune. Povești pe Piele.",
                  style: TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // 🔹 Descriere
                _buildInfoCard(
                  "'Probably the best' - nu e doar un slogan pe care ni l-am ales din orgoliu, ci ecoul feedback-ului primit de la miile de clienți care ne-au trecut pragul de-a lungul anilor.\n\n"
                  "Suntem Alecs și Denis, doi artiști pentru care tatuajul nu e doar o meserie, ci o formă de artă ce prinde viață pe piele. Cu o experiență de 10 ani și mii de proiecte finalizate în România și alte țări europene, Alecs și-a cizelat un stil distinctiv în arta tatuajelor ornamentale, grafice și realiste. Alături de el, Denis aduce o perspectivă proaspătă prin măiestria sa în fine line și microrealism, creând adevărate opere de artă prin tehnici de stippling și black work.",
                ),

                const SizedBox(height: 20),

                // 🔹 Stilurile noastre
                _buildInfoCard(
                  "🎨 **Stilurile Noastre:**\n\n"
                  "**Alecs:**\n"
                  "• Ornamental & Graphic Design\n"
                  "• Realism\n"
                  "• Custom Design\n"
                  "• Black & Grey / Color\n\n"
                  "**Denis:**\n"
                  "• Fine Line & Microrealism\n"
                  "• Black Work\n"
                  "• Stippling\n"
                  "• Minimalist",
                ),

                const SizedBox(height: 20),

                // 🔹 Procesul nostru creativ
                _buildInfoCard(
                  "💫 **Procesul Nostru Creativ:**\n"
                  "• Consultație personalizată gratuită\n"
                  "• Design custom adaptat stilului tău\n"
                  "• Atenție la detalii și execuție impecabilă\n"
                  "• Sfaturi complete pentru îngrijire",
                ),

                const SizedBox(height: 20),

                // 🔹 Butoane portofoliu
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPortfolioButton(context, "Vezi Portofoliu Alecs", "/portofoliu_alecs"),
                    const SizedBox(width: 20),
                    _buildPortfolioButton(context, "Vezi Portofoliu Denis", "/portofoliu_denis"),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔹 Buton consultație
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, "/chat"),
                  icon: const Icon(Icons.calendar_today, color: Colors.black),
                  label: const Text("Programează Consultație", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
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

  /// 🔹 Butoane pentru portofolii artiști
  Widget _buildPortfolioButton(BuildContext context, String text, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }
}
