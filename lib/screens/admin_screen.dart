import 'package:flutter/material.dart';
import 'gallery_admin_screen.dart';
import 'vouchers_admin_screen.dart';
import 'promotions_admin_screen.dart';
import 'treasure_hunt_admin_screen.dart';
import 'chat_admin_screen.dart';
import 'qr_fidelity_screen.dart';
import 'add_artist_screen.dart';

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administrare")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAdminButton(context, "Administrare Galerii", GalleryAdminScreen()),
            const SizedBox(height: 20),
            _buildAdminButton(context, "Administrare Vouchere Treasure Hunt", VouchersAdminScreen()),
            const SizedBox(height: 20),
            _buildAdminButton(context, "Administrare Promoții", PromotionsAdminScreen()),
            const SizedBox(height: 20),
            _buildAdminButton(context, "Administrare Treasure Hunt", TreasureHuntAdminScreen()),
            const SizedBox(height: 20),
            _buildAdminButton(context, "Administrare Chat", ChatAdminScreen()),
            const SizedBox(height: 20),
            _buildAdminButton(context, "Generare QR Fidelizare", QRFidelityScreen()),
            const SizedBox(height: 20),
            _buildAdminButton(context, "Adaugă Artiști Noi", AddArtistScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminButton(BuildContext context, String text, Widget screen) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Text(text),
    );
  }
}
