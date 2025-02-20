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
            context,
            icon: Icons.local_offer,
            title: 'Promoții',
            route: '/promotii',
          ),
          _buildMenuItem(
            context,
            icon: Icons.photo_library,
            title: 'Portofoliu',
            route: '/portofoliu',
          ),
          _buildMenuItem(
            context,
            icon: Icons.design_services,
            title: 'Servicii',
            route: '/servicii',
          ),
          _buildMenuItem(
            context,
            icon: Icons.card_giftcard,
            title: 'Fidelizare',
            route: '/fidelizare',
          ),
          _buildMenuItem(
            context,
            icon: Icons.chat_bubble,
            title: 'Chat',
            route: '/chat',
          ),
          _buildMenuItem(
            context,
            icon: Icons.map,
            title: 'Treasure Hunt',
            route: '/treasure-hunt',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF2C3E50), // Albastru petrol
              const Color(0xFF1ABC9C), // Verde smarald
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: MediaQuery.of(context).size.width * 0.1,
              color: const Color(0xFFD4A373), // Bej auriu pentru eleganță
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
