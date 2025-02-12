import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/firestore_service.dart';

class QrScannerScreen extends StatefulWidget {
  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isEmpty) {
      _showDialog("Eroare", "Niciun cod QR detectat. Încearcă din nou.");
      return;
    }

    for (final barcode in barcodes) {
      if (barcode.rawValue == null) {
        _showDialog("Eroare", "Cod QR invalid.");
        return;
      }

      String scannedVoucherId = barcode.rawValue!;
      bool available = await FirestoreService().isVoucherAvailable(scannedVoucherId);

      if (available) {
        int rewardPoints = 50; // Puncte oferite pentru acest voucher
        await FirestoreService().saveVoucherScan(scannedVoucherId, rewardPoints);
        _showDialog("Succes!", "Ai revendicat voucherul cu succes și ai primit $rewardPoints puncte!");
      } else {
        _showDialog("Eroare!", "Acest voucher a fost deja revendicat.");
      }
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scanare Cod QR"),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                cameraController.start();
              },
              child: Text("Repornește scanarea"),
            ),
          ),
        ],
      ),
    );
  }
}
