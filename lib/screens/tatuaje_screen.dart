import 'package:flutter/material.dart';

class TatuajeScreen extends StatelessWidget {
  const TatuajeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Portofoliu Tatuaje"),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPortfolioButton(context, "Vezi Portofoliu Alecs", "/portofoliu_alecs"),
              const SizedBox(height: 20),
              _buildPortfolioButton(context, "Vezi Portofoliu Denis", "/portofoliu_denis"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioButton(BuildContext context, String text, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purpleAccent,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: Text(text),
    );
  }
}
