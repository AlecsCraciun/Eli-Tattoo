// lib/services/treasure_hunt_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TreasureHuntService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obține nivelul curent al utilizatorului
  Stream<DocumentSnapshot> getCurrentLevel(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('treasure_hunt')
        .doc('progress')
        .snapshots();
  }

  // Verifică și procesează un cod QR scanat
  Future<Map<String, dynamic>> processQRCode(String userId, String qrCode) async {
    try {
      // Verificăm dacă codul QR este valid și corespunde nivelului actual
      final userProgress = await _firestore
          .collection('users')
          .doc(userId)
          .collection('treasure_hunt')
          .doc('progress')
          .get();

      final currentLevel = userProgress.data()?['currentLevel'] ?? 1;
      
      // Verificăm codul în baza de date
      final qrDoc = await _firestore
          .collection('treasure_hunt')
          .doc('codes')
          .collection('level_\$currentLevel')
          .doc(qrCode)
          .get();

      if (!qrDoc.exists) {
        return {
          'success': false,
          'message': 'Cod QR invalid',
          'points': 0,
        };
      }

      // Actualizăm progresul utilizatorului
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('treasure_hunt')
          .doc('progress')
          .set({
        'currentLevel': currentLevel + 1,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Adăugăm punctele de loialitate
      final points = qrDoc.data()?['points'] ?? 0;
      await _firestore.collection('users').doc(userId).update({
        'points': FieldValue.increment(points),
      });

      return {
        'success': true,
        'message': 'Felicitări! Ai trecut la următorul nivel!',
        'points': points,
      };
    } catch (e) {
      print('Eroare la procesarea codului QR: \$e');
      return {
        'success': false,
        'message': 'A apărut o eroare. Încearcă din nou.',
        'points': 0,
      };
    }
  }
}
