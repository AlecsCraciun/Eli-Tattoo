// lib/appointments/models/artist.dart

class Artist {
  final String id;
  final String name;
  final String email;
  final List<String> specializations;
  final String experience;
  final String location;
  final bool isActive;
  final List<String> workingDays;
  final String workingHoursStart;
  final String workingHoursEnd;
  final bool isPiercingSpecialist;

  Artist({
    required this.id,
    required this.name,
    required this.email,
    required this.specializations,
    required this.experience,
    required this.location,
    this.isActive = true,
    this.isPiercingSpecialist = false,
    this.workingDays = const ['Luni', 'Marți', 'Miercuri', 'Joi', 'Vineri', 'Sâmbătă'],
    this.workingHoursStart = '11:00',
    this.workingHoursEnd = '19:00',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'specializations': specializations,
      'experience': experience,
      'location': location,
      'isActive': isActive,
      'isPiercingSpecialist': isPiercingSpecialist,
      'workingDays': workingDays,
      'workingHoursStart': workingHoursStart,
      'workingHoursEnd': workingHoursEnd,
    };
  }

  factory Artist.fromMap(Map<String, dynamic> map, String documentId) {
    return Artist(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      specializations: List<String>.from(map['specializations'] ?? []),
      experience: map['experience'] ?? '',
      location: map['location'] ?? '',
      isActive: map['isActive'] ?? true,
      isPiercingSpecialist: map['isPiercingSpecialist'] ?? false,
      workingDays: List<String>.from(map['workingDays'] ?? []),
      workingHoursStart: map['workingHoursStart'] ?? '11:00',
      workingHoursEnd: map['workingHoursEnd'] ?? '19:00',
    );
  }

  static List<Artist> getDefaultArtists() {
    return [
      Artist(
        id: 'alecs',
        name: 'Alecs Craciun',
        email: 'alecstattoobrasov@gmail.com',
        specializations: [
          'ornamental',
          'graphic',
          'realism'
        ],
        experience: '7+ ani',
        location: 'Strada Republicii 25',
      ),
      Artist(
        id: 'denis',
        name: 'Denis Mihali',
        email: 'denis@elitattoostudio.ro',
        specializations: [
          'fine line',
          'microrealism',
          'black work',
          'stippling'
        ],
        experience: '3+ ani',
        location: 'Strada Republicii 25',
      ),
      Artist(
        id: 'blanca',
        name: 'Blanca Sardaru',
        email: 'blanca@elitattoostudio.ro',
        specializations: [
          'fine line'
        ],
        experience: '5+ ani',
        location: 'B-dul Nicolae Balcescu Nr.20',
        isPiercingSpecialist: true,
      ),
    ];
  }

  // Helper pentru a verifica dacă artistul lucrează într-o anumită zi
  bool isWorkingOnDay(String day) {
    return workingDays.contains(day);
  }

  // Helper pentru a verifica dacă artistul este disponibil la o anumită oră
  bool isWorkingAtHour(String time) {
    try {
      final workStart = workingHoursStart.split(':').map(int.parse).toList();
      final workEnd = workingHoursEnd.split(':').map(int.parse).toList();
      final checkTime = time.split(':').map(int.parse).toList();
      
      final start = workStart[0] * 60 + workStart[1];
      final end = workEnd[0] * 60 + workEnd[1];
      final check = checkTime[0] * 60 + checkTime[1];
      
      return check >= start && check < end;
    } catch (e) {
      print('Eroare la verificarea orei de lucru: $e');
      return false;
    }
  }

  // Helper pentru a obține specializările ca string
  String get specializationsAsString {
    return specializations.join(', ');
  }
}
