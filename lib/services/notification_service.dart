// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Cerere permisiuni
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Configurare notificări locale
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(initializationSettings);

    // Ascultă pentru notificări când aplicația e în fundal
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Ascultă pentru notificări când aplicația e deschisă
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  // Handler pentru notificări în fundal
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Notificare primită în fundal: \${message.notification?.title}');
  }

  // Handler pentru notificări în prim-plan
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'eli_tattoo_channel',
            'Eli Tattoo Notifications',
            channelDescription: 'Notificări importante de la Eli Tattoo',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  // Salvare token FCM
  Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  // Abonare la topic
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  // Dezabonare de la topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}
