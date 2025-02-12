// lib/services/storage_service.dart
import 'package:shared_preferences.dart';

class StorageService {
  static const String keyUserId = 'userId';
  static const String keyPoints = 'points';
  static const String keyLastVisit = 'lastVisit';
  static const String keyCompletedHunts = 'completedHunts';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // Inițializare
  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Salvare userId
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(keyUserId, userId);
  }

  // Obținere userId
  String? getUserId() {
    return _prefs.getString(keyUserId);
  }

  // Salvare puncte
  Future<void> savePoints(int points) async {
    await _prefs.setInt(keyPoints, points);
  }

  // Obținere puncte
  int getPoints() {
    return _prefs.getInt(keyPoints) ?? 0;
  }

  // Salvare ultima vizită
  Future<void> saveLastVisit() async {
    await _prefs.setString(keyLastVisit, DateTime.now().toIso8601String());
  }

  // Obținere ultima vizită
  DateTime? getLastVisit() {
    final lastVisit = _prefs.getString(keyLastVisit);
    return lastVisit != null ? DateTime.parse(lastVisit) : null;
  }

  // Salvare treasure hunts completate
  Future<void> saveCompletedHunt(String huntId) async {
    final completedHunts = getCompletedHunts();
    completedHunts.add(huntId);
    await _prefs.setStringList(keyCompletedHunts, completedHunts);
  }

  // Obținere treasure hunts completate
  List<String> getCompletedHunts() {
    return _prefs.getStringList(keyCompletedHunts) ?? [];
  }

  // Ștergere toate datele
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
