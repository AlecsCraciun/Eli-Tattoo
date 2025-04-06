// lib/appointments/screens/main_screen.dart

import 'package:flutter/material.dart';

class AppointmentsMainScreen extends StatefulWidget {
  @override
  _AppointmentsMainScreenState createState() => _AppointmentsMainScreenState();
}

class _AppointmentsMainScreenState extends State<AppointmentsMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    CalendarScreen(),
    NewBookingScreen(),
    DashboardScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF2d2d2d),
            ],
          ),
        ),
        child: Row(
          children: [
            // Navigation Rail cu efect glassmorphism
            Container(
              width: 72,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                labelType: NavigationRailLabelType.selected,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_today, color: Colors.white70),
                    selectedIcon: Icon(Icons.calendar_today, color: Colors.blue),
                    label: Text('Calendar'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.add_circle_outline, color: Colors.white70),
                    selectedIcon: Icon(Icons.add_circle, color: Colors.blue),
                    label: Text('Programare'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.dashboard_outlined, color: Colors.white70),
                    selectedIcon: Icon(Icons.dashboard, color: Colors.blue),
                    label: Text('Dashboard'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history, color: Colors.white70),
                    selectedIcon: Icon(Icons.history, color: Colors.blue),
                    label: Text('Istoric'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined, color: Colors.white70),
                    selectedIcon: Icon(Icons.settings, color: Colors.blue),
                    label: Text('Setări'),
                  ),
                ],
              ),
            ),
            // Conținut principal
            Expanded(
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _screens[_selectedIndex],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
