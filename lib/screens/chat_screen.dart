import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class ChatScreen extends StatefulWidget {
  final String? userId;
  final String? userName;

  const ChatScreen({super.key, this.userId, this.userName});

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
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
      final doc = await _firestore.collection("users").doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userRole = doc["role"];
        });
      }
    }
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (_messageController.text.trim().isEmpty && imageUrl == null) return;

    await _firestore.collection('messages').add({
      'text': _messageController.text.trim(),
      'imageUrl': imageUrl ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': user.uid,
      'senderName': user.displayName ?? 'Anonim',
      'senderPhoto': user.photoURL ?? '',
      'receiverId': widget.userId ?? 'eli_tattoo_team',
    });

    _messageController.clear();
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
    final user = _auth.currentUser;
    final bool isArtistOrAdmin = _userRole == "admin" || _userRole == "artist";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName ?? 'Chat ELI Tattoo'),
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                    final messages = snapshot.data!.docs.where((msg) {
                      final data = msg.data() as Map<String, dynamic>;
                      final receiverId = data['receiverId'] ?? '';
                      final senderId = data['senderId'] ?? '';

                      if (widget.userId != null) {
                        return senderId == widget.userId || receiverId == widget.userId;
                      }

                      return receiverId == "eli_tattoo_team" || senderId == _currentUserId;
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
                        bool isMe = senderId == user?.uid;

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
                                    if (!isMe) Text(senderName, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                    if (imageUrl.isNotEmpty) Image.network(imageUrl, width: 200, height: 200, fit: BoxFit.cover),
                                    if (data['text'].toString().isNotEmpty) Text(data['text'], style: const TextStyle(fontSize: 16, color: Colors.white)),
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

              // ✅ Bara de input pentru trimiterea mesajelor și imaginilor
              if (user != null) _chatInputField(),
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
