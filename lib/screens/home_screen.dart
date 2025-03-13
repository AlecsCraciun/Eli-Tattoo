import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'promo_screen.dart';
import 'portfolio_screen.dart';
import 'services_screen.dart';
import 'loyalty_screen.dart';
import 'chat_screen.dart';
import 'chat_users_screen.dart';
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

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void _navigateToChat(BuildContext context) {
    if (_user == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else if (_userRole == "admin" || _userRole == "artist") {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatUsersScreen()));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatId: _user!.uid,
            userName: "Eli Tattoo Team",
          ),
        ),
      );
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.amber),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80), // 🔹 Coborâm logo-ul
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
              const SizedBox(height: 30), // 🔹 Coborâm butoanele principale
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.2, // 🔹 Butoanele mai joase
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildCustomButton(context, 'Promoții', PromoScreen(), Icons.local_offer, false),
                      _buildCustomButton(context, 'Portofoliu', PortfolioScreen(), Icons.image, false),
                      _buildCustomButton(context, 'Servicii', ServicesScreen(), Icons.build, false),
                      _buildCustomButton(context, 'Fidelizare', LoyaltyScreen(), Icons.star, true),
                      _buildCustomButton(context, 'Chat', null, Icons.chat, true),
                      _buildCustomButton(context, 'Treasure Hunt', TreasureHuntScreen(), Icons.map, true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCustomButton(BuildContext context, String label, Widget? screen, IconData icon, bool requiresAuth) {
    return GestureDetector(
      onTap: () {
        if (requiresAuth && _user == null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
        } else if (label == 'Chat') {
          _navigateToChat(context);
        } else if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        }
      },
      child: GlassContainer(
        width: double.infinity,
        height: 60, // 🔹 Reducem înălțimea butoanelor
        borderRadius: BorderRadius.circular(12),
        blur: 5,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.black54,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(icon: const Icon(Icons.phone, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.map, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chat, color: Colors.white), onPressed: () => _navigateToChat(context)),
          IconButton(icon: const Icon(Icons.account_circle, color: Colors.white), onPressed: () => Scaffold.of(context).openDrawer()),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.amber,
            ),
            child: Text(
              _user != null ? _user!.email ?? "Cont" : "Cont Neautentificat",
              style: const TextStyle(color: Colors.white, fontSize: 20),
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
          if (_userRole == "admin" || _userRole == "artist")
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.amber),
              title: const Text("Administrează"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen()));
              },
            ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
