import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class VouchersAdminScreen extends StatefulWidget {
  @override
  _VouchersAdminScreenState createState() => _VouchersAdminScreenState();
}

class _VouchersAdminScreenState extends State<VouchersAdminScreen> {
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  // 🔹 Generează un cod voucher unic
  String _generateVoucherCode() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(
      List.generate(8, (index) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // 🔹 Adaugă un voucher nou în Firestore
  Future<void> _addVoucher() async {
    if (_valueController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Completează toate câmpurile!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String code = _generateVoucherCode();
      await FirebaseFirestore.instance.collection("vouchere").add({
        "code": code,
        "value": _valueController.text,
        "description": _descriptionController.text,
        "createdAt": FieldValue.serverTimestamp(),
      });

      _valueController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Voucher adăugat cu succes!"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Eroare la adăugare: $e"),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔹 Șterge un voucher din Firestore
  Future<void> _deleteVoucher(String docId) async {
    try {
      await FirebaseFirestore.instance.collection("vouchere").doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Voucher șters cu succes!"),
        backgroundColor: Colors.red,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Eroare la ștergere: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administrare Vouchere Treasure Hunt")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(labelText: "Valoare Voucher"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Descriere Voucher"),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _addVoucher,
                    icon: const Icon(Icons.add),
                    label: const Text("Adaugă Voucher"),
                  ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("vouchere").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var vouchers = snapshot.data!.docs;
                  if (vouchers.isEmpty) {
                    return const Center(child: Text("Nu există vouchere."));
                  }

                  return ListView.builder(
                    itemCount: vouchers.length,
                    itemBuilder: (context, index) {
                      var doc = vouchers[index];
                      String code = doc["code"];
                      String value = doc["value"];
                      String description = doc["description"];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text("Voucher: $code"),
                          subtitle: Text("Valoare: $value | $description"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteVoucher(doc.id),
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
