import 'package:flutter/material.dart';

class ChatAdminScreen extends StatelessWidget {
  const ChatAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administrare Chat")),
      body: const Center(child: Text("Pagina de administrare chat")),
    );
  }
}
