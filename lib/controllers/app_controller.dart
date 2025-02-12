// lib/controllers/app_controller.dart
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/loyalty_service.dart';

class AppController extends GetxController {
  final AuthService _authService = Get.find();
  final StorageService _storageService = Get.find();
  final LoyaltyService _loyaltyService = Get.find();

  // Stare observabilă
  final RxBool isLoading = false.obs;
  final RxInt userPoints = 0.obs;
  final RxString currentPage = ''.obs;
  final RxBool isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    isLoading.value = true;
    try {
      // Verificăm autentificarea
      if (!_authService.isAuthenticated) {
        await _authService.signInAnonymously();
      }

      // Încărcăm punctele utilizatorului
      final userId = _authService.user.value?.uid;
      if (userId != null) {
        _loyaltyService.getUserPoints(userId).listen((snapshot) {
          userPoints.value = snapshot.data()?['points'] ?? 0;
        });
      }

      // Încărcăm preferințele salvate
      _loadPreferences();
    } catch (e) {
      print('Eroare la inițializarea aplicației: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _loadPreferences() {
    // Încărcăm tema
    final savedTheme = _storageService.getUserId();
    if (savedTheme != null) {
      isDarkMode.value = true;
    }
  }

  // Metode pentru navigare
  void changePage(String page) {
    currentPage.value = page;
  }

  // Metode pentru temă
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    // Salvăm preferința
    _storageService.saveUserId(isDarkMode.value.toString());
  }

  // Metodă pentru refresh
  Future<void> refreshData() async {
    isLoading.value = true;
    await _initializeApp();
    isLoading.value = false;
  }
}
