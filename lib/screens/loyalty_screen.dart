import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  _LoyaltyScreenState createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _qrController;
  bool isScanning = false;
  final String userId = "USER_ID"; // 🔹 Înlocuiește cu ID-ul real al utilizatorului autentificat

  void _onQRViewCreated(QRViewController controller) {
    _qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isScanning) {
        setState(() => isScanning = true);
        _validateQRCode(scanData.code);
      }
    });
  }

  void _validateQRCode(String? code) async {
    if (code == null) return;
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isScanning = false);
  }

  @override
  void dispose() {
    _qrController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Fidelizare", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 20),
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

  /// 🔹 Afișează punctele acumulate ale utilizatorului
  Widget _buildPointsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text(
            "Puncte Acumulate",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 10),
          FutureBuilder<DocumentSnapshot>(
            future: _firestore.collection('loyalty_points').doc(userId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                print("🔥 Eroare Firestore: ${snapshot.error}");
                return const Text("Eroare la încărcarea punctelor", style: TextStyle(color: Colors.red));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                print("🔥 DEBUG: Nu există document pentru userId: $userId");
                return const Text("0 Puncte", style: TextStyle(color: Colors.white, fontSize: 24));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
              print("🔥 DEBUG Firestore Data: $data"); // 🟢 ADĂUGAT PENTRU VERIFICARE
              final points = data['total_points'] ?? 0;

              return Text(
                "$points Puncte",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 Afișează istoricul punctelor acumulate și consumate
  Widget _buildPointsHistory() {
    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('loyalty_points').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          print("🔥 Eroare Firestore: ${snapshot.error}");
          return const Center(child: Text("Eroare la încărcarea istoricului.", style: TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          print("🔥 DEBUG: Nu există istoric pentru userId: $userId");
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
                    title: Text(entry['type'], style: const TextStyle(color: Colors.white)),
                    subtitle: Text(entry['date'], style: const TextStyle(color: Colors.grey)),
                    trailing: Text(
                      "${entry['points']} Puncte",
                      style: TextStyle(color: entry['points'] >= 0 ? Colors.green : Colors.red),
                    ),
                  );
                },
              );
      },
    );
  }

  /// 🔹 Afișează lista voucherelor revendicate
  Widget _buildVouchersList() {
    return StreamBuilder<QuerySnapshot>(
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
                  return Card(
                    color: Colors.black.withOpacity(0.8),
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ListTile(
                      leading: Image.network(voucher['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                      title: Text(voucher['title'], style: const TextStyle(color: Colors.white)),
                      subtitle: Text("Revendicat pe: ${voucher['date']}", style: const TextStyle(color: Colors.grey)),
                    ),
                  );
                },
              );
      },
    );
  }

  /// 🔹 Buton Scanare QR
  Widget _buildScanButton() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        )),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.purpleAccent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.6), blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              "Scanează QR",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
