import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_settings/app_settings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:eli_tattoo/screens/legal/privacy_policy_screen.dart';
import 'package:eli_tattoo/screens/legal/terms_screen.dart';
import 'package:eli_tattoo/screens/legal/gdpr_rights_screen.dart';

class GdprScreen extends StatefulWidget {
  const GdprScreen({Key? key}) : super(key: key);

  @override
  _GdprScreenState createState() => _GdprScreenState();
}

class _GdprScreenState extends State<GdprScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  Map<String, dynamic> _userSettings = {};
  bool _isLoading = true;
  bool _allowPushNotifications = true;
  bool _allowEmailNotifications = true;
  bool _allowLocationTracking = true;
  bool _allowDataCollection = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
    _checkNotificationPermissions();
    _checkLocationPermission();
  }

  Future<void> _checkNotificationPermissions() async {
    if (!kIsWeb) {
      final settings = await _messaging.getNotificationSettings();
      setState(() {
        _allowPushNotifications = settings.authorizationStatus == AuthorizationStatus.authorized;
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    if (!kIsWeb) {
      final status = await Permission.location.status;
      setState(() {
        _allowLocationTracking = status.isGranted;
      });
    }
  }

  Future<void> _loadUserSettings() async {
    if (_user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();
        if (doc.exists) {
          setState(() {
            _userSettings = doc.data() ?? {};
            _allowEmailNotifications = _userSettings['allowEmail'] ?? true;
            _allowDataCollection = _userSettings['allowDataCollection'] ?? true;
          });
        }
      } catch (e) {
        _showErrorSnackBar('Eroare la încărcarea setărilor: $e');
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateNotificationSettings(bool value) async {
    if (!kIsWeb) {
      if (value) {
        final status = await _messaging.requestPermission();
        if (status.authorizationStatus == AuthorizationStatus.authorized) {
          await _updateSettings('allowPush', true);
        } else {
          await AppSettings.openAppSettings();
        }
      } else {
        await AppSettings.openAppSettings();
      }
      await _checkNotificationPermissions();
    } else {
      setState(() => _allowPushNotifications = value);
      await _updateSettings('allowPush', value);
    }
  }

  Future<void> _updateLocationSettings(bool value) async {
    if (!kIsWeb) {
      if (value) {
        final status = await Permission.location.request();
        if (status.isGranted) {
          await _updateSettings('allowLocation', true);
        } else {
          await AppSettings.openAppSettings();
        }
      } else {
        await AppSettings.openAppSettings();
      }
      await _checkLocationPermission();
    } else {
      setState(() => _allowLocationTracking = value);
      await _updateSettings('allowLocation', value);
    }
  }

  Future<void> _updateSettings(String setting, bool value) async {
    if (_user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({setting: value});
      _showSuccessSnackBar('Setările au fost actualizate');
    } catch (e) {
      _showErrorSnackBar('Eroare la actualizarea setărilor: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _downloadUserData() async {
    if (_user == null) return;
    
    try {
      setState(() => _isLoading = true);
      
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();
      
      final appointments = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: _user!.uid)
          .get();
      
      final loyaltyPoints = await FirebaseFirestore.instance
          .collection('loyalty')
          .doc(_user!.uid)
          .get();

      final allData = {
        'userData': userData.data(),
        'appointments': appointments.docs.map((doc) => doc.data()).toList(),
        'loyaltyPoints': loyaltyPoints.data(),
      };

      final jsonData = jsonEncode(allData);
      
      if (kIsWeb) {
        final blob = html.Blob([jsonData]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement()
          ..href = url
          ..style.display = 'none'
          ..download = 'my_data.json';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/my_data.json');
        await file.writeAsString(jsonData);
        await Share.shareFiles(
          [file.path],
          text: 'Datele mele de la Eli Tattoo',
        );
      }

      _showSuccessSnackBar('Datele au fost descărcate cu succes');
    } catch (e) {
      _showErrorSnackBar('Eroare la descărcarea datelor: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    if (_user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        title: const Text(
          'Confirmare Ștergere Cont',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Ești sigur că vrei să ștergi contul? Această acțiune este permanentă și nu poate fi anulată.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performAccountDeletion();
            },
            child: const Text(
              'Șterge Cont',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performAccountDeletion() async {
    try {
      setState(() => _isLoading = true);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .delete();

      final appointments = await FirebaseFirestore.instance
          .collection('appointments')
          .where('userId', isEqualTo: _user!.uid)
          .get();
      
      for (var doc in appointments.docs) {
        await doc.reference.delete();
      }

      await FirebaseFirestore.instance
          .collection('loyalty')
          .doc(_user!.uid)
          .delete();

      await _user!.delete();
      await FirebaseAuth.instance.signOut();

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      _showSuccessSnackBar('Contul a fost șters cu succes');
    } catch (e) {
      _showErrorSnackBar('Eroare la ștergerea contului: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Setări & GDPR', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        'Notificări',
                        [
                          _buildSwitchTile(
                            'Notificări Push',
                            'Primește notificări despre programări și oferte',
                            _allowPushNotifications,
                            _updateNotificationSettings,
                          ),
                          _buildSwitchTile(
                            'Notificări Email',
                            'Primește actualizări prin email',
                            _allowEmailNotifications,
                            (value) async {
                              setState(() => _allowEmailNotifications = value);
                              await _updateSettings('allowEmail', value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        'Permisiuni',
                        [
                          _buildSwitchTile(
                            'Locație',
                            'Permite accesul la locație pentru Treasure Hunt',
                            _allowLocationTracking,
                            _updateLocationSettings,
                          ),
                          _buildSwitchTile(
                            'Colectare Date',
                            'Permite colectarea datelor pentru îmbunătățirea serviciilor',
                            _allowDataCollection,
                            (value) async {
                              setState(() => _allowDataCollection = value);
                              await _updateSettings('allowDataCollection', value);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSection(
                        'Documente Legale',
                        [
                          _buildLinkTile(
                            'Politica de Confidențialitate',
                            'Vezi detalii despre cum îți protejăm datele',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrivacyPolicyScreen(),
                              ),
                            ),
                          ),
                          _buildLinkTile(
                            'Termeni și Condiții',
                            'Citește termenii și condițiile serviciului',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TermsScreen(),
                              ),
                            ),
                          ),
                          _buildLinkTile(
                            'Drepturi GDPR',
                            'Află despre drepturile tale conform GDPR',
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GdprRightsScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildDataSection(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(15),
      blur: 10,
      color: Colors.white.withOpacity(0.1),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.amber,
      ),
    );
  }

  Widget _buildLinkTile(String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: onTap,
    );
  }

    Widget _buildDataSection() {
    return GlassContainer(
      borderRadius: BorderRadius.circular(15),
      blur: 10,
      color: Colors.white.withOpacity(0.1),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Datele Tale',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDataButton(
              'Descarcă Datele Tale',
              'Primește o copie a tuturor datelor tale',
              Icons.download,
              _downloadUserData,
            ),
            const SizedBox(height: 8),
            _buildDataButton(
              'Șterge Contul',
              'Șterge permanent contul și toate datele asociate',
              Icons.delete_forever,
              _deleteAccount,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDataButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive
                ? Colors.red.withOpacity(0.3)
                : Colors.white.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : Colors.white,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? Colors.red : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDestructive
                          ? Colors.red.withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
