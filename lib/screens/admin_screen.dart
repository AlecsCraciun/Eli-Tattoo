import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

import 'admin_portfolio_screen.dart';
import 'promotions_admin_screen.dart';
import 'treasure_hunt_admin_screen.dart';
import 'qr_fidelity_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Panou Administrare", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildGlassTile(
                    context,
                    icon: Icons.photo_library,
                    label: "Portofolii",
                    screen: const AdminPortfolioScreen(),
                  ),
                  _buildGlassTile(
                    context,
                    icon: Icons.local_offer,
                    label: "Promoții",
                    screen: const PromotionsAdminScreen(),
                  ),
                  _buildGlassTile(
                    context,
                    icon: Icons.card_giftcard,
                    label: "Treasure Hunt",
                    screen: const TreasureHuntAdminScreen(),
                  ),
                  _buildGlassTile(
                    context,
                    icon: Icons.qr_code,
                    label: "Fidelizare",
                    screen: const QrFidelityScreen(),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGlassTile(BuildContext context,
      {required IconData icon, required String label, required Widget screen}) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      ),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 20,
        blur: 15,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          colors: [
            Colors.white.withAlpha(20),
            Colors.white38.withAlpha(30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderGradient: LinearGradient(
          colors: [
            Colors.white24,
            Colors.white10,
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2B5876), Color(0xFF4E4376)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
