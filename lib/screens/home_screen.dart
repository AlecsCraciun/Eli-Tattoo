import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:animate_do/animate_do.dart';
import 'promo_screen.dart';
import 'portfolio_screen.dart';
import 'services_screen.dart';
import 'loyalty_screen.dart';
import 'chat_screen.dart';
import 'treasure_hunt_screen.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 🔹 Fundal cu efect luxury
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 60),

              // 🔹 Logo cu efect de parallax
              BounceInDown(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Titlu elegant
              FadeIn(
                child: const Text(
                  "Bine ai venit la Eli Tattoo Studio",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildCustomButton(context, 'Promoții', PromoScreen(), Icons.local_offer),
                      _buildCustomButton(context, 'Portofoliu', PortfolioScreen(), Icons.image),
                      _buildCustomButton(context, 'Servicii', ServicesScreen(), Icons.build),
                      _buildCustomButton(context, 'Fidelizare', LoyaltyScreen(), Icons.star),
                      _buildCustomButton(context, 'Chat', ChatScreen(), Icons.chat),
                      _buildCustomButton(context, 'Treasure Hunt', TreasureHuntScreen(), Icons.map),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // 🔹 Buton QR Scanner cu efect
      floatingActionButton: ElasticIn(
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => QRScannerScreen()));
          },
          backgroundColor: Colors.redAccent,
          child: const Icon(Icons.qr_code_scanner, size: 28, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCustomButton(BuildContext context, String text, Widget screen, IconData icon) {
    return FadeInUp(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: GlassContainer(
            width: double.infinity,
            height: 80,
            borderRadius: BorderRadius.circular(15),
            blur: 10,
            border: Border.all(width: 1, color: Colors.white.withOpacity(0.2)), // ✅ FIX AICI
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(blurRadius: 5, color: Colors.black, offset: Offset(1, 1))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
