// lib/services/gallery_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GalleryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Obține toate lucrările
  Stream<QuerySnapshot> getAllWorks() {
    return _firestore
        .collection('portfolio')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Obține lucrările unui artist specific
  Stream<QuerySnapshot> getArtistWorks(String artistId) {
    return _firestore
        .collection('portfolio')
        .where('artistId', isEqualTo: artistId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Obține lucrări după stil
  Stream<QuerySnapshot> getWorksByStyle(String style) {
    return _firestore
        .collection('portfolio')
        .where('styles', arrayContains: style)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Obține stilurile disponibile
  Future<List<String>> getAvailableStyles() async {
    final styles = await _firestore.collection('styles').get();
    return styles.docs.map((doc) => doc['name'] as String).toList();
  }

  // Obține artiștii disponibili
  Future<List<Map<String, dynamic>>> getAvailableArtists() async {
    final artists = await _firestore.collection('artists').get();
    return artists.docs.map((doc) => {
      'id': doc.id,
      'name': doc['name'],
      'specialties': doc['specialties'],
    }).toList();
  }

  // Filtrează lucrările după mai multe criterii
  Stream<QuerySnapshot> filterWorks({
    String? artistId,
    String? style,
    bool? isFeatured,
  }) {
    Query query = _firestore.collection('portfolio');

    if (artistId != null) {
      query = query.where('artistId', isEqualTo: artistId);
    }
    if (style != null) {
      query = query.where('styles', arrayContains: style);
    }
    if (isFeatured != null) {
      query = query.where('isFeatured', isEqualTo: isFeatured);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }
}
