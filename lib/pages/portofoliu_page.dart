// lib/pages/portofoliu_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class PortofoliuPage extends StatelessWidget {
  const PortofoliuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'PORTOFOLIU',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filtre pentru artiști
          Container(
            padding: const EdgeInsets.all(15),
            color: AppColors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildArtistFilter('Alecs'),
                _buildArtistFilter('Denis'),
                _buildArtistFilter('Blanca'),
              ],
            ),
          ),
          // Grid de imagini
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: 10, // Număr temporar pentru test
              itemBuilder: (context, index) {
                return _buildPortfolioItem();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistFilter(String name) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.gold,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.gold),
        ),
      ),
      child: Text(name),
    );
  }

  Widget _buildPortfolioItem() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.gold),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/placeholder.png', // Înlocuiește cu imagini reale
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: const Text(
                'Artist: Alecs',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
