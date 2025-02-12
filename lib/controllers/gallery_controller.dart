// lib/controllers/gallery_controller.dart
import 'package:get/get.dart';
import '../services/gallery_service.dart';

class GalleryController extends GetxController {
  final GalleryService _galleryService = Get.find();

  // Stare observabilă
  final RxBool isLoading = false.obs;
  final RxList portfolioItems = [].obs;
  final RxString selectedArtist = ''.obs;
  final RxString selectedStyle = ''.obs;
  final RxList<String> availableStyles = <String>[
    'Fine Line',
    'Microrealism',
    'Black Work',
    'Stippling',
    'Piercing'
  ].obs;

  // Lista de artiști
  final RxList<Map<String, dynamic>> artists = [
    {
      'id': 'alecs',
      'name': 'Alecs',
      'specialties': ['Toate stilurile'],
    },
    {
      'id': 'denis',
      'name': 'Denis',
      'specialties': ['Fine Line', 'Microrealism', 'Black Work', 'Stippling'],
    },
    {
      'id': 'blanca',
      'name': 'Blanca',
      'specialties': ['Piercing'],
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadPortfolio();
  }

  // Încarcă toate lucrările
  Future<void> loadPortfolio() async {
    isLoading.value = true;
    try {
      _galleryService.getAllWorks().listen((snapshot) {
        portfolioItems.value = snapshot.docs;
      });
    } catch (e) {
      print('Eroare la încărcarea portofoliului: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrează după artist
  void filterByArtist(String artistId) {
    isLoading.value = true;
    selectedArtist.value = artistId;
    try {
      _galleryService.getArtistWorks(artistId).listen((snapshot) {
        portfolioItems.value = snapshot.docs;
      });
    } catch (e) {
      print('Eroare la filtrarea după artist: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrează după stil
  void filterByStyle(String style) {
    isLoading.value = true;
    selectedStyle.value = style;
    try {
      _galleryService.getWorksByStyle(style).listen((snapshot) {
        portfolioItems.value = snapshot.docs;
      });
    } catch (e) {
      print('Eroare la filtrarea după stil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Resetează filtrele
  void resetFilters() {
    selectedArtist.value = '';
    selectedStyle.value = '';
    loadPortfolio();
  }
}
