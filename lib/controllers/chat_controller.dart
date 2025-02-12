// lib/controllers/chat_controller.dart
import 'package:get/get.dart';
import '../services/chat_service.dart';

class ChatController extends GetxController {
  final ChatService _chatService = Get.find();

  // Stare observabilă
  final RxBool isLoading = false.obs;
  final RxList chats = [].obs;
  final RxList messages = [].obs;
  final RxString currentChatId = ''.obs;
  final RxString selectedArtist = ''.obs;

  // Lista de artiști disponibili pentru chat
  final RxList<Map<String, dynamic>> artists = [
    {
      'id': 'alecs',
      'name': 'Alecs',
      'role': 'Owner & Artist',
      'status': 'online',
    },
    {
      'id': 'denis',
      'name': 'Denis',
      'role': 'Artist',
      'status': 'offline',
    },
    {
      'id': 'blanca',
      'name': 'Blanca',
      'role': 'Piercing Specialist',
      'status': 'online',
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  // Încarcă toate chat-urile utilizatorului
  Future<void> loadChats() async {
    isLoading.value = true;
    try {
      const userId = 'current_user_id'; // Înlocuiește cu ID-ul real
      _chatService.getUserChats(userId).listen((snapshot) {
        chats.value = snapshot.docs;
      });
    } catch (e) {
      print('Eroare la încărcarea chat-urilor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Încarcă mesajele pentru un chat specific
  Future<void> loadMessages(String chatId) async {
    isLoading.value = true;
    try {
      currentChatId.value = chatId;
      _chatService.getChatMessages(chatId).listen((snapshot) {
        messages.value = snapshot.docs;
        markMessagesAsRead(chatId);
      });
    } catch (e) {
      print('Eroare la încărcarea mesajelor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Trimite un mesaj nou
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty || currentChatId.value.isEmpty) return;

    try {
      await _chatService.sendMessage(
        currentChatId.value,
        'current_user_id', // Înlocuiește cu ID-ul real
        message,
      );
    } catch (e) {
      print('Eroare la trimiterea mesajului: $e');
      Get.snackbar(
        'Eroare',
        'Nu am putut trimite mesajul. Încearcă din nou.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Marchează mesajele ca citite
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      await _chatService.markMessagesAsRead(
        chatId,
        'current_user_id', // Înlocuiește cu ID-ul real
      );
    } catch (e) {
      print('Eroare la marcarea mesajelor ca citite: $e');
    }
  }

  // Începe un chat nou cu un artist
  Future<void> startNewChat(String artistId) async {
    isLoading.value = true;
    try {
      const userId = 'current_user_id'; // Înlocuiește cu ID-ul real
      final chatId = await _chatService.createOrGetChat(userId, artistId);
      currentChatId.value = chatId;
      selectedArtist.value = artistId;
      loadMessages(chatId);
    } catch (e) {
      print('Eroare la crearea chat-ului nou: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
