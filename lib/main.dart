import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/treasure_hunt_screen.dart';
import 'screens/loyalty_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/chat_users_screen.dart'; // 🔹 Import corect pentru lista de conversații
import 'screens/services_screen.dart';
import 'screens/tatuaje_screen.dart';
import 'screens/portofoliu_blanca_screen.dart';
import 'screens/laser_removal_screen.dart';
import 'screens/rate_tbi_screen.dart';
import 'screens/admin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eli Tattoo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/treasure_hunt': (context) => TreasureHuntScreen(),
        '/fidelizare': (context) => LoyaltyScreen(),
        '/scan_qr': (context) => QRScannerScreen(),
        '/chat': (context) {
          final user = FirebaseAuth.instance.currentUser;
          return user != null ? ChatUsersScreen() : const HomeScreen();

        },
        '/chat_users': (context) => const ChatUsersScreen(), // 🔹 Lista de conversații pentru artiști/admini
        '/services': (context) => const ServicesScreen(),
        '/tatuaje': (context) => const TatuajeScreen(),
        '/portofoliu_blanca': (context) => const PortofoliuBlancaScreen(),
        '/laser_removal': (context) => const LaserRemovalScreen(),
        '/rate_tbi': (context) => const RateTBIScreen(),
        '/admin': (context) => AdminScreen(),
      },
    );
  }
}
