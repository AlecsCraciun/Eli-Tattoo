// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Row(
        children: [
          // Meniul din stânga - FIDELIZARE
          _buildSideMenu(
            text: 'FIDELIZARE',
            rotation: 3,
            onTap: () => Get.toNamed('/fidelizare'),
          ),
          
          // Conținutul principal
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Logo
                Image.asset(
                  'assets/icons/app_icon.png',
                  height: 150,
                ),
                
                // Grid de butoane pentru navigare
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        _buildMenuButton('PORTOFOLIU', () => Get.toNamed('/portofoliu')),
                        _buildMenuButton('SERVICII', () => Get.toNamed('/servicii')),
                        _buildMenuButton('CHAT', () => Get.toNamed('/chat')),
                        _buildMenuButton('TREASURE HUNT', () => Get.toNamed('/treasure-hunt')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Meniul din dreapta - PROMOȚII
          _buildSideMenu(
            text: 'PROMOȚII',
            rotation: 1,
            onTap: () => Get.toNamed('/promotii'),
          ),
        ],
      ),
    );
  }

  Widget _buildSideMenu({
    required String text,
    required int rotation,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        color: AppColors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotatedBox(
              quarterTurns: rotation,
              child: Text(
                text,
                style: AppTextStyles.menuText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.gold,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: AppColors.gold, width: 2),
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.menuText.copyWith(
          color: AppColors.gold,
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
