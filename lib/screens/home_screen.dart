import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'promo_screen.dart';
import 'portfolio_screen.dart';
import 'services_screen.dart';
import 'loyalty_screen.dart';
import 'chat_screen.dart';
import 'treasure_hunt_screen.dart';
import 'qr_scanner_screen.dart';
import 'login_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

        setState(() {
          _user = user;
          _userRole = userDoc.exists ? userDoc.get("role") : "user";
        });
      } else {
        setState(() {
          _user = null;
          _userRole = null;
        });
      }
    });
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Nu se poate deschide $url';
    }
  }

  void _navigateWithAuth(BuildContext context, Widget screen) {
    if (_user == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Eli Tattoo Studio', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_user != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                backgroundImage: _user!.photoURL != null && _user!.photoURL!.isNotEmpty
                    ? NetworkImage(_user!.photoURL!)
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                radius: 18,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
              },
            ),
          ] else
            IconButton(
              icon: const Icon(Icons.login, color: Colors.white),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.amber),
              child: Text(
                'Meniu Cont',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profilul Meu'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Setări'),
              onTap: () {},
            ),
            if (_userRole == "admin" || _userRole == "artist") // ✅ Afișează doar pentru Admin/Artist
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Administrează'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen()));
                },
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              BounceInDown(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FadeIn(
                child: const Text(
                  "Eli Tattoo Studio",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 10, color: Colors.black, offset: Offset(2, 2))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildCustomButton(context, 'Promoții', PromoScreen(), Icons.local_offer),
                      _buildCustomButton(context, 'Portofoliu', PortfolioScreen(), Icons.image),
                      _buildCustomButton(context, 'Servicii', ServicesScreen(), Icons.build),
                      _buildAuthButton(context, 'Fidelizare', LoyaltyScreen(), Icons.star),
                      _buildAuthButton(context, 'Chat', ChatScreen(), Icons.chat),
                      _buildAuthButton(context, 'Treasure Hunt', TreasureHuntScreen(), Icons.map),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton(BuildContext context, String text, Widget screen, IconData icon) {
    return FadeInUp(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
        child: _buildGlassButton(text, icon),
      ),
    );
  }

  Widget _buildAuthButton(BuildContext context, String text, Widget screen, IconData icon) {
    return FadeInUp(
      child: GestureDetector(
        onTap: () => _navigateWithAuth(context, screen),
        child: _buildGlassButton(text, icon),
      ),
    );
  }

  Widget _buildGlassButton(String text, IconData icon) {
    return GlassContainer(
      width: double.infinity,
      height: 90,
      borderRadius: BorderRadius.circular(18),
      blur: 12,
      border: Border.all(width: 2, color: Colors.white.withOpacity(0.3)),
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.15),
          Colors.white.withOpacity(0.07),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowStrength: 10,
      shadowColor: Colors.black.withOpacity(0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(blurRadius: 5, color: Colors.black, offset: Offset(1, 1))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
