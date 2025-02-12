import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Metodă pentru login cu email și parolă
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

  // Metodă pentru logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Metodă pentru verificarea rolului utilizatorului
  Future<String?> getUserRole(String email) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users_roles').doc(email).get();
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
}
