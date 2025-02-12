// lib/services/social_media_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialMediaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Platforme sociale
  final Map<String, String> socialPlatforms = {
    'facebook': 'EliTattooBrasov',
    'instagram': 'eli.tattoo.brasov',
    'tiktok': '@eli.tattoo.brasov',
  };

  // Planifică postări
  Future<void> schedulePosts({
    required String platform,
    required String content,
    required DateTime scheduledDate,
    List<String>? imageUrls,
    List<String>? hashtags,
  }) async {
    try {
      await _firestore.collection('social_media').add({
        'platform': platform,
        'content': content,
        'scheduledDate': scheduledDate,
        'imageUrls': imageUrls,
        'hashtags': hashtags,
        'status': 'scheduled',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Eroare la planificarea postării: $e');
    }
  }

  // Obține statistici sociale
  Future<Map<String, dynamic>> getSocialStats(String platform) async {
    try {
      final stats = await _firestore
          .collection('social_media')
          .doc('statistics')
          .collection(platform)
          .doc('current')
          .get();

      return {
        'followers': stats['followers'] ?? 0,
        'engagement_rate': stats['engagement_rate'] ?? 0,
        'top_posts': stats['top_posts'] ?? [],
      };
    } catch (e) {
      print('Eroare la obținerea statisticilor: \$e');
      return {};
    }
  }

  // Gestionează hashtag-uri
  Future<List<String>> getRecommendedHashtags(String category) async {
    try {
      final hashtags = await _firestore
          .collection('social_media')
          .doc('hashtags')
          .collection(category)
          .get();

      return hashtags.docs.map((doc) => doc['tag'] as String).toList();
    } catch (e) {
      print('Eroare la obținerea hashtag-urilor: $e');
      return [];
    }
  }
}
