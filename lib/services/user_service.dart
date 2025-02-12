// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Creează profil utilizator
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? birthDate,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone,
        'birthDate': birthDate,
        'points': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Eroare la crearea profilului: $e');
    }
  }

  // Actualizează profil utilizator
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? birthDate,
  }) async {
    try {
      final updates = <String, dynamic>{
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (birthDate != null) updates['birthDate'] = birthDate;

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      print('Eroare la actualizarea profilului: $e');
    }
  }

  // Obține profilul utilizatorului
  Stream<DocumentSnapshot> getUserProfile(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  // Verifică dacă utilizatorul există
  Future<bool> checkUserExists(String email) async {
    try {
      final result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Eroare la verificarea utilizatorului: $e');
      return false;
    }
  }
}
