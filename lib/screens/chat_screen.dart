import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userName;

  const ChatScreen({super.key, required this.chatId, required this.userName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUserId == null) return;

    final String receiverId = _isAdmin ? widget.chatId : "eli_tattoo_team";
    final String chatId = _isAdmin ? widget.chatId : _currentUserId!;

    final messageData = {
      'text': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': _currentUserId,
      'receiverId': receiverId,
    };

    try {
      print("📤 Trimit mesaj de la $_currentUserId către $receiverId: ${messageData['text']}");

      // 🔹 Salvăm mesajul în aceeași locație globală "chats"
      final chatRef = _firestore.collection('chats').doc(chatId).collection('messages');

      await chatRef.add(messageData);

      print("✅ Mesaj trimis cu succes!");

      setState(() {});
    } catch (e) {
      print("❌ Eroare la trimiterea mesajului: $e");
    }

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.userName)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 🔹 **Toți userii și adminii citesc din aceeași colecție "chats"**
    final String chatPath = "chats/${widget.chatId}/messages";

    return Scaffold(
      appBar: AppBar(title: Text(widget.userName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection(chatPath).orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nu există mesaje încă!",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>? ?? {};
                    final isMe = data['senderId'] == _currentUserId;
                    final messageText = data['text'] ?? 'Mesaj indisponibil';

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[300] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(messageText),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _chatInputField(),
        ],
      ),
    );
  }

  Widget _chatInputField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(hintText: 'Scrie un mesaj...'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
