import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FidelizarePage extends StatefulWidget {
  @override
  _FidelizarePageState createState() => _FidelizarePageState();
}

class _FidelizarePageState extends State<FidelizarePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _lastScannedCode = '';

  void _scanQR(String code) async {
    if (_lastScannedCode == code) return;
    setState(() => _lastScannedCode = code);

    User? user = _auth.currentUser;
    if (user != null) {
      DocumentReference userRef = _firestore.collection('users').doc(user.uid);

      try {
        await _firestore.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(userRef);

          if (!snapshot.exists) {
            transaction.set(userRef, {'points': 10});
          } else {
            transaction.update(userRef, {'points': FieldValue.increment(10)});
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Puncte adăugate!')),
        );
      } catch (e) {
        print("Eroare la actualizarea punctelor: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la adăugarea punctelor!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fidelizare - Scanare QR')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (barcode, args) {
                if (barcode.rawValue != null) {
                  _scanQR(barcode.rawValue!);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _lastScannedCode.isEmpty ? 'Scanează un cod QR' : 'Ultimul scan: $_lastScannedCode',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
