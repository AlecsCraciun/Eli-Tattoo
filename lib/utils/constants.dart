// lib/utils/constants.dart
class AppConstants {
  // Informații salon
  static const String salonName = 'Eli Tattoo';
  static const String phone = '0787 229 574';
  static const String email = 'alecstattoobrasov@gmail.com';
  
  // Locații
  static const List<SalonLocation> locations = [
    SalonLocation(
      address: 'Strada Republicii 25',
      city: 'Brașov',
      country: 'Romania',
    ),
    SalonLocation(
      address: 'B-dul Nicolae Balcescu Nr.20',
      city: 'Brașov',
      country: 'Romania',
    ),
  ];

  // Program
  static const Map<String, String> schedule = {
    'Luni-Vineri': '11:00 - 19:00',
    'Sâmbătă': '11:00 - 17:00',
    'Duminică': 'Închis',
  };

  // Artiști
  static const List<Artist> artists = [
    Artist(
      name: 'Alecs',
      role: 'Owner & Artist',
      specialties: ['Toate stilurile'],
    ),
    Artist(
      name: 'Blanca',
      role: 'Artist & Specialist Piercing',
      specialties: ['Piercing'],
    ),
    Artist(
      name: 'Denis',
      role: 'Artist',
      specialties: [
        'Fine Line',
        'Microrealism',
        'Black Work',
        'Stippling',
      ],
    ),
  ];
}

class SalonLocation {
  final String address;
  final String city;
  final String country;

  const SalonLocation({
    required this.address,
    required this.city,
    required this.country,
  });

  String get fullAddress => '$address, $city, $country';
}

class Artist {
  final String name;
  final String role;
  final List<String> specialties;

  const Artist({
    required this.name,
    required this.role,
    required this.specialties,
  });
}
