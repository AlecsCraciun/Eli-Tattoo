import 'package:flutter/material.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servicii')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildServiceCard('Tatuaje', 'Detalii despre tatuaje oferite.'),
          _buildServiceCard('Piercing', 'Informații despre serviciile de piercing.'),
          _buildServiceCard('Laser Removal', 'Detalii despre eliminarea tatuajelor.'),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }
}
