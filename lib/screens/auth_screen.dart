import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:eli_tattoo_clienti/services/auth_service.dart';
import 'package:eli_tattoo_clienti/screens/home_screen.dart';
import 'package:eli_tattoo_clienti/screens/admin_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loading = false;

  void _signIn() async {
    setState(() => _loading = true);

    AuthService authService = AuthService();
    User? user = await authService.signInWithEmailAndPassword(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      String? role = await authService.getUserRole(user.uid);

      // 🔹 Verifică și creează colecția messages dacă nu există
      await _ensureMessagesCollection(user.uid);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => (role == "admin") ? AdminScreen() : HomeScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Autentificare eșuată. Verifică email-ul și parola.")),
      );
    }

    setState(() => _loading = false);
  }

  /// 🔹 Creează automat colecția `messages` pentru utilizatorii noi
  Future<void> _ensureMessagesCollection(String userId) async {
    final userMessagesRef = FirebaseFirestore.instance.collection("users").doc(userId).collection("messages");

    final snapshot = await userMessagesRef.limit(1).get();
    if (snapshot.docs.isEmpty) {
      await userMessagesRef.doc("placeholder").set({"text": "start chat"}); // Adaugă un document dummy
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: GlassContainer(
              width: MediaQuery.of(context).size.width * 0.85,
              height: 350,
              borderRadius: BorderRadius.circular(20),
              blur: 15,
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Autentificare",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInputField(emailController, "Email"),
                    const SizedBox(height: 10),
                    _buildInputField(passwordController, "Parolă", isPassword: true),
                    const SizedBox(height: 20),
                    _loading
                        ? const CircularProgressIndicator(color: Colors.amber)
                        : _buildLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintText, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _signIn,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text("Login"),
    );
  }
}
