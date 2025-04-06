import 'package:flutter/material.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class GdprScreen extends StatefulWidget {
  const GdprScreen({Key? key}) : super(key: key);

  @override
  _GdprScreenState createState() => _GdprScreenState();
}

class _GdprScreenState extends State<GdprScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> _userSettings = {};
  bool _isLoading = true;

  // Setări pentru notificări și permisiuni
  bool _allowPushNotifications = true;
  bool _allowEmailNotifications = true;
  bool _allowLocationTracking = true;
  bool _allowDataCollection = true;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
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
            _allowPushNotifications = _userSettings['allowPush'] ?? true;
            _allowEmailNotifications = _userSettings['allowEmail'] ?? true;
            _allowLocationTracking = _userSettings['allowLocation'] ?? true;
            _allowDataCollection = _userSettings['allowDataCollection'] ?? true;
          });
        }
      } catch (e) {
        print('Eroare la încărcarea setărilor: $e');
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateSettings(String setting, bool value) async {
    if (_user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({setting: value});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setările au fost actualizate'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la actualizarea setărilor: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                            (value) {
                              setState(() => _allowPushNotifications = value);
                              _updateSettings('allowPush', value);
                            },
                          ),
                          _buildSwitchTile(
                            'Notificări Email',
                            'Primește actualizări prin email',
                            _allowEmailNotifications,
                            (value) {
                              setState(() => _allowEmailNotifications = value);
                              _updateSettings('allowEmail', value);
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
                            (value) {
                              setState(() => _allowLocationTracking = value);
                              _updateSettings('allowLocation', value);
                            },
                          ),
                          _buildSwitchTile(
                            'Colectare Date',
                            'Permite colectarea datelor pentru îmbunătățirea serviciilor',
                            _allowDataCollection,
                            (value) {
                              setState(() => _allowDataCollection = value);
                              _updateSettings('allowDataCollection', value);
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
                            () => _launchURL('privacy'),
                          ),
                          _buildLinkTile(
                            'Termeni și Condiții',
                            'Citește termenii și condițiile serviciului',
                            () => _launchURL('terms'),
                          ),
                          _buildLinkTile(
                            'Drepturi GDPR',
                            'Află despre drepturile tale conform GDPR',
                            () => _launchURL('gdpr'),
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
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7))),
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
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.7))),
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
            color: isDestructive ? Colors.red.withOpacity(0.3) : Colors.white.withOpacity(0.2),
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

  Future<void> _launchURL(String page) async {
    final urls = {
      'privacy': 'https://elitattoo.ro/privacy',
      'terms': 'https://elitattoo.ro/terms',
      'gdpr': 'https://elitattoo.ro/gdpr',
    };

    final url = urls[page];
    if (url != null) {
      try {
        await launch(url);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nu s-a putut deschide pagina: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadUserData() async {
    // Implementează logica pentru descărcarea datelor
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Se pregătește descărcarea datelor tale...'),
      ),
    );
  }

  Future<void> _deleteAccount() async {
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
              // Implementează logica de ștergere cont
              Navigator.pop(context);
              Navigator.pop(context);
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
}
