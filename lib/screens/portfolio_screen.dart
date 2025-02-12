import 'package:flutter/material.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portofoliu')),
      body: const Center(
        child: Text("Aici va fi galeria cu tatuajele realizate."),
      ),
    );
  }
}
