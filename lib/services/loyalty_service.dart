// lib/services/loyalty_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obține punctele utilizatorului
  Stream<DocumentSnapshot> getUserPoints(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  // Adaugă puncte pentru un serviciu
  Future<void> addServicePoints({
    required String userId,
    required String serviceType,
    required double serviceAmount,
  }) async {
    // Calculăm punctele (1 punct la fiecare 10 RON)
    int pointsToAdd = (serviceAmount / 10).floor();

    await _firestore.collection('users').doc(userId).set({
      'points': FieldValue.increment(pointsToAdd),
      'lastUpdate': FieldValue.serverTimestamp(),
      'history': FieldValue.arrayUnion([
        {
          'date': DateTime.now(),
          'type': 'earn',
          'points': pointsToAdd,
          'service': serviceType,
          'amount': serviceAmount,
        }
      ]),
    }, SetOptions(merge: true));
  }

  // Folosește puncte pentru o recompensă
  Future<bool> usePointsForReward({
    required String userId,
    required String rewardId,
    required int pointsCost,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final currentPoints = userDoc.data()?['points'] ?? 0;

      if (currentPoints < pointsCost) {
        return false;
      }

      await _firestore.collection('users').doc(userId).set({
        'points': FieldValue.increment(-pointsCost),
        'lastUpdate': FieldValue.serverTimestamp(),
        'history': FieldValue.arrayUnion([
          {
            'date': DateTime.now(),
            'type': 'redeem',
            'points': -pointsCost,
            'rewardId': rewardId,
          }
        ]),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Eroare la folosirea punctelor: $e');
      return false;
    }
  }

  // Obține istoricul punctelor
  Stream<QuerySnapshot> getPointsHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('history')
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Obține recompensele disponibile
  Stream<QuerySnapshot> getAvailableRewards() {
    return _firestore
        .collection('rewards')
        .where('isActive', isEqualTo: true)
        .orderBy('pointsCost')
        .snapshots();
  }
}
