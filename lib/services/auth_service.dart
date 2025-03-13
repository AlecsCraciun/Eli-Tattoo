import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Înregistrare utilizator nou cu email și parolă
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // 🔹 Crează documentul utilizatorului în Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'role': 'user', // Implicit toți utilizatorii noi sunt "user"
          'points': 0,
          'vouchers': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print("Eroare înregistrare: $e");
      return null;
    }
  }

  // ✅ Autentificare utilizator
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } catch (e) {
      print("Eroare autentificare: $e");
      return null;
    }
  }

  // ✅ Obține rolul utilizatorului din Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc['role'];
      } else {
        return null;
      }
    } catch (e) {
      print("Eroare la preluarea rolului: $e");
      return null;
    }
  }

  // ✅ Deconectare utilizator
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
