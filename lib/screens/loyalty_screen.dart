import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'dart:convert';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  _LoyaltyScreenState createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MobileScannerController _qrController = MobileScannerController();
  bool _isScanning = false;

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  Future<void> _processQRCode(String rawValue) async {
    if (_isScanning) return;
    setState(() => _isScanning = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("Utilizator neautentificat.");

      final Map<String, dynamic> data = jsonDecode(rawValue);
      final String qrId = data['qr_id'];
      final int points = data['points'];
      final String type = data['type']; // 'add' sau 'remove'

      final usedRef = _firestore.collection('used_qr_codes').doc(qrId);
      final usedSnap = await usedRef.get();

      if (usedSnap.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Codul QR a fost deja folosit!')),
        );
        return;
      }

      final loyaltyRef = _firestore.collection('loyalty_points').doc(user.uid);
      final loyaltySnap = await loyaltyRef.get();

      int currentPoints = 0;
      List history = [];

      if (loyaltySnap.exists) {
        final data = loyaltySnap.data() as Map<String, dynamic>;
        currentPoints = (data['total_points'] ?? 0);
        history = data['history'] ?? [];
      }

      final newPoints = type == 'add' ? currentPoints + points : currentPoints - points;
      final now = DateTime.now();

      history.add({
        'points': type == 'add' ? points : -points,
        'date': "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}"
      });

      await loyaltyRef.set({
        'total_points': newPoints,
        'history': history,
      });

      await usedRef.set({'used_by': user.uid, 'timestamp': now});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${type == 'add' ? 'Ai primit' : 'Ți s-au retras'} $points puncte.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare: $e')),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Trebuie să fii autentificat pentru a vedea această pagină.")),
      );
    }
    final userId = user.uid;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Fidelizare", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              const SizedBox(height: 80),
              _buildPointsCard(userId),
              const SizedBox(height: 20),
              Expanded(child: _buildPointsHistory(userId)),
              const SizedBox(height: 20),
              _buildScanButton(),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(String userId) {
    return BounceInDown(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(20),
          blur: 10,
          border: Border.all(width: 2, color: Colors.white.withOpacity(0.3)),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.07)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Puncte Acumulate", style: TextStyle(color: Colors.white, fontSize: 22)),
                    StreamBuilder<DocumentSnapshot>(
                      stream: _firestore.collection('loyalty_points').doc(userId).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text("0 Puncte", style: TextStyle(color: Colors.white, fontSize: 28));
                        }
                        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                        final points = data['total_points'] ?? 0;
                        return Text("$points Puncte", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsHistory(String userId) {
    return FadeInUp(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(20),
          blur: 10,
          border: Border.all(width: 2, color: Colors.white.withOpacity(0.3)),
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.07)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('loyalty_points').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text("Nu există istoric de puncte.", style: TextStyle(color: Colors.white)));
                }
                final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final history = List<Map<String, dynamic>>.from(data['history'] ?? []);
                return history.isEmpty
                    ? const Center(child: Text("Nu există istoric de puncte.", style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final entry = history[index];
                          return ListTile(
                            title: Text(entry['date'], style: const TextStyle(color: Colors.white)),
                            trailing: Text("${entry['points']} Puncte", style: TextStyle(color: entry['points'] >= 0 ? Colors.green : Colors.red)),
                          );
                        },
                      );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: SizedBox(
              height: 300,
              child: MobileScanner(
                controller: _qrController,
                onDetect: (capture) {
                  final code = capture.barcodes.firstOrNull?.rawValue;
                  if (code != null) {
                    Navigator.of(context).pop();
                    _processQRCode(code);
                  }
                },
              ),
            ),
          ),
        );
      },
      backgroundColor: Colors.amber,
      child: const Icon(Icons.qr_code_scanner, size: 28, color: Colors.black),
    );
  }
}
