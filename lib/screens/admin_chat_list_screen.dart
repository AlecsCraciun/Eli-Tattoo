import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mesaje utilizatori"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // 🔹 Creăm o listă unică de utilizatori pe baza mesajelor trimise
          Map<String, String> users = {};
          for (var msg in snapshot.data!.docs) {
            final data = msg.data() as Map<String, dynamic>;
            final senderId = data['senderId'] ?? '';
            final senderName = data['senderName'] ?? 'Anonim';
            if (senderId.isNotEmpty) users[senderId] = senderName;
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userId = users.keys.elementAt(index);
              final userName = users.values.elementAt(index);

              return ListTile(
                title: Text(userName, style: const TextStyle(color: Colors.white)),
                leading: const Icon(Icons.person, color: Colors.amber),
                trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                tileColor: Colors.black54,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(userId: userId, userName: userName),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
