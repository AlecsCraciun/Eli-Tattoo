import 'package:cloud_firestore/cloud_firestore.dart';

class Appointment {
  static const List<int> availableDurations = [
    60,   // 1 oră
    120,  // 2 ore
    180,  // 3 ore
    240,  // 4 ore
    300,  // 5 ore
    360,  // 6 ore
    420,  // 7 ore
    480   // 8 ore
  ];

  final String id;
  final String artistId;
  final String artistName;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String tattooTitle;
  final DateTime date;
  final String time;
  final int duration;
  final double price;
  final double advance;
  final String notes;
  final String status;
  final String location;
  final DateTime? createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  DateTime get endTime {
    try {
      final timeParts = time.split(':');
      final startDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      return startDateTime.add(Duration(minutes: duration));
    } catch (e) {
      print('Eroare la calcularea endTime: $e');
      return date;
    }
  }

  DateTime get startDateTime {
    try {
      final timeParts = time.split(':');
      return DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (e) {
      print('Eroare la calcularea startDateTime: $e');
      return date;
    }
  }

  String get formattedDuration {
    try {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (hours == 0) {
        return '$minutes minute';
      } else if (minutes == 0) {
        return hours == 1 ? '1 oră' : '$hours ore';
      }
      return '${hours == 1 ? "1 oră" : "$hours ore"} și $minutes minute';
    } catch (e) {
      print('Eroare la formatarea duratei: $e');
      return '2 ore';
    }
  }

  Appointment({
    required this.id,
    required this.artistId,
    this.artistName = '',
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.tattooTitle,
    required this.date,
    required this.time,
    required this.duration,
    required this.price,
    required this.advance,
    required this.location,
    this.notes = '',
    this.status = 'pending',
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  }) : assert(availableDurations.contains(duration), 
       'Durata trebuie să fie una din valorile predefinite: ${availableDurations.join(", ")} minute');

  factory Appointment.fromMap(Map<String, dynamic> map, String documentId) {
    try {
      final timestamp = map['date'] as Timestamp?;
      final DateTime appointmentDate = timestamp?.toDate() ?? DateTime.now();

      return Appointment(
        id: documentId,
        artistId: map['artistId'] as String? ?? '',
        artistName: map['artistName'] as String? ?? '',
        clientName: map['clientName'] as String? ?? '',
        clientEmail: map['clientEmail'] as String? ?? '',
        clientPhone: map['clientPhone'] as String? ?? '',
        tattooTitle: map['tattooTitle'] as String? ?? '',
        date: appointmentDate,
        time: map['time'] as String? ?? '',
        duration: (map['duration'] as num?)?.toInt() ?? 120,
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        advance: (map['advance'] as num?)?.toDouble() ?? 0.0,
        location: map['location'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
        status: map['status'] as String? ?? 'pending',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
        createdBy: map['createdBy'] as String?,
        updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
        updatedBy: map['updatedBy'] as String?,
      );
    } catch (e) {
      print('Eroare la crearea Appointment din Map: $e');
      throw Exception('Eroare la parsarea datelor programării: $e');
    }
  }

  Map<String, dynamic> toMap() {
    try {
      return {
        'artistId': artistId,
        'artistName': artistName,
        'clientName': clientName,
        'clientEmail': clientEmail,
        'clientPhone': clientPhone,
        'tattooTitle': tattooTitle,
        'date': Timestamp.fromDate(date),
        'time': time,
        'duration': duration,
        'price': price,
        'advance': advance,
        'location': location,
        'notes': notes,
        'status': status,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
        'createdBy': createdBy,
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'updatedBy': updatedBy,
      };
    } catch (e) {
      print('Eroare la convertirea Appointment în Map: $e');
      throw Exception('Eroare la salvarea datelor programării: $e');
    }
  }

  Appointment copyWith({
    String? id,
    String? artistId,
    String? artistName,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    String? tattooTitle,
    DateTime? date,
    String? time,
    int? duration,
    double? price,
    double? advance,
    String? location,
    String? notes,
    String? status,
    DateTime? createdAt,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    try {
      return Appointment(
        id: id ?? this.id,
        artistId: artistId ?? this.artistId,
        artistName: artistName ?? this.artistName,
        clientName: clientName ?? this.clientName,
        clientEmail: clientEmail ?? this.clientEmail,
        clientPhone: clientPhone ?? this.clientPhone,
        tattooTitle: tattooTitle ?? this.tattooTitle,
        date: date ?? this.date,
        time: time ?? this.time,
        duration: duration ?? this.duration,
        price: price ?? this.price,
        advance: advance ?? this.advance,
        location: location ?? this.location,
        notes: notes ?? this.notes,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        createdBy: createdBy ?? this.createdBy,
        updatedAt: updatedAt ?? this.updatedAt,
        updatedBy: updatedBy ?? this.updatedBy,
      );
    } catch (e) {
      print('Eroare la copierea Appointment: $e');
      throw Exception('Eroare la modificarea programării: $e');
    }
  }

  @override
  String toString() {
    return 'Appointment{id: $id, date: $date, time: $time, clientName: $clientName, status: $status}';
  }

  bool isSameDay(DateTime other) {
    return date.year == other.year && 
           date.month == other.month && 
           date.day == other.day;
  }
}
