import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Verifică dacă voucherul este disponibil
  Future<bool> isVoucherAvailable(String voucherId) async {
    DocumentReference voucherRef = _firestore.collection('treasure_hunt_rewards').doc(voucherId);
    DocumentSnapshot voucherDoc = await voucherRef.get();

    if (voucherDoc.exists) {
      return voucherDoc.get("claimed") == false;
    }
    return false;
  }

  // Salvăm voucherul scanat și îl adăugăm în contul utilizatorului
  Future<void> saveVoucherScan(String voucherId, int rewardPoints) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      DocumentReference userRef = _firestore.collection('users_roles').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        List<dynamic> vouchereReclamate = userDoc.get("vouchers_claimed") ?? [];

        if (!vouchereReclamate.contains(voucherId)) {
          // Salvăm scanarea voucherului
          await _firestore.collection('scanned_qr_codes').add({
            "user_id": userId,
            "voucher_id": voucherId,
            "timestamp": Timestamp.now()
          });

          // Adăugăm voucherul în contul utilizatorului
          await userRef.update({
            "vouchers_claimed": FieldValue.arrayUnion([voucherId])
          });

          // Actualizăm punctele de loialitate ale utilizatorului
          DocumentReference loyaltyRef = _firestore.collection('loyalty_points').doc(userId);
          DocumentSnapshot loyaltyDoc = await loyaltyRef.get();

          if (loyaltyDoc.exists) {
            await loyaltyRef.update({
              "points": FieldValue.increment(rewardPoints)
            });
          } else {
            await loyaltyRef.set({
              "user_id": userId,
              "points": rewardPoints
            });
          }

          print("Voucher scanat, adăugat la utilizator și punctele actualizate!");
        } else {
          print("Acest voucher a fost deja revendicat!");
        }
      }
    }
  }
}
