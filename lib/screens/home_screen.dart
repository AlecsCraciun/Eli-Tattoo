import 'package:flutter/material.dart';
import 'promo_screen.dart';
import 'portfolio_screen.dart';
import 'services_screen.dart';
import 'loyalty_screen.dart';
import 'chat_screen.dart';
import 'treasure_hunt_screen.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundal imagine
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Conținutul paginii
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo plasat sus cu dimensiune dublată
              Container(
                width: 300,
                height: 300,
                margin: EdgeInsets.only(top: 60, bottom: 20),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Text(
                "Bine ai venit la Eli Tattoo Studio",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Butoanele centrate pe ecran cu imagini personalizate
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCustomButton(context, 'Promoții', 'assets/buttons/buton_programare.png', PromoScreen(), Icons.local_offer),
                      _buildCustomButton(context, 'Portofoliu', 'assets/buttons/buton_portofoliu.png', PortfolioScreen(), Icons.image),
                      _buildCustomButton(context, 'Servicii', 'assets/buttons/buton_servicii.png', ServicesScreen(), Icons.build),
                      _buildCustomButton(context, 'Fidelizare', 'assets/buttons/buton_fidelizare.png', LoyaltyScreen(), Icons.star),
                      _buildCustomButton(context, 'Chat', 'assets/buttons/buton_contact.png', ChatScreen(), Icons.chat),
                      _buildCustomButton(context, 'Treasure Hunt', 'assets/buttons/buton_treasure_hunt.png', TreasureHuntScreen(), Icons.map),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QrScannerScreen()),
          );
        },
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.qr_code_scanner, size: 28, color: Colors.white),
      ),
    );
  }

  Widget _buildCustomButton(BuildContext context, String text, String imagePath, Widget screen, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 300, // Dimensiunea butoanelor
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 5, color: Colors.black, offset: Offset(1, 1))
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
