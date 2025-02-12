// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eli Tattoo'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildMenuItem(
            icon: Icons.local_offer,
            title: 'Promoții',
            onTap: () => Get.toNamed('/promotii'),
          ),
          _buildMenuItem(
            icon: Icons.photo_library,
            title: 'Portofoliu',
            onTap: () => Get.toNamed('/portofoliu'),
          ),
          _buildMenuItem(
            icon: Icons.design_services,
            title: 'Servicii',
            onTap: () => Get.toNamed('/servicii'),
          ),
          _buildMenuItem(
            icon: Icons.card_giftcard,
            title: 'Fidelizare',
            onTap: () => Get.toNamed('/fidelizare'),
          ),
          _buildMenuItem(
            icon: Icons.chat_bubble,
            title: 'Chat',
            onTap: () => Get.toNamed('/chat'),
          ),
          _buildMenuItem(
            icon: Icons.map,
            title: 'Treasure Hunt',
            onTap: () => Get.toNamed('/treasure-hunt'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D2D2D),
              Color(0xFF1A1A1A),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFFE91E63),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
