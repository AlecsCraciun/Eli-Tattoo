import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatUsersScreen extends StatefulWidget {
  const ChatUsersScreen({super.key});

  @override
  _ChatUsersScreenState createState() => _ChatUsersScreenState();
}

class _ChatUsersScreenState extends State<ChatUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversații"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('messages').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          // Grupăm mesajele pe utilizatori unici
          final messages = snapshot.data!.docs;
          Map<String, String> userConversations = {};

          for (var msg in messages) {
            final data = msg.data() as Map<String, dynamic>;
            final senderId = data['senderId'] ?? '';
            final senderName = data['senderName'] ?? 'Utilizator Necunoscut';

            if (senderId.isNotEmpty && senderId != _auth.currentUser?.uid) {
              userConversations[senderId] = senderName;
            }
          }

          if (userConversations.isEmpty) {
            return const Center(child: Text("Nu există conversații."));
          }

          return ListView.builder(
            itemCount: userConversations.length,
            itemBuilder: (context, index) {
              String userId = userConversations.keys.elementAt(index);
              String userName = userConversations.values.elementAt(index);

              return ListTile(
                title: Text(userName),
                subtitle: const Text("Apasă pentru a vedea conversația"),
                trailing: const Icon(Icons.chat, color: Colors.amber),
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
