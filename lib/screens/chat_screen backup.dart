import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({super.key, required this.userId, required this.userName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _currentUserId;

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
    }
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (_messageController.text.trim().isEmpty && imageUrl == null) return;

    final messageData = {
      'text': _messageController.text.trim(),
      'imageUrl': imageUrl ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': user.uid,
      'receiverId': widget.userId,
      'senderName': user.displayName ?? 'Anonim',
      'senderPhoto': user.photoURL ?? '',
    };

    // 1️⃣ Salvează mesajul în chatul utilizatorului destinatar
    await _firestore.collection('users')
        .doc(widget.userId)
        .collection('messages')
        .add(messageData);

    // 2️⃣ Salvează mesajul și în chatul utilizatorului expeditor
    await _firestore.collection('users')
        .doc(user.uid)
        .collection('messages')
        .add(messageData);

    _messageController.clear();

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

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      File imageFile = File(pickedFile.path);
      String fileName = 'chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(imageFile);

      setState(() => _isUploading = true);
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      _sendMessage(imageUrl: imageUrl);
    } catch (e) {
      print("⚠️ Eroare la upload imagine: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              Expanded(
                child: _currentUserId == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('users')
                            .doc(_currentUserId) // ID utilizator curent (admin sau user)
                            .collection('messages')
                            .orderBy('timestamp', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                "Nu există mesaje încă.",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          final messages = snapshot.data!.docs.where((msg) {
                            final data = msg.data() as Map<String, dynamic>;
                            final senderId = data['senderId'] ?? '';
                            final receiverId = data['receiverId'] ?? '';

                            return (senderId == _currentUserId && receiverId == widget.userId) ||
                                (senderId == widget.userId && receiverId == _currentUserId);
                          }).toList();

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(10),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final data = messages[index].data() as Map<String, dynamic>;
                              final senderId = data['senderId'] ?? 'Anonim';
                              final senderName = data['senderName'] ?? senderId;
                              final imageUrl = data['imageUrl'] ?? '';
                              bool isMe = senderId == _currentUserId;

                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  child: GlassContainer(
                                    width: MediaQuery.of(context).size.width * 0.7,
                                    blur: 15,
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      colors: isMe
                                          ? [Colors.green.withOpacity(0.4), Colors.green.withOpacity(0.2)]
                                          : [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        children: [
                                          if (!isMe)
                                            Text(senderName, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                          if (imageUrl.isNotEmpty)
                                            Image.network(imageUrl, width: 200, height: 200, fit: BoxFit.cover),
                                          if (data['text'].toString().isNotEmpty)
                                            Text(data['text'], style: const TextStyle(fontSize: 16, color: Colors.white)),
                                        ],
                                      ),
                                    ),
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
        ],
      ),
    );
  }

  Widget _chatInputField() {
    return GlassContainer(
      width: double.infinity,
      height: 60,
      blur: 20,
      borderRadius: BorderRadius.circular(15),
      gradient: LinearGradient(
        colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowStrength: 5,
      border: Border.all(color: Colors.white.withOpacity(0.3)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image, color: Colors.amber),
              onPressed: _pickImage,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Scrie un mesaj...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.green),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
