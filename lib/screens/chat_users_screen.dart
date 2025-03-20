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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _isAdmin = userDoc['role'] == 'admin' || userDoc['role'] == 'artist';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Conversații")),
      body: _isAdmin ? _buildAdminChatList() : _buildUserChat(),
    );
  }

  /// 🔹 **Adminul vede utilizatorii care au trimis mesaje**
  Widget _buildAdminChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chats').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final users = snapshot.data!.docs.toList();

        if (users.isEmpty) {
          return const Center(child: Text("Nu există conversații."));
        }

        return ListView(
          children: users.map((user) {
            final userId = user.id;

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(userId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return const SizedBox.shrink();

                final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                final userName = userData['name'] ?? userData['email']?.split('@').first ?? 'Utilizator Necunoscut';

                return ListTile(
                  title: Text(userName),
                  subtitle: const Text("Apasă pentru a deschide chat-ul"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatId: userId, userName: userName),
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  /// 🔹 Utilizatorul obișnuit intră direct în chat cu echipa Eli Tattoo
  Widget _buildUserChat() {
    return ChatScreen(chatId: 'eli_tattoo_team', userName: "Eli Tattoo Team");
  }
}
