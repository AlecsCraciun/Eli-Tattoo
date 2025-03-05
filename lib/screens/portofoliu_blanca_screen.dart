import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class PortofoliuBlancaScreen extends StatelessWidget {
  const PortofoliuBlancaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Piercing by Blanca", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🔹 Fundal luxury
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),

          Column(
            children: [
              const SizedBox(height: 80),

              // 🔹 Avatar + descriere într-un card glossy (mai compact)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 Avatar Blanca (același loc)
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                                image: const DecorationImage(
                                  image: AssetImage("assets/images/blanca_avatar.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),

                            // 🔹 Titlu + început descriere
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "✨ Artă și Precizie în Piercing",
                                    style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    "Cu peste 5 ani de experiență, Blanca transformă fiecare procedură într-o experiență unică și sigură.",
                                    style: TextStyle(color: Colors.white, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // 🔹 Restul descrierii sub avatar
                        const SizedBox(height: 10),
                        const Text(
                          "Pasiunea ei pentru detalii și devotamentul pentru siguranța clienților au făcut-o una dintre cele mai apreciate specialiste din Brașov.",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Card cu informații detaliate
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        "🌟 De ce să alegi Piercing by Blanca:",
                        "✅ Tehnică precisă și delicată\n"
                        "✅ Bijuterii premium, hipoalergenice\n"
                        "✅ Proceduri 100% sterile\n"
                        "✅ Consultanță completă pre și post-piercing\n"
                        "✅ Atmosferă primitoare și relaxantă",
                      ),

                      const SizedBox(height: 10),

                      _buildInfoCard(
                        "💫 Ce ne face diferiți:",
                        "🔸 Consultație detaliată pentru alegerea bijuteriei perfecte\n"
                        "🔸 Proceduri realizate exclusiv cu materiale premium\n"
                        "🔸 Sfaturi complete pentru îngrijire\n"
                        "🔸 Monitorizare post-procedură\n"
                        "🔸 Atmosferă caldă și primitoare",
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Placeholder pentru poze cu piercing-uri
                      const Text(
                        "📸 Urmărește portofoliul nostru de piercing-uri:",
                        style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemCount: 6, // 🔹 Înlocuiește cu numărul real de imagini
                        itemBuilder: (context, index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              "assets/images/piercing_$index.jpg", // 🔹 Înlocuiește cu imagini reale
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Buton de programare
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, "/chat"),
                        icon: const Icon(Icons.schedule, color: Colors.black),
                        label: const Text("Programează-te acum!", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),

                      const SizedBox(height: 30),
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

  /// 🔹 Card glossy cu informații
  Widget _buildInfoCard(String title, String text) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
