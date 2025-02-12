import 'package:flutter/material.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promoții')),
      body: const Center(
        child: Text("Aici vor apărea promoțiile din Firebase."),
      ),
    );
  }
}
