import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  _LoyaltyScreenState createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  MobileScannerController _qrController = MobileScannerController();
  final String userId = "USER_ID"; // Înlocuiește cu ID-ul real

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _buildPointsCard(),
              const SizedBox(height: 20),
              Expanded(child: _buildPointsHistory()),
              const SizedBox(height: 20),
              Expanded(child: _buildVouchersList()),
              const SizedBox(height: 20),
              _buildScanButton(),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 Card cu punctele acumulate
  Widget _buildPointsCard() {
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
                    const Text(
                      "Puncte Acumulate",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    FutureBuilder<DocumentSnapshot>(
                      future: _firestore.collection('loyalty_points').doc(userId).get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Text("0 Puncte", style: TextStyle(color: Colors.white, fontSize: 28));
                        }
                        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                        final points = data['total_points'] ?? 0;
                        return Text(
                          "$points Puncte",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        );
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

  /// 🔹 Istoric puncte
  Widget _buildPointsHistory() {
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
            child: FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('loyalty_points').doc(userId).get(),
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
                            trailing: Text(
                              "${entry['points']} Puncte",
                              style: TextStyle(color: entry['points'] >= 0 ? Colors.green : Colors.red),
                            ),
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

  /// 🔹 Vouchere revendicate
  Widget _buildVouchersList() {
    return FadeInUp(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GlassContainer(
              borderRadius: BorderRadius.circular(12),
              blur: 10,
              border: Border.all(width: 2, color: Colors.white.withOpacity(0.3)),
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.07)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: const Text(
                  "Aici vor apărea voucherele tale revendicate!",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').doc(userId).collection('vouchers').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final vouchers = snapshot.data!.docs;
                return vouchers.isEmpty
                    ? const Center(child: Text("Nu ai revendicat vouchere.", style: TextStyle(color: Colors.white)))
                    : ListView.builder(
                        itemCount: vouchers.length,
                        itemBuilder: (context, index) {
                          final voucher = vouchers[index].data() as Map<String, dynamic>;
                          return ListTile(
                            leading: Image.network(voucher['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                            title: Text(voucher['title'], style: const TextStyle(color: Colors.white)),
                            subtitle: Text("Revendicat pe: ${voucher['date']}", style: const TextStyle(color: Colors.grey)),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Buton Scanare QR
  Widget _buildScanButton() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: Colors.amber,
      child: const Icon(Icons.qr_code_scanner, size: 28, color: Colors.black),
    );
  }
}
