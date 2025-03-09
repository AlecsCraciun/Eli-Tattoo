import 'package:flutter/material.dart';

class AddArtistScreen extends StatelessWidget {
  const AddArtistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adaugă Artiști Noi")),
      body: const Center(child: Text("Pagina de adăugare artiști noi")),
    );
  }
}
