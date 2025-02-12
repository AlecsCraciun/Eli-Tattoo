// lib/controllers/loyalty_controller.dart
import 'package:get/get.dart';
import '../services/loyalty_service.dart';

class LoyaltyController extends GetxController {
  final LoyaltyService _loyaltyService = Get.find();

  // Stare observabilă
  final RxBool isLoading = false.obs;
  final RxInt points = 0.obs;
  final RxList pointsHistory = [].obs;
  final RxList availableRewards = [].obs;

  // Lista de recompense disponibile
  final RxList<Map<String, dynamic>> rewards = [
    {
      'id': 'discount_20',
      'name': 'Reducere 20%',
      'description': 'Reducere de 20% la următorul tatuaj',
      'pointsCost': 500,
    },
    {
      'id': 'free_piercing',
      'name': 'Piercing Gratuit',
      'description': 'Un piercing gratuit la alegere',
      'pointsCost': 300,
    },
    {
      'id': 'priority_booking',
      'name': 'Programare Prioritară',
      'description': 'Prioritate la următoarea programare',
      'pointsCost': 200,
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserPoints();
    loadPointsHistory();
    loadAvailableRewards();
  }

  // Încarcă punctele utilizatorului
  Future<void> loadUserPoints() async {
    isLoading.value = true;
    try {
      const userId = 'current_user_id'; // Înlocuiește cu ID-ul real
      _loyaltyService.getUserPoints(userId).listen((snapshot) {
        points.value = snapshot.data()?['points'] ?? 0;
      });
    } catch (e) {
      print('Eroare la încărcarea punctelor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Încarcă istoricul punctelor
  Future<void> loadPointsHistory() async {
    isLoading.value = true;
    try {
      const userId = 'current_user_id'; // Înlocuiește cu ID-ul real
      _loyaltyService.getPointsHistory(userId).listen((snapshot) {
        pointsHistory.value = snapshot.docs;
      });
    } catch (e) {
      print('Eroare la încărcarea istoricului: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Încarcă recompensele disponibile
  Future<void> loadAvailableRewards() async {
    isLoading.value = true;
    try {
      _loyaltyService.getAvailableRewards().listen((snapshot) {
        availableRewards.value = snapshot.docs;
      });
    } catch (e) {
      print('Eroare la încărcarea recompenselor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Folosește puncte pentru o recompensă
  Future<void> redeemReward(String rewardId, int pointsCost) async {
    isLoading.value = true;
    try {
      const userId = 'current_user_id'; // Înlocuiește cu ID-ul real
      final success = await _loyaltyService.usePointsForReward(
        userId: userId,
        rewardId: rewardId,
        pointsCost: pointsCost,
      );

      if (success) {
        Get.snackbar(
          'Succes',
          'Recompensa a fost activată cu succes!',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Eroare',
          'Nu ai suficiente puncte pentru această recompensă.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('Eroare la folosirea recompensei: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
