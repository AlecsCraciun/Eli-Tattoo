import 'package:flutter/material.dart';

class PortofoliuBlancaScreen extends StatelessWidget {
  const PortofoliuBlancaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Portofoliu Blanca"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          "Aici va fi portofoliul pentru Blanca.",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
