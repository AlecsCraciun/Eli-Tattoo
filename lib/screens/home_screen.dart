import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'gdpr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  String? _userRole;
  Map<String, dynamic> _userStats = {};
  bool _isLoading = true;
  final ScrollController _statusScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      setState(() => _isLoading = true);
      await _checkAuthStatus();
      if (_user != null) {
        await _loadUserStats();
      }
    } finally {
      setState(() => _isLoading = false);
    }
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

  Future<void> _loadUserStats() async {
    if (_user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(_user!.uid)
          .get();
      
      final appointments = await FirebaseFirestore.instance
          .collection("appointments")
          .where("userId", isEqualTo: _user!.uid)
          .where("status", isEqualTo: "active")
          .get();

      final unreadMessages = await FirebaseFirestore.instance
          .collection("messages")
          .where("recipientId", isEqualTo: _user!.uid)
          .where("read", isEqualTo: false)
          .get();

      setState(() {
        _userStats = {
          "points": userDoc.get("points") ?? 0,
          "level": userDoc.get("level") ?? 1,
          "activeAppointments": appointments.docs.length,
          "unreadMessages": unreadMessages.docs.length,
          "vouchers": userDoc.get("vouchers") ?? [],
          "treasureProgress": userDoc.get("treasureProgress") ?? 0,
        };
      });
    } catch (e) {
      print("Error loading user stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: _initializeUser,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildLogo(),
                  const SizedBox(height: 20),
                  _buildStatusBar(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildMainButtons(),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.amber,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLogo() {
    return BounceInDown(
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
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: GlassContainer(
        borderRadius: BorderRadius.circular(15),
        blur: 10,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        child: SingleChildScrollView(
          controller: _statusScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildStatusItem(
                "Puncte",
                "${_userStats['points'] ?? 0}",
                Icons.star,
                Colors.amber,
              ),
              _buildStatusDivider(),
              _buildStatusItem(
                "Nivel",
                "${_userStats['level'] ?? 1}",
                Icons.trending_up,
                Colors.green,
              ),
              _buildStatusDivider(),
              _buildStatusItem(
                "Programări",
                "${_userStats['activeAppointments'] ?? 0}",
                Icons.calendar_today,
                Colors.blue,
              ),
              _buildStatusDivider(),
              _buildStatusItem(
                "Mesaje",
                "${_userStats['unreadMessages'] ?? 0}",
                Icons.mail,
                Colors.red,
              ),
              _buildStatusDivider(),
              _buildStatusItem(
                "Vouchere",
                "${(_userStats['vouchers'] as List?)?.length ?? 0}",
                Icons.card_giftcard,
                Colors.purple,
              ),
              _buildStatusDivider(),
              _buildStatusItem(
                "Treasure",
                "${_userStats['treasureProgress'] ?? 0}%",
                Icons.map,
                Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white.withOpacity(0.2),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
        children: [
          _buildCustomButton(context, 'Promoții', PromoScreen(), Icons.local_offer, false),
          _buildCustomButton(context, 'Portofoliu', PortfolioScreen(), Icons.image, false),
          _buildCustomButton(context, 'Servicii', ServicesScreen(), Icons.build, false),
          _buildCustomButton(context, 'Fidelizare', LoyaltyScreen(), Icons.star, true),
          _buildCustomButton(context, 'Chat', null, Icons.chat, true),
          _buildCustomButton(context, 'Treasure Hunt', TreasureHuntScreen(), Icons.map, true),
        ],
      ),
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
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.map, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.chat, color: Colors.white),
                  if ((_userStats['unreadMessages'] ?? 0) > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${_userStats['unreadMessages']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () => _navigateToChat(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                if (_userRole == "admin" || _userRole == "artist") {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GdprScreen()));
                }
              },
            ),
          ],
        ),
      ),
    );
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
}
