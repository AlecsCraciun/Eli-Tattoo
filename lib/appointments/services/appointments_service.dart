import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/appointment.dart';

class AppointmentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Canale pentru notificări
  static const String APPOINTMENTS_CHANNEL = 'appointments_channel';
  static const String REMINDERS_CHANNEL = 'reminders_channel';
  static const String UPDATES_CHANNEL = 'updates_channel';
  static const String CANCELLATIONS_CHANNEL = 'cancellations_channel';

  // Referințe Firestore
  late final CollectionReference _appointments;
  late final CollectionReference _artists;

  AppointmentsService() {
    _initializeCollections();
    _initializeTimezones();
  }

  void _initializeCollections() {
    _appointments = _firestore.collection('appointments');
    _artists = _firestore.collection('artists');
  }

  void _initializeTimezones() {
    try {
      tz.initializeTimeZones();
      print('Timezone initialization successful');
    } catch (e) {
      print('Eroare la inițializarea timezone-urilor: $e');
    }
  }

  Future<void> initializeNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          print('Notificare apăsată: ${response.payload}');
        },
      );
      print('Notifications initialization successful');
    } catch (e) {
      print('Eroare la inițializarea notificărilor: $e');
      throw 'Eroare la inițializarea notificărilor: $e';
    }
  }

  Future<String> createAppointment(Appointment appointment) async {
    try {
      print('Creating appointment for ${appointment.clientName}');
      
      final isAvailable = await checkAvailability(
        appointment.artistId,
        appointment.date,
        appointment.time,
        appointment.duration,
      );
      
      if (!isAvailable) {
        throw 'Intervalul orar este deja ocupat';
      }

      final docRef = await _appointments.add({
        ...appointment.toMap(),
        'date': Timestamp.fromDate(appointment.date),
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.email,
        'locationId': appointment.location,
        'status': 'confirmed',
      });

      print('Appointment created with ID: ${docRef.id}');

      await Future.wait([
        showAppointmentNotification(appointment.clientName, appointment.time),
        scheduleReminder(appointment.clientName, appointment.date),
      ]);

      return docRef.id;
    } catch (e) {
      print('Error creating appointment: $e');
      throw 'Eroare la crearea programării: $e';
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    try {
      print('Updating appointment ${appointment.id}');
      
      if (appointment.id == null) {
        throw 'ID-ul programării lipsește';
      }

      // Verificăm dacă programarea există
      final docSnapshot = await _appointments.doc(appointment.id).get();
      if (!docSnapshot.exists) {
        throw 'Programarea nu există';
      }

      // Verificăm disponibilitatea, excludând programarea curentă
      final query = await _appointments
          .where('artistId', isEqualTo: appointment.artistId)
          .where('date', isEqualTo: Timestamp.fromDate(appointment.date))
          .where('status', isEqualTo: 'confirmed')
          .get();

      for (var doc in query.docs) {
        if (doc.id != appointment.id) {  // Excludem programarea curentă
          final existingApp = Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          final existingStart = existingApp.startDateTime;
          final existingEnd = existingApp.endTime;
          final newStart = appointment.startDateTime;
          final newEnd = appointment.endTime;

          if (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart)) {
            throw 'Intervalul orar este deja ocupat';
          }
        }
      }

      // Actualizăm programarea
      await _appointments.doc(appointment.id).update({
        ...appointment.toMap(),
        'date': Timestamp.fromDate(appointment.date),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.email,
        'status': 'confirmed',  // Asigurăm că statusul rămâne confirmed
      });

      print('Appointment updated successfully');
      await showUpdateNotification(appointment.clientName);
    } catch (e) {
      print('Error updating appointment: $e');
      throw 'Eroare la actualizarea programării: $e';
    }
  }


  Stream<Map<DateTime, List<Appointment>>> getMonthAppointments(
    DateTime startOfMonth,
    DateTime endOfMonth, {
    String? artistId,
  }) {
    try {
      print('Fetching appointments for period: ${startOfMonth.toString()} - ${endOfMonth.toString()}');
      print('Artist ID: ${artistId ?? 'all artists'}');

      final normalizedStart = DateTime(startOfMonth.year, startOfMonth.month, startOfMonth.day);
      final normalizedEnd = DateTime(endOfMonth.year, endOfMonth.month, endOfMonth.day, 23, 59, 59);

      print('Normalized date range: ${normalizedStart.toString()} - ${normalizedEnd.toString()}');

      Query query = _appointments
          .where('status', isEqualTo: 'confirmed')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(normalizedStart))
          .where('date', isLessThan: Timestamp.fromDate(normalizedEnd))
          .orderBy('date', descending: false);

      if (artistId != null && artistId.isNotEmpty) {
        query = query.where('artistId', isEqualTo: artistId);
      }

      return query.snapshots().map((snapshot) {
        print('Received ${snapshot.docs.length} appointments from Firestore');
        
        final Map<DateTime, List<Appointment>> monthAppointments = {};

        for (var doc in snapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            final Timestamp timestamp = data['date'] as Timestamp;
            final DateTime appointmentDate = timestamp.toDate();
            
            final DateTime normalizedDate = DateTime(
              appointmentDate.year,
              appointmentDate.month,
              appointmentDate.day,
            );

            print('Processing appointment: ID=${doc.id}, Date=${normalizedDate.toString()}');

            if (!monthAppointments.containsKey(normalizedDate)) {
              monthAppointments[normalizedDate] = [];
            }

            final appointment = Appointment.fromMap(data, doc.id);
            monthAppointments[normalizedDate]!.add(appointment);

            print('Added appointment: ${appointment.toString()}');
          } catch (e) {
            print('Error processing appointment document ${doc.id}: $e');
            continue;
          }
        }

        monthAppointments.forEach((date, appointments) {
          appointments.sort((a, b) => a.time.compareTo(b.time));
        });

        print('Returning appointments for ${monthAppointments.length} days');
        monthAppointments.forEach((date, appointments) {
          print('Date: $date, Appointments: ${appointments.length}');
        });

        return monthAppointments;
      });
    } catch (e, stackTrace) {
      print('Error in getMonthAppointments: $e');
      print('Stack trace: $stackTrace');
      return Stream.value({});
    }
  }

  Future<bool> checkAvailability(
    String artistId,
    DateTime date,
    String time,
    int duration,
  ) async {
    try {
      print('Checking availability for artist $artistId on $date at $time');
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final appointmentTime = time.split(':');
      final startTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(appointmentTime[0]),
        int.parse(appointmentTime[1]),
      );
      final endTime = startTime.add(Duration(minutes: duration));

      final snapshot = await _appointments
          .where('artistId', isEqualTo: artistId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', isEqualTo: 'confirmed')
          .get();

      for (var doc in snapshot.docs) {
        final existingAppointment = Appointment.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
        
        final existingStartTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(existingAppointment.time.split(':')[0]),
          int.parse(existingAppointment.time.split(':')[1]),
        );
        final existingEndTime = existingStartTime.add(
          Duration(minutes: existingAppointment.duration),
        );

        if (startTime.isBefore(existingEndTime) && 
            endTime.isAfter(existingStartTime)) {
          print('Time slot is not available');
          return false;
        }
      }

      print('Time slot is available');
      return true;
    } catch (e) {
      print('Error checking availability: $e');
      return false;
    }
  }

  Stream<List<Appointment>> getAppointmentsForDate(
    DateTime date, {
    String? artistId,
  }) {
    try {
      print('Getting appointments for date: $date');
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      Query query = _appointments
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .where('status', isEqualTo: 'confirmed')
          .orderBy('date')
          .orderBy('time');

      if (artistId != null && artistId.isNotEmpty) {
        query = query.where('artistId', isEqualTo: artistId);
      }

      return query.snapshots().map((snapshot) {
        final appointments = snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        print('Found ${appointments.length} appointments for $date');
        return appointments;
      });
    } catch (e) {
      print('Error getting appointments for date: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Appointment>> getArtistAppointments(String artistId) {
    try {
      print('Getting appointments for artist: $artistId');
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      return _appointments
          .where('artistId', isEqualTo: artistId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('status', isEqualTo: 'confirmed')
          .orderBy('date')
          .orderBy('time')
          .snapshots()
          .map((snapshot) {
        final appointments = snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        print('Found ${appointments.length} appointments for artist $artistId');
        return appointments;
      });
    } catch (e) {
      print('Error getting artist appointments: $e');
      return Stream.value([]);
    }
  }

  Stream<List<Appointment>> getLocationAppointments(String locationId) {
    try {
      print('Getting appointments for location: $locationId');
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      return _appointments
          .where('locationId', isEqualTo: locationId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('status', isEqualTo: 'confirmed')
          .orderBy('date')
          .orderBy('time')
          .snapshots()
          .map((snapshot) {
        final appointments = snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        print('Found ${appointments.length} appointments for location $locationId');
        return appointments;
      });
    } catch (e) {
      print('Error getting location appointments: $e');
      return Stream.value([]);
    }
  }

  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      print('Cancelling appointment: $appointmentId');
      await _appointments.doc(appointmentId).update({
        'status': 'cancelled',
        'cancelReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': _auth.currentUser?.email,
      });
      print('Appointment cancelled successfully');
      await showCancelNotification(reason);
    } catch (e) {
      print('Error cancelling appointment: $e');
      throw 'Eroare la anularea programării: $e';
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      print('Getting dashboard stats');
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1);

      final snapshot = await _appointments
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThan: Timestamp.fromDate(endOfMonth))
          .where('status', isEqualTo: 'confirmed')
          .get();

      final todayAppointments = snapshot.docs.where((doc) {
        final timestamp = (doc.data() as Map<String, dynamic>)['date'] as Timestamp;
        final date = timestamp.toDate();
        return date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) && 
               date.isBefore(endOfDay);
      }).length;

      final monthlyAppointments = snapshot.docs.length;

      final monthlyRevenue = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['price'] ?? 0)
          .fold<double>(0, (sum, price) => sum + (price as num).toDouble());

      print('Stats calculated: Today: $todayAppointments, Monthly: $monthlyAppointments, Revenue: $monthlyRevenue');

      return {
        'todayAppointments': todayAppointments,
        'monthlyAppointments': monthlyAppointments,
        'monthlyRevenue': monthlyRevenue,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'todayAppointments': 0,
        'monthlyAppointments': 0,
        'monthlyRevenue': 0.0,
      };
    }
  }

  Future<void> showAppointmentNotification(
    String clientName,
    String time,
  ) async {
    try {
      print('Showing appointment notification for $clientName at $time');
      const androidDetails = AndroidNotificationDetails(
        APPOINTMENTS_CHANNEL,
        'Programări',
        channelDescription: 'Notificări pentru programări noi',
        importance: Importance.high,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notifications.show(
        DateTime.now().millisecond,
        'Programare Nouă',
        'Programare nouă pentru $clientName la ora $time',
        notificationDetails,
      );
      print('Appointment notification shown successfully');
    } catch (e) {
      print('Error showing appointment notification: $e');
    }
  }

  Future<void> scheduleReminder(String clientName, DateTime appointmentDate) async {
    try {
      print('Scheduling reminder for $clientName on $appointmentDate');
      final scheduledDate = appointmentDate.subtract(const Duration(hours: 24));
      
      const androidDetails = AndroidNotificationDetails(
        REMINDERS_CHANNEL,
        'Remindere',
        channelDescription: 'Notificări pentru remindere programări',
        importance: Importance.high,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      final scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);
      await _notifications.zonedSchedule(
        appointmentDate.millisecond,
        'Reminder Programare',
        'Mâine ai programare cu $clientName',
        scheduledTime,
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('Reminder scheduled successfully');
    } catch (e) {
      print('Error scheduling reminder: $e');
    }
  }

  Future<void> showUpdateNotification(String clientName) async {
    try {
      print('Showing update notification for $clientName');
      const androidDetails = AndroidNotificationDetails(
        UPDATES_CHANNEL,
        'Actualizări',
        channelDescription: 'Notificări pentru actualizări programări',
        importance: Importance.high,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notifications.show(
        DateTime.now().millisecond,
        'Programare Actualizată',
        'Programarea pentru $clientName a fost actualizată',
        notificationDetails,
      );
      print('Update notification shown successfully');
    } catch (e) {
      print('Error showing update notification: $e');
    }
  }

  Future<void> showCancelNotification(String reason) async {
    try {
      print('Showing cancellation notification');
      const androidDetails = AndroidNotificationDetails(
        CANCELLATIONS_CHANNEL,
        'Anulări',
        channelDescription: 'Notificări pentru anulări programări',
        importance: Importance.high,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notifications.show(
        DateTime.now().millisecond,
        'Programare Anulată',
        'O programare a fost anulată. Motiv: $reason',
        notificationDetails,
      );
      print('Cancellation notification shown successfully');
    } catch (e) {
      print('Error showing cancellation notification: $e');
    }
  }
}
