// lib/pages/servicii_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class ServiciiPage extends StatelessWidget {
  const ServiciiPage({super.key});

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
          'SERVICII',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildServiceCategory(
            'Tatuaje',
            [
              ServiceItem('Tatuaj Alb-Negru', 'de la 200 RON'),
              ServiceItem('Tatuaj Color', 'de la 250 RON'),
              ServiceItem('Cover-Up', 'în funcție de complexitate'),
              ServiceItem('Tatuaj Realist', 'în funcție de dimensiune'),
            ],
          ),
          const SizedBox(height: 20),
          _buildServiceCategory(
            'Piercing',
            [
              ServiceItem('Piercing Ureche', '100 RON'),
              ServiceItem('Piercing Nas', '100 RON'),
              ServiceItem('Piercing Buză', '120 RON'),
              ServiceItem('Piercing Limbă', '150 RON'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategory(String title, List<ServiceItem> services) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.gold, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...services.map((service) => _buildServiceItem(service)),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ServiceItem service) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gold, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            service.name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
            ),
          ),
          Text(
            service.price,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceItem {
  final String name;
  final String price;

  ServiceItem(this.name, this.price);
}
