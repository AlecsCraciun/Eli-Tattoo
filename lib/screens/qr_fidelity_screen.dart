import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class QRFidelityScreen extends StatefulWidget {
  const QRFidelityScreen({super.key});

  @override
  _QRFidelityScreenState createState() => _QRFidelityScreenState();
}

class _QRFidelityScreenState extends State<QRFidelityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _amountController = TextEditingController();
  bool _isAddingPoints = true;

  Future<void> _generateQRCode() async {
    if (_amountController.text.isEmpty) return;
    double amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    String qrCode = const Uuid().v4();
    String type = _isAddingPoints ? "add" : "withdraw";

    final qrPayload = jsonEncode({
      "qr_id": qrCode,
      "points": amount.round(),
      "type": type,
    });

    try {
      await _firestore.collection("qr_codes").add({
        "code": qrPayload,
        "type": type,
        "amount": amount,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Cod QR generat cu succes!"),
        backgroundColor: Colors.green,
      ));

      _amountController.clear();
    } catch (e) {
      print("Eroare la generare QR: $e");
    }
  }

  Future<void> _deleteQRCode(String docId) async {
    try {
      await _firestore.collection("qr_codes").doc(docId).delete();
    } catch (e) {
      print("Eroare la ștergere QR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Generare QR Fidelizare")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Introduceți suma / punctele",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() => _isAddingPoints = true);
                    _generateQRCode();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Oferă Puncte"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _isAddingPoints = false);
                    _generateQRCode();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Retrage Puncte"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection("qr_codes").orderBy("createdAt", descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final qrCodes = snapshot.data!.docs;

                  if (qrCodes.isEmpty) {
                    return const Center(child: Text("Nu există coduri QR generate."));
                  }

                  return ListView.builder(
                    itemCount: qrCodes.length,
                    itemBuilder: (context, index) {
                      final doc = qrCodes[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final String payload = data["code"];
                      final decoded = jsonDecode(payload);
                      final String qrCode = decoded["qr_id"];
                      final double amount = data["amount"];
                      final String type = data["type"];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: QrImageView(
                            data: payload,
                            size: 50,
                          ),
                          title: Text("${type == 'add' ? 'Adăugat' : 'Retras'}: ${amount.toStringAsFixed(2)} RON"),
                          subtitle: Text("Cod: $qrCode"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteQRCode(doc.id),
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
      ),
    );
  }
}
