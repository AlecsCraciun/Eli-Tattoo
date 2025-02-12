// lib/controllers/treasure_hunt_controller.dart
import 'package:get/get.dart';
import '../services/qr_service.dart';
import '../services/loyalty_service.dart';

class TreasureHuntController extends GetxController {
  final QRService _qrService = Get.find();
  final LoyaltyService _loyaltyService = Get.find();

  // Stare observabilă
  final RxBool isLoading = false.obs;
  final RxInt currentLevel = 1.obs;
  final RxString currentClue = ''.obs;
  final RxInt totalPoints = 0.obs;
  final RxBool isScanning = false.obs;

  // Lista de indicii pentru fiecare nivel
  final Map<int, String> huntClues = {
    1: 'Caută primul indiciu lângă oglinda mare din salon.',
    2: 'Verifică zona de așteptare, poate găsești ceva interesant.',
    3: 'Următorul indiciu este ascuns în apropierea stației de sterilizare.',
    4: 'Felicitări! Ai completat toate nivelurile!',
  };

  @override
  void onInit() {
    super.onInit();
    loadCurrentProgress();
  }

  // Încarcă progresul curent
  Future<void> loadCurrentProgress() async {
    isLoading.value = true;
    try {
      // Aici vom încărca progresul salvat din storage
      currentClue.value = huntClues[currentLevel.value] ?? '';
    } catch (e) {
      print('Eroare la încărcarea progresului: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Procesează un cod QR scanat
  Future<void> processQRCode(String qrData) async {
    isLoading.value = true;
    try {
      if (!_qrService.isValidTreasureHuntQR(qrData)) {
        Get.snackbar(
          'Cod Invalid',
          'Acest cod QR nu face parte din Treasure Hunt.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final level = _qrService.extractLevel(qrData);
      if (level != currentLevel.value) {
        Get.snackbar(
          'Nivel Greșit',
          'Acest cod QR este pentru alt nivel. Caută indiciul pentru nivelul curent!',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Calculăm și adăugăm punctele
      final pointsEarned = _qrService.calculatePoints(level!);
      await _loyaltyService.addServicePoints(
        userId: 'current_user_id', // Înlocuiește cu ID-ul real
        serviceType: 'treasure_hunt',
        serviceAmount: pointsEarned.toDouble(),
      );

      // Actualizăm nivelul și indiciul
      currentLevel.value++;
      currentClue.value = huntClues[currentLevel.value] ?? '';
      totalPoints.value += pointsEarned;

      Get.snackbar(
        'Felicitări!',
        'Ai câștigat $pointsEarned puncte! Caută următorul indiciu.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Eroare la procesarea codului QR: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Începe scanarea
  void startScanning() {
    isScanning.value = true;
  }

  // Oprește scanarea
  void stopScanning() {
    isScanning.value = false;
  }
}
