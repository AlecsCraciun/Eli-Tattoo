// lib/controllers/booking_controller.dart
import 'package:get/get.dart';
import '../services/booking_service.dart';
import '../services/notification_service.dart';

class BookingController extends GetxController {
  final BookingService _bookingService = Get.find();
  final NotificationService _notificationService = Get.find();

  // Stare observabilă
  final RxBool isLoading = false.obs;
  final RxList appointments = [].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString selectedArtist = ''.obs;
  final RxString selectedService = ''.obs;

  // Lista de artiști disponibili
  final RxList<Map<String, dynamic>> availableArtists = [
    {
      'id': 'alecs',
      'name': 'Alecs',
      'services': ['Toate stilurile'],
    },
    {
      'id': 'denis',
      'name': 'Denis',
      'services': ['Fine Line', 'Microrealism', 'Black Work', 'Stippling'],
    },
    {
      'id': 'blanca',
      'name': 'Blanca',
      'services': ['Piercing'],
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadAppointments();
  }

  // Încarcă programările
  Future<void> loadAppointments() async {
    isLoading.value = true;
    try {
      const userId = 'current_user_id'; // Înlocuiește cu ID-ul real
      _bookingService.getUserAppointments(userId).listen((snapshot) {
        appointments.value = snapshot.docs;
      });
    } catch (e) {
      print('Eroare la încărcarea programărilor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Verifică disponibilitatea
  Future<bool> checkAvailability() async {
    if (selectedArtist.value.isEmpty) {
      return false;
    }
    return await _bookingService.checkAvailability(
      selectedDate.value,
      selectedArtist.value,
    );
  }

  // Creează o programare nouă
  Future<void> createAppointment({
    required String description,
    String? referenceImage,
  }) async {
    isLoading.value = true;
    try {
      await _bookingService.createAppointment(
        userId: 'current_user_id', // Înlocuiește cu ID-ul real
        artistId: selectedArtist.value,
        dateTime: selectedDate.value,
        serviceType: selectedService.value,
        description: description,
        referenceImage: referenceImage,
      );

      // Trimite notificare
      // Implementează logica de notificare
      
      Get.snackbar(
        'Succes',
        'Programarea a fost creată cu succes!',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('Eroare la crearea programării: $e');
      Get.snackbar(
        'Eroare',
        'Nu am putut crea programarea. Încearcă din nou.',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
