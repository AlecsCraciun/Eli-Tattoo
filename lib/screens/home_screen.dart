import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:ui';
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  User? _user;
  String? _userRole;
  Map<String, dynamic> _userStats = {};
  bool _isLoading = true;
  bool _hasError = false;
  final ScrollController _statusScrollController = ScrollController();
  List<StreamSubscription> _subscriptions = [];
  late AnimationController _backgroundAnimationController;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _initializeUser();
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    _loadingTimer?.cancel();
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _statusScrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      _loadingTimer?.cancel();
      _loadingTimer = Timer(const Duration(seconds: 10), () {
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      });

      _user = FirebaseAuth.instance.currentUser;
      if (_user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .doc(_user!.uid)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userRole = userData['role'] ?? "user";
          });
        }
        await _loadUserStats();
        _setupUserStatsStream();
      }

      _loadingTimer?.cancel();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      print("Error in _initializeUser: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _loadUserStats() async {
    if (_user == null) return;

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final loyaltyDoc = await FirebaseFirestore.instance
          .collection("loyalty_points")
          .doc(_user!.uid)
          .get();
      
      int totalPoints = 0;
      if (loyaltyDoc.exists) {
        final data = loyaltyDoc.data() as Map<String, dynamic>;
        totalPoints = data['total_points'] ?? 0;
      }

      final appointments = await FirebaseFirestore.instance
          .collection("appointments")
          .where("clientEmail", isEqualTo: _user!.email)
          .where("date", isGreaterThanOrEqualTo: startOfDay)
          .get();

      final unreadMessages = await FirebaseFirestore.instance
          .collection("chats")
          .doc(_user!.uid)
          .collection("messages")
          .where("receiverId", isEqualTo: _user!.uid)
          .where("read", isEqualTo: false)
          .get();

      if (mounted) {
        setState(() {
          _userStats = {
            "points": totalPoints,
            "activeAppointments": appointments.docs.length,
            "unreadMessages": unreadMessages.docs.length,
            "vouchers": _userStats["vouchers"] ?? [],
          };
        });
      }
    } catch (e) {
      print("Error loading user stats: $e");
    }
  }

  void _setupUserStatsStream() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    if (_user != null) {
      _subscriptions.add(
        FirebaseFirestore.instance
            .collection("loyalty_points")
            .doc(_user!.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists && mounted) {
            final data = snapshot.data() as Map<String, dynamic>;
            setState(() {
              _userStats["points"] = data['total_points'] ?? 0;
            });
          }
        })
      );

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      _subscriptions.add(
        FirebaseFirestore.instance
            .collection("appointments")
            .where("clientEmail", isEqualTo: _user!.email)
            .where("date", isGreaterThanOrEqualTo: startOfDay)
            .snapshots()
            .listen((snapshot) {
          if (mounted) {
            setState(() {
              _userStats["activeAppointments"] = snapshot.docs.length;
            });
          }
        })
      );

      _subscriptions.add(
        FirebaseFirestore.instance
            .collection("chats")
            .doc(_user!.uid)
            .collection("messages")
            .where("receiverId", isEqualTo: _user!.uid)
            .where("read", isEqualTo: false)
            .snapshots()
            .listen((snapshot) {
          if (mounted) {
            setState(() {
              _userStats["unreadMessages"] = snapshot.docs.length;
            });
          }
        })
      );
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
            AnimatedBuilder(
              animation: _backgroundAnimationController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        HSLColor.fromAHSL(1.0, _backgroundAnimationController.value * 360, 0.6, 0.2).toColor(),
                        HSLColor.fromAHSL(1.0, (_backgroundAnimationController.value * 360 + 60) % 360, 0.6, 0.3).toColor(),
                      ],
                    ),
                  ),
                );
              },
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              _buildAnimatedLogo(),
                              const Spacer(),
                              _buildStatusBar(),
                              const SizedBox(height: 20),
                              _buildMainButtons(),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading || _hasError)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black26,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoading)
                          const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        if (_hasError) ...[
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 50,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'A apărut o eroare la încărcare',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _initializeUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_hasError ? 'Reîncearcă' : 'Anulează'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAnimatedLogo() {
    return BounceInDown(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    if (_user == null) return Container();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(20),
          blur: 20,
          color: Colors.white.withOpacity(0.1),
          child: SizedBox(
            height: 85,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildStatusItem(
                    "Puncte",
                    "${_userStats['points'] ?? 0}",
                    Icons.star_rounded,
                    Colors.amber.shade300,
                  ),
                ),
                _buildStatusDivider(),
                Expanded(
                  child: _buildStatusItem(
                    "Programări",
                    "${_userStats['activeAppointments'] ?? 0}",
                    Icons.event_available_rounded,
                    Colors.teal.shade300,
                  ),
                ),
                _buildStatusDivider(),
                Expanded(
                  child: _buildStatusItem(
                    "Mesaje",
                    "${_userStats['unreadMessages'] ?? 0}",
                    Icons.mark_chat_unread_rounded,
                    Colors.pink.shade300,
                  ),
                ),
                _buildStatusDivider(),
                Expanded(
                  child: _buildStatusItem(
                    "Vouchere",
                    "${(_userStats['vouchers'] ?? []).length}",
                    Icons.card_giftcard_rounded,
                    Colors.purple.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildCustomButton(context, 'Promoții', PromoScreen(), Icons.local_offer_rounded, false)),
              const SizedBox(width: 10),
              Expanded(child: _buildCustomButton(context, 'Portofoliu', PortfolioScreen(), Icons.photo_library_rounded, false)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildCustomButton(context, 'Servicii', ServicesScreen(), Icons.design_services_rounded, false)),
              const SizedBox(width: 10),
              Expanded(child: _buildCustomButton(context, 'Fidelizare', LoyaltyScreen(), Icons.star_rounded, true)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildCustomButton(context, 'Chat', null, Icons.chat_rounded, true)),
              const SizedBox(width: 10),
              Expanded(child: _buildCustomButton(context, 'Treasure Hunt', TreasureHuntScreen(), Icons.explore_rounded, true)),
            ],
          ),
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
        borderRadius: BorderRadius.circular(15),
        blur: 20,
        color: Colors.white.withOpacity(0.1),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
          ),
          child: SafeArea(
            child: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomBarItem(Icons.phone_rounded, () async {
                      final phoneUri = Uri.parse('tel:+40787229574');
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      }
                    }),
                    _buildBottomBarItem(Icons.map_rounded, () async {
                      final mapsUri = Uri.parse('https://www.google.com/maps/dir//Eli+Tattoo+Studio+Strada+Republicii+25+Brașov+500030/@45.643265,25.5922325,16z');
                      if (await canLaunchUrl(mapsUri)) {
                        await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
                      }
                    }),
                    _buildBottomBarItem(Icons.chat_rounded, () async {
                      final whatsappUri = Uri.parse('whatsapp://send?phone=+40787229574');
                      if (await canLaunchUrl(whatsappUri)) {
                        await launchUrl(whatsappUri);
                      }
                    }, showBadge: (_userStats['unreadMessages'] ?? 0) > 0),
                    _buildBottomBarItem(Icons.settings_rounded, () {
                      if (_userRole == "admin" || _userRole == "artist") {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AdminScreen()));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const GdprScreen()));
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBarItem(IconData icon, VoidCallback onTap, {bool showBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            if (showBadge)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
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
