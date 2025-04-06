// lib/appointments/screens/settings_screen.dart

import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Setări program
  Map<String, WorkingHours> workingHours = {
    'Luni': WorkingHours(start: '11:00', end: '19:00'),
    'Marți': WorkingHours(start: '11:00', end: '19:00'),
    'Miercuri': WorkingHours(start: '11:00', end: '19:00'),
    'Joi': WorkingHours(start: '11:00', end: '19:00'),
    'Vineri': WorkingHours(start: '11:00', end: '19:00'),
    'Sâmbătă': WorkingHours(start: '11:00', end: '17:00'),
    'Duminică': WorkingHours(start: '', end: '', isActive: false),
  };

  // Setări artiști
  List<Artist> artists = [
    Artist(
      name: 'Alecs Craciun',
      specialization: 'Realism, Black & Grey',
      location: 'Strada Republicii 25',
      isActive: true,
    ),
    Artist(
      name: 'Denis Mihali',
      specialization: 'Fine Line, Microrealism',
      location: 'B-dul Nicolae Balcescu Nr.20',
      isActive: true,
    ),
    Artist(
      name: 'Blanca Sardaru',
      specialization: 'Piercing',
      location: 'Strada Republicii 25',
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Setări Calendar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),

          // Program de lucru
          _buildSection(
            title: 'Program de Lucru',
            child: Column(
              children: workingHours.entries.map((entry) {
                return _buildWorkingHourCard(entry.key, entry.value);
              }).toList(),
            ),
          ),
          SizedBox(height: 24),

          // Configurare artiști
          _buildSection(
            title: 'Configurare Artiști',
            child: Column(
              children: artists.map((artist) {
                return _buildArtistCard(artist);
              }).toList(),
            ),
          ),
          SizedBox(height: 24),

          // Setări notificări
          _buildSection(
            title: 'Setări Notificări',
            child: Column(
              children: [
                _buildNotificationSetting(
                  'Reminder programare',
                  'Cu 24h înainte',
                  true,
                ),
                _buildNotificationSetting(
                  'Confirmare programare',
                  'La creare',
                  true,
                ),
                _buildNotificationSetting(
                  'Anulare programare',
                  'La anulare',
                  true,
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Setări generale
          _buildSection(
            title: 'Setări Generale',
            child: Column(
              children: [
                _buildGeneralSetting(
                  'Durată standard ședință',
                  '2 ore',
                  Icons.timer,
                ),
                _buildGeneralSetting(
                  'Interval minim între programări',
                  '30 minute',
                  Icons.space_bar,
                ),
                _buildGeneralSetting(
                  'Avans minim',
                  '100 RON',
                  Icons.payments,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildWorkingHourCard(String day, WorkingHours hours) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.white70, size: 20),
                SizedBox(width: 8),
                Text(
                  hours.isActive ? '${hours.start} - ${hours.end}' : 'Închis',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Switch(
            value: hours.isActive,
            onChanged: (value) {
              setState(() {
                hours.isActive = value;
              });
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildArtistCard(Artist artist) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                artist.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: artist.isActive,
                onChanged: (value) {
                  setState(() {
                    artist.isActive = value;
                  });
                },
                activeColor: Colors.blue,
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            artist.specialization,
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            artist.location,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSetting(
    String title,
    String subtitle,
    bool value,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: (value) {
              setState(() {
                // Implementare salvare setare
              });
            },
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSetting(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class WorkingHours {
  String start;
  String end;
  bool isActive;

  WorkingHours({
    required this.start,
    required this.end,
    this.isActive = true,
  });
}

class Artist {
  String name;
  String specialization;
  String location;
  bool isActive;

  Artist({
    required this.name,
    required this.specialization,
    required this.location,
    this.isActive = true,
  });
}
