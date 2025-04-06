import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:io';
import 'dart:async';

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
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  
  String? _currentUserId;
  bool _isAdmin = false;
  bool _isTyping = false;
  bool _showEmoji = false;
  String? _replyTo;
  String? _editingMessageId;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _markMessagesAsRead() async {
    if (_currentUserId == null) return;
    
    final chatId = _isAdmin ? widget.chatId : _currentUserId!;
    final messagesRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: _currentUserId)
        .where('read', isEqualTo: false);

    final messages = await messagesRef.get();
    
    for (var doc in messages.docs) {
      await doc.reference.update({'read': true});
    }
  }

  void _handleTyping(String text) {
    if (!_isAdmin) return;

    _typingTimer?.cancel();
    
    if (text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
      _firestore.collection('chats').doc(widget.chatId).update({
        'typing': true,
        'typingUser': widget.userName,
      });
    }

    _typingTimer = Timer(const Duration(seconds: 2), () {
      setState(() => _isTyping = false);
      _firestore.collection('chats').doc(widget.chatId).update({
        'typing': false,
        'typingUser': null,
      });
    });
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final File imageFile = File(image.path);
        await _uploadAndSendImage(imageFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la încărcarea imaginii: $e')),
      );
    }
  }

  Future<void> _uploadAndSendImage(File imageFile) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('chat_images/$fileName');
      
      await ref.putFile(imageFile);
      final String downloadUrl = await ref.getDownloadURL();

      await _sendMessage(imageUrl: downloadUrl);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la încărcarea imaginii: $e')),
      );
    }
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    if ((_messageController.text.trim().isEmpty && imageUrl == null) || _currentUserId == null) return;

    final String chatId = _isAdmin ? widget.chatId : _currentUserId!;
    final String receiverId = _isAdmin ? widget.chatId : "eli_tattoo_team";

    final messageData = {
      'text': _messageController.text.trim(),
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'senderId': _currentUserId,
      'receiverId': receiverId,
      'read': false,
      'senderName': widget.userName,
      if (_replyTo != null) 'replyTo': _replyTo,
    };

    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      
      if (_editingMessageId != null) {
        await chatRef.collection('messages').doc(_editingMessageId).update({
          'text': _messageController.text.trim(),
          'edited': true,
        });
        setState(() => _editingMessageId = null);
      } else {
        await chatRef.collection('messages').add(messageData);
        
        await chatRef.set({
          'lastMessage': imageUrl != null ? '📷 Imagine' : messageData['text'],
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': FieldValue.increment(1),
          'lastSender': _currentUserId,
          'participants': [_currentUserId, receiverId],
        }, SetOptions(merge: true));
      }

      _messageController.clear();
      setState(() => _replyTo = null);
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Eroare la trimiterea mesajului: $e")),
      );
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la ștergerea mesajului: $e')),
      );
    }
  }

  void _editMessage(String messageId, String currentText) {
    setState(() {
      _editingMessageId = messageId;
      _messageController.text = currentText;
    });
    FocusScope.of(context).requestFocus();
  }

  Widget _buildMessage(Map<String, dynamic> data, String messageId) {
    final isMe = data['senderId'] == _currentUserId;
    final messageText = data['text']?.toString() ?? '';
    final imageUrl = data['imageUrl'];
    final timestamp = data['timestamp'] as Timestamp?;
    final isEdited = data['edited'] ?? false;
    final replyTo = data['replyTo'];

    return SwipeableTile.card(
      key: Key(messageId),
      color: Colors.transparent,
      shadow: const BoxShadow(color: Colors.transparent),
      horizontalPadding: 0,
      verticalPadding: 0,
      direction: isMe ? SwipeDirection.endToStart : SwipeDirection.startToEnd,
      onSwiped: (direction) {
        setState(() => _replyTo = messageId);
      },
      backgroundBuilder: (context, direction, progress) {
        return Container(
          color: Colors.blue.withOpacity(0.2),
          child: const Icon(Icons.reply, color: Colors.white),
        );
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: GestureDetector(
            onLongPress: isMe ? () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: const Text('Opțiuni', style: TextStyle(color: Colors.white)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.white),
                        title: const Text('Editează', style: TextStyle(color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          _editMessage(messageId, messageText);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text('Șterge', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.pop(context);
                          _deleteMessage(messageId);
                        },
                      ),
                    ],
                  ),
                ),
              );
            } : null,
            child: GlassContainer(
              borderRadius: BorderRadius.circular(15),
              blur: 10,
              color: isMe 
                ? Colors.amber.withOpacity(0.3)
                : Colors.white.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (replyTo != null)
                      FutureBuilder<DocumentSnapshot>(
                        future: _firestore
                            .collection('chats')
                            .doc(widget.chatId)
                            .collection('messages')
                            .doc(replyTo)
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox();
                          final replyData = snapshot.data!.data() as Map<String, dynamic>?;
                          if (replyData == null) return const SizedBox();
                          
                          return Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              replyData['text'] ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          placeholder: (context, url) => 
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    if (messageText.isNotEmpty)
                      Text(
                        messageText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timestamp != null
                              ? timeago.format(timestamp.toDate(), locale: 'ro')
                              : '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        if (isEdited)
                          Text(
                            ' • editat',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          if (_editingMessageId != null)
            GlassContainer(
              blur: 10,
              color: Colors.amber.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Editezi un mesaj',
                      style: TextStyle(color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _editingMessageId = null;
                          _messageController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          GlassContainer(
            borderRadius: BorderRadius.circular(25),
            blur: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _showEmoji ? Icons.keyboard : Icons.emoji_emotions,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() => _showEmoji = !_showEmoji);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.amber),
                    onPressed: _pickImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                                            onChanged: _handleTyping,
                      decoration: InputDecoration(
                        hintText: 'Scrie un mesaj...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.amber),
                    onPressed: () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userName,
              style: const TextStyle(color: Colors.white),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('chats').doc(widget.chatId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?['typing'] != true) {
                  return const SizedBox();
                }
                return Text(
                  "${snapshot.data?['typingUser'] ?? 'Cineva'} scrie...",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (_replyTo != null)
                GlassContainer(
                  blur: 10,
                  color: Colors.white.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.reply, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Răspunzi la mesaj',
                          style: TextStyle(color: Colors.white),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _replyTo = null),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection("chats")
                      .doc(widget.chatId)
                      .collection("messages")
                      .orderBy("timestamp", descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!.docs;
                    if (messages.isEmpty) {
                      return Center(
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(15),
                          blur: 10,
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              "Începe o conversație...",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final data = messages[index].data() as Map<String, dynamic>;
                        return _buildMessage(data, messages[index].id);
                      },
                    );
                  },
                ),
              ),
              _buildInputField(),
              if (_showEmoji)
                SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _messageController.text += emoji.emoji;
                    },
                    config: Config(
                      columns: 7,
                      emojiSizeMax: 32,
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      initCategory: Category.RECENT,
                      bgColor: const Color(0xFF1f1f1f),
                      iconColor: Colors.white,
                      iconColorSelected: Colors.amber,
                      backspaceColor: Colors.amber,
                      recentsLimit: 28,
                      categoryIcons: const CategoryIcons(),
                      buttonMode: ButtonMode.MATERIAL,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
