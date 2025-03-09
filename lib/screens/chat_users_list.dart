import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatUsersListScreen extends StatefulWidget {
  const ChatUsersListScreen({super.key});

  @override
  _ChatUsersListScreenState createState() => _ChatUsersListScreenState();
}

class _ChatUsersListScreenState extends State<ChatUsersListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection("users").doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userRole = doc["role"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null || (_userRole != "admin" && _userRole != "artist")) {
      return const Center(child: Text("Nu ai permisiunea de a accesa această pagină."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversații"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("messages").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          Map<String, String> users = {};

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final senderId = data["senderId"] ?? "";
            final senderName = data["senderName"] ?? "";

            if (senderId.isNotEmpty && senderId != user.uid) {
              users[senderId] = senderName;
            }
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              String userId = users.keys.elementAt(index);
              String userName = users.values.elementAt(index);

              return ListTile(
                title: Text(userName),
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
