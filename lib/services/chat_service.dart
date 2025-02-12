// lib/services/chat_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crează sau obține chat-ul cu un artist
  Future<String> createOrGetChat(String userId, String artistId) async {
    // Verificăm dacă există deja un chat
    final existingChat = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .get();

    for (var doc in existingChat.docs) {
      List<String> participants = List<String>.from(doc['participants']);
      if (participants.contains(artistId)) {
        return doc.id;
      }
    }

    // Dacă nu există, creăm unul nou
    final chatDoc = await _firestore.collection('chats').add({
      'participants': [userId, artistId],
      'lastMessage': null,
      'lastMessageTime': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return chatDoc.id;
  }

  // Trimite un mesaj
  Future<void> sendMessage(String chatId, String senderId, String message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Actualizăm ultimul mesaj în chat
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  // Obține mesajele unui chat
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Obține toate chat-urile unui utilizator
  Stream<QuerySnapshot> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // Marchează mesajele ca citite
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
