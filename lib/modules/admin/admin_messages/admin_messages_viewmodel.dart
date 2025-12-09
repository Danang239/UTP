import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMessagesViewModel extends GetxController {
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // daftar chat (1 row per user)
  final chats = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  Future<void> loadChats() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final snap =
          await FirebaseFirestore.instance.collection('chats').get();

      final list = <Map<String, dynamic>>[];

      for (final doc in snap.docs) {
        final data = doc.data();

        list.add({
          'id': doc.id,
          'userName': data['user_name'] ?? 'User',
          'lastMessage': data['last_message'] ?? '',
          'updatedAt': data['updated_at'], // boleh null
        });
      }

      chats.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void openChatDetail(Map<String, dynamic> chat) {
    // TODO: nanti sambungkan ke halaman chat detail admin
    // misalnya Get.toNamed(Routes.adminChatDetail, arguments: chat);
    Get.snackbar(
      'Buka Chat',
      'Buka chat dengan ${chat['userName']} (id: ${chat['id']})',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
