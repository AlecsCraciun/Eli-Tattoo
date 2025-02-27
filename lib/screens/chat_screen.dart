import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _sendMessage({String? imageUrl}) async {
    final user = _auth.currentUser;

    if ((_messageController.text.trim().isEmpty && imageUrl == null)) return;

    await _firestore.collection('messages').add({
      'text': _messageController.text.trim(),
      'imageUrl': imageUrl ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': user?.uid ?? 'guest',
      'senderName': user?.displayName ?? 'Anonim',
      'senderPhoto': user?.photoURL ?? '',
      'receiver': 'eli_tattoo_angajati',
    });

    _messageController.clear();
    _focusNode.unfocus();

    Future.delayed(const Duration(milliseconds: 500), () {
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

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      _sendMessage(imageUrl: imageUrl);
    } catch (e) {
      print("⚠️ Eroare la upload imagine: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat ELI Tattoo'),
        backgroundColor: Colors.teal[800],
      ),
      backgroundColor: Colors.grey[300], // Fundal gri deschis ca în WhatsApp
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("❌ Eroare Firestore: ${snapshot.error}");
                  return Center(
                    child: Text(
                      'Eroare: ${snapshot.error}',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Niciun mesaj încă.'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    final data = message.data() as Map<String, dynamic>;

                    final text = data['text'] ?? '';
                    final senderId = data['senderId'] ?? 'Anonim';
                    final senderName = data['senderName'] ?? senderId;
                    final senderPhoto = data['senderPhoto'] ?? '';
                    final imageUrl = data['imageUrl'] ?? '';

                    bool isMe = senderId == user?.uid;

                    return Container(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      child: Column(
                        crossAxisAlignment:
                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(
                              senderName,
                              style: TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          Material(
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isMe
                                  ? const Radius.circular(12)
                                  : const Radius.circular(0),
                              bottomRight: isMe
                                  ? const Radius.circular(0)
                                  : const Radius.circular(12),
                            ),
                            color: isMe ? Colors.green[400] : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (imageUrl.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.error,
                                              color: Colors.red);
                                        },
                                      ),
                                    ),
                                  if (text.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        text,
                                        style: TextStyle(
                                          color:
                                              isMe ? Colors.white : Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Zona de input pentru mesaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.green),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    focusNode: _focusNode,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Scrie un mesaj...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
