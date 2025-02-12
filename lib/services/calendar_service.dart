// lib/services/calendar_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Program de lucru standard
  final Map<String, dynamic> workingHours = {
    'monday-friday': {'start': '11:00', 'end': '19:00'},
    'saturday': {'start': '11:00', 'end': '17:00'},
    'sunday': {'start': null, 'end': null}, // Închis
  };

  // Obține programările pentru o zi specifică
  Stream<QuerySnapshot> getDayAppointments(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('appointments')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThan: endOfDay)
        .orderBy('date')
        .snapshots();
  }

  // Verifică disponibilitatea pentru o oră specifică
  Future<bool> checkTimeSlotAvailability(
    DateTime dateTime,
    String artistId,
  ) async {
    try {
      final appointments = await _firestore
          .collection('appointments')
          .where('date', isEqualTo: dateTime)
          .where('artistId', isEqualTo: artistId)
          .get();

      return appointments.docs.isEmpty;
    } catch (e) {
      print('Eroare la verificarea disponibilității: $e');
      return false;
    }
  }

  // Obține următoarele slot-uri disponibile
  Future<List<DateTime>> getNextAvailableSlots(
    String artistId,
    int numberOfSlots,
  ) async {
    List<DateTime> availableSlots = [];
    DateTime currentDate = DateTime.now();

    while (availableSlots.length < numberOfSlots) {
      if (currentDate.weekday == DateTime.sunday) {
        currentDate = currentDate.add(const Duration(days: 1));
        continue;
      }

      final startHour = currentDate.weekday == DateTime.saturday ? 11 : 11;
      final endHour = currentDate.weekday == DateTime.saturday ? 17 : 19;

      for (int hour = startHour; hour < endHour; hour++) {
        final timeSlot = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          hour,
        );

        if (await checkTimeSlotAvailability(timeSlot, artistId)) {
          availableSlots.add(timeSlot);
          if (availableSlots.length == numberOfSlots) break;
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return availableSlots;
  }

  // Adaugă o rezervare nouă
  Future<void> addAppointment({
    required String userId,
    required String artistId,
    required DateTime date,
    required String serviceType,
    String? notes,
  }) async {
    try {
      if (!await checkTimeSlotAvailability(date, artistId)) {
        throw Exception('Slot-ul nu mai este disponibil');
      }

      await _firestore.collection('appointments').add({
        'userId': userId,
        'artistId': artistId,
        'date': date,
        'serviceType': serviceType,
        'notes': notes,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Eroare la adăugarea programării: $e');
      rethrow;
    }
  }
}
