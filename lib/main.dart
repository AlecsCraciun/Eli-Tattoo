import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/treasure_hunt_screen.dart';
import 'screens/loyalty_screen.dart';
import 'screens/qr_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eli Tattoo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(), // Acces direct la HomeScreen fără autentificare
        '/home': (context) => HomeScreen(),
        '/treasure_hunt': (context) => TreasureHuntScreen(),
        '/fidelizare': (context) => LoyaltyScreen(),
        '/scan_qr': (context) => QrScannerScreen(),
      },
    );
  }
}
