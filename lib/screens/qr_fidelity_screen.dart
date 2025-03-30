import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:glassmorphism/glassmorphism.dart';

class QrFidelityScreen extends StatefulWidget {
  const QrFidelityScreen({super.key});

  @override
  _QrFidelityScreenState createState() => _QrFidelityScreenState();
}

class _QrFidelityScreenState extends State<QrFidelityScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _qrData;
  String? _lastScannedBy;
  int? _points;
  String? _actionType;

  Future<void> _generateQR(String type) async {
    final amountText = _amountController.text;
    if (amountText.isEmpty || int.tryParse(amountText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Te rog introdu o sumă validă"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int amount = int.parse(amountText);
    if (amount < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Suma minimă este de 10 RON"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int points = (amount / 10).floor();
    final String qrId = const Uuid().v4();
    
    final qrPayload = {
      'qr_id': qrId,
      'points': points,
      'type': type,
      'amount': amount,
    };

    try {
      await FirebaseFirestore.instance.collection('generated_qr_codes').doc(qrId).set({
        'timestamp': DateTime.now(),
        'type': type,
        'points': points,
        'amount': amount,
        'status': 'active',
      });

      setState(() {
        _qrData = jsonEncode(qrPayload);
        _points = points;
        _actionType = type;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cod QR generat cu succes pentru ${points} puncte!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Eroare la generarea codului QR: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Stream<QuerySnapshot> _usedQRStream() {
    return FirebaseFirestore.instance
        .collection('used_qr_codes')
        .orderBy('timestamp', descending: true)
        .limit(50) // Limităm la ultimele 50 de intrări
        .snapshots();
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D4350), Color(0xFFA43931)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildQRGeneratorSection() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: _qrData != null ? 500 : 200,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.2),
        ],
      ),
      borderGradient: const LinearGradient(
        colors: [Colors.white54, Colors.white24],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Sumă cheltuită (RON)",
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: "Ex: 280",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateQR("add"),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Oferă Puncte"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateQR("remove"),
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text("Retrage Puncte"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_qrData != null && _points != null) ...[
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: QrImageView(
                  data: _qrData!,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${_actionType == 'add' ? 'Se oferă' : 'Se retrag'} $_points puncte",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 300,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.2),
        ],
      ),
      borderGradient: const LinearGradient(
        colors: [Colors.white54, Colors.white24],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Istoric Scanări",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usedQRStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nu există scanări înregistrate",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final timestamp = (data['timestamp'] as Timestamp).toDate();
                    final formatted = DateFormat("dd.MM.yyyy HH:mm").format(timestamp);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(
                          data['type'] == 'add' ? Icons.add_circle : Icons.remove_circle,
                          color: data['type'] == 'add' ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        title: Text(
                          "${data['points']} puncte ${data['type'] == 'add' ? 'adăugate' : 'retrase'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Scanat de: ${data['used_by'] ?? 'necunoscut'}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              formatted,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Administrare Fidelizare"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQRGeneratorSection(),
                  const SizedBox(height: 20),
                  _buildHistorySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
