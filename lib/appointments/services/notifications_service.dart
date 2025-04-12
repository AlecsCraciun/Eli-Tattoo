import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Configurare notificări locale
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _localNotifications.initialize(initSettings);

    // Permisiuni pentru notificări push
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obține token FCM pentru device
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveDeviceToken(token);
    }
  }

  Future<void> _saveDeviceToken(String token) async {
    // Salvăm token-ul în Firestore pentru utilizatorul curent
    // Vom folosi acest token pentru a trimite notificări specifice utilizatorului
  }

  Future<void> sendAppointmentConfirmation(String email, Map<String, dynamic> appointmentData) async {
    // Trimite email de confirmare
    await _sendEmail(
      to: email,
      subject: 'Confirmare Programare - Eli Tattoo Studio',
      body: _generateConfirmationEmailBody(appointmentData),
    );

    // Trimite notificare push
    await _sendPushNotification(
      title: 'Programare Confirmată',
      body: 'Programarea ta pentru ${appointmentData['date']} a fost confirmată.',
      data: appointmentData,
    );
  }

  Future<void> scheduleAppointmentReminder(String email, Map<String, dynamic> appointmentData) async {
    // Programăm reminder cu 24h înainte
    DateTime appointmentDate = DateTime.parse(appointmentData['date']);
    DateTime reminderDate = appointmentDate.subtract(Duration(hours: 24));

    // Reminder prin email
    await _scheduleEmail(
      to: email,
      subject: 'Reminder Programare - Eli Tattoo Studio',
      body: _generateReminderEmailBody(appointmentData),
      scheduledDate: reminderDate,
    );

    // Reminder prin notificare push
    await _scheduleNotification(
      title: 'Reminder Programare',
      body: 'Ai o programare mâine la ${appointmentData['time']}',
      scheduledDate: reminderDate,
      data: appointmentData,
    );
  }
}
