import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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
  String? _actionType; // "add" sau "remove"

  Future<void> _generateQR(String type) async {
    final amountText = _amountController.text;
    if (amountText.isEmpty || int.tryParse(amountText) == null) return;

    final int amount = int.parse(amountText);
    final int points = (amount / 10).floor();
    final String qrId = const Uuid().v4();
    
    final qrPayload = {
      'qr_id': qrId,
      'points': points,
      'type': type,
    };

    await FirebaseFirestore.instance.collection('generated_qr_codes').doc(qrId).set({
      'timestamp': DateTime.now(),
      'type': type,
      'points': points,
    });

    setState(() {
      _qrData = jsonEncode(qrPayload);
      _points = points;
      _actionType = type;
    });
  }

  Stream<QuerySnapshot> _usedQRStream() {
    return FirebaseFirestore.instance
        .collection('used_qr_codes')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel - Fidelizare"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Sumă cheltuită de client:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Ex: 280",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateQR("add"),
                    icon: const Icon(Icons.add),
                    label: const Text("Oferă Puncte"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateQR("remove"),
                    icon: const Icon(Icons.remove),
                    label: const Text("Retrage Puncte"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_qrData != null && _points != null && _actionType != null) ...[
              Center(
                child: QrImageView(
                  data: _qrData!,
                  version: QrVersions.auto,
                  size: 200,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${_actionType == 'add' ? 'Oferă' : 'Retrage'} $_points puncte",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 30),
            const Text(
              "Istoric QR-uri folosite",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _usedQRStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final timestamp = (data['timestamp'] as Timestamp).toDate();
                      final formatted = DateFormat("dd.MM.yyyy HH:mm").format(timestamp);
                      return Card(
                        child: ListTile(
                          title: Text(formatted),
                          subtitle: Text("Scanat de: ${data['used_by'] ?? 'necunoscut'}"),
                          leading: Icon(
                            data['type'] == 'add' ? Icons.add_circle : Icons.remove_circle,
                            color: data['type'] == 'add' ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
