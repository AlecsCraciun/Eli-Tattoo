import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  String _errorMessage = '';
  bool _isLoading = false;

  // 🔹 Autentificare cu email și parolă
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Completează toate câmpurile!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = await _authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // 🔹 Verifică rolul utilizatorului din Firestore
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

        String role = userDoc.exists ? (userDoc["role"] ?? "user") : "user";

        print("🔥 Autentificare reușită! UID: ${user.uid}, Rol: $role");

        if (role == "admin") {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        setState(() => _errorMessage = "Email sau parolă incorectă!");
      }
    } catch (e) {
      print("❌ Eroare autentificare: $e");
      setState(() => _errorMessage = "Eroare autentificare: $e");
    }

    setState(() => _isLoading = false);
  }

  // 🔹 Înregistrare utilizator nou
  Future<void> _register() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = "Completează toate câmpurile!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? user = await _authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        // 🔹 Adaugă user-ul în Firestore
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "email": user.email,
          "role": "user",
          "uid": user.uid,
        });

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _errorMessage = "Email deja folosit sau parolă prea scurtă!");
      }
    } catch (e) {
      print("❌ Eroare înregistrare: $e");
      setState(() => _errorMessage = "Eroare înregistrare: $e");
    }

    setState(() => _isLoading = false);
  }

  // 🔹 Autentificare cu Google
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          setState(() => _isLoading = false);
          return;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      User? user = userCredential.user;
      if (user != null) {
        // 🔹 Verifică dacă userul există deja în Firestore
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
            "email": user.email,
            "role": "user",
            "uid": user.uid,
          });
        }

        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print("❌ Eroare Google Sign-In: $e");
      setState(() => _errorMessage = "Autentificare cu Google eșuată.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Autentificare", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email"),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _passwordFocus.requestFocus(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Parolă"),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text("Autentificare"),
                    ),
                    ElevatedButton(
                      onPressed: _register,
                      child: const Text("Înregistrare"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: const Icon(Icons.login, color: Colors.white),
                      label: const Text("Autentificare cu Google"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
