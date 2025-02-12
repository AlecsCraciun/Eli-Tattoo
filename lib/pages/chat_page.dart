// lib/pages/chat_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

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
          'CHAT',
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
          // Lista de conversații
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(15),
              children: [
                _buildChatItem('Alecs', 'Bună ziua! Cu ce vă pot ajuta?'),
                _buildChatItem('Blanca', 'Aveți întrebări despre piercing?'),
                _buildChatItem('Denis', 'Vă pot ajuta cu un design personalizat'),
              ],
            ),
          ),
          // Bara de căutare
          Container(
            padding: const EdgeInsets.all(15),
            color: AppColors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Caută o conversație...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: AppColors.darkBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: AppColors.gold),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: AppColors.gold),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(color: AppColors.gold, width: 2),
                      ),
                      prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                    ),
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    // Logica pentru chat nou
                  },
                  backgroundColor: AppColors.gold,
                  child: const Icon(Icons.add, color: AppColors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(String name, String lastMessage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.gold),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.gold,
          child: Text(
            name[0],
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          lastMessage,
          style: const TextStyle(
            color: Colors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.gold),
        onTap: () {
          // Logica pentru deschiderea conversației
        },
      ),
    );
  }
}
