// lib/services/blog_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Categorii de articole
  final List<String> categories = [
    'noutati',
    'sfaturi',
    'ingrijire',
    'styles',
    'evenimente',
    'behind-the-scenes'
  ];

  // Creează un articol nou
  Future<void> createArticle({
    required String title,
    required String content,
    required String authorId,
    required List<String> categories,
    String? thumbnailUrl,
    List<String>? tags,
  }) async {
    try {
      final slug = _generateSlug(title);
      
      await _firestore.collection('blog').add({
        'title': title,
        'slug': slug,
        'content': content,
        'authorId': authorId,
        'categories': categories,
        'thumbnailUrl': thumbnailUrl,
        'tags': tags,
        'views': 0,
        'isPublished': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Eroare la crearea articolului: $e');
    }
  }

  // Obține articole publicate
  Stream<QuerySnapshot> getPublishedArticles() {
    return _firestore
        .collection('blog')
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Obține articole după categorie
  Stream<QuerySnapshot> getArticlesByCategory(String category) {
    return _firestore
        .collection('blog')
        .where('categories', arrayContains: category)
        .where('isPublished', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Generează slug pentru URL
  String _generateSlug(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }
}
