import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

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
  final ScrollController _scrollController = ScrollController();

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

    final String chatId = _isAdmin ? widget.chatId : _currentUserId!;
    final String receiverId = _isAdmin ? widget.chatId : "eli_tattoo_team";

    final messageData = {
      'text': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': _currentUserId,
      'receiverId': receiverId,
      'read': false
    };

    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      await chatRef.collection('messages').add(messageData);

      await chatRef.set({
        'lastMessage': messageData['text'],
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      print("❌ Eroare la trimiterea mesajului: $e");
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('chats').doc(widget.chatId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?['typing'] == null) return const SizedBox();
                return const Text("Typing...", style: TextStyle(fontSize: 12, color: Colors.white70));
              },
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/images/background.png"), fit: BoxFit.cover),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/background.png"), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection("chats")
                    .doc(widget.chatId)
                    .collection("messages")
                    .orderBy("timestamp", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final messages = snapshot.data!.docs;
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text("Nu există mesaje.", style: TextStyle(fontSize: 16, color: Colors.white70)),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final data = messages[index].data() as Map<String, dynamic>? ?? {};
                      final isMe = data['senderId'] == _currentUserId;
                      final messageText = data['text']?.toString() ?? '[Media]';

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: GlassContainer(
                          blur: 10,
                          opacity: 0.2,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.green[300] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(messageText),
                          ),
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
      ),
    );
  }

  Widget _chatInputField() {
    return GlassContainer(
      blur: 10,
      opacity: 0.3,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Scrie un mesaj...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
