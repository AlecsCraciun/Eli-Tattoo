// lib/services/booking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Verifică disponibilitatea
  Future<bool> checkAvailability(DateTime dateTime, String artistId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('date', isEqualTo: dateTime)
        .where('artistId', isEqualTo: artistId)
        .get();

    return snapshot.docs.isEmpty;
  }

  // Crează o programare nouă
  Future<void> createAppointment({
    required String userId,
    required String artistId,
    required DateTime dateTime,
    required String serviceType,
    String? description,
    String? referenceImage,
  }) async {
    await _firestore.collection('appointments').add({
      'userId': userId,
      'artistId': artistId,
      'date': dateTime,
      'serviceType': serviceType,
      'description': description,
      'referenceImage': referenceImage,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Obține programările unui utilizator
  Stream<QuerySnapshot> getUserAppointments(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('date')
        .snapshots();
  }

  // Anulează o programare
  Future<void> cancelAppointment(String appointmentId) async {
    await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .update({'status': 'cancelled'});
  }

  // Obține orele disponibile pentru o dată
  Future<List<DateTime>> getAvailableTimeSlots(
    DateTime date,
    String artistId,
  ) async {
    // Program de lucru
    final workingHours = {
      'start': const TimeOfDay(hour: 11, minute: 0),
      'end': const TimeOfDay(hour: 19, minute: 0),
    };

    List<DateTime> availableSlots = [];
    DateTime current = DateTime(
      date.year,
      date.month,
      date.day,
      workingHours['start']!.hour,
      workingHours['start']!.minute,
    );

    while (current.hour < workingHours['end']!.hour) {
      if (await checkAvailability(current, artistId)) {
        availableSlots.add(current);
      }
      current = current.add(const Duration(hours: 1));
    }

    return availableSlots;
  }
}
