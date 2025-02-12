// lib/services/seo_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SEOService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lista domeniilor
  final List<String> domains = [
    'artisti-tatuaje.ink',
    'artisti-tatuaje.ro',
    'inked-society.ro',
    'inkedsociety.ro',
    'tattoo-brasov.ro',
    'tattoo-community.ro',
    'tatuaje-romania.ro',
    'tatuajebrasov.ro',
    'tatuatori-romania.ro',
    'tatuatori.ro'
  ];

  // Cuvinte cheie principale
  final List<String> mainKeywords = [
    'tatuaje brasov',
    'salon tatuaje brasov',
    'piercing brasov',
    'tattoo artist brasov',
    'tatuaje fine line brasov',
    'microrealism tatuaje',
    'black work tattoo',
    'stippling tattoo brasov'
  ];

  // Gestionează redirectările
  Future<void> updateRedirects(Map<String, String> redirects) async {
    try {
      await _firestore.collection('seo').doc('redirects').set({
        'rules': redirects,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Eroare la actualizarea redirectărilor: $e');
    }
  }

  // Actualizează meta descrierile
  Future<void> updateMetaDescriptions(Map<String, String> descriptions) async {
    try {
      await _firestore.collection('seo').doc('meta').set({
        'descriptions': descriptions,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Eroare la actualizarea meta descrierilor: $e');
    }
  }

  // Gestionează sitemap-ul
  Future<void> updateSitemap(List<Map<String, dynamic>> pages) async {
    try {
      await _firestore.collection('seo').doc('sitemap').set({
        'pages': pages,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Eroare la actualizarea sitemap-ului: $e');
    }
  }
}
