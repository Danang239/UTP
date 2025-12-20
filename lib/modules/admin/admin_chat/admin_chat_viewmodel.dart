import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminChatViewModel extends GetxController {
  final TextEditingController messageC = TextEditingController();

  final RxString userId = ''.obs;
  final RxString userName = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    debugPrint('🔥 AdminChat args = $args');

    if (args == null || args['userId'] == null) {
      Get.snackbar('Error', 'Data user tidak ditemukan');
      return;
    }

    userId.value = args['userId'];
    userName.value = args['userName'] ?? 'User';
  }

  // ======================
  // ADMIN KIRIM BALASAN
  // ======================
  Future<void> sendAdminMessage() async {
    final text = messageC.text.trim();

    debugPrint('🔥 sendAdminMessage');
    debugPrint('🔥 userId = ${userId.value}');
    debugPrint('🔥 text = $text');

    if (text.isEmpty || userId.value.isEmpty) return;

    final chatRef =
        FirebaseFirestore.instance.collection('admin_chats').doc(userId.value);

    // 1️⃣ simpan pesan admin
    await chatRef.collection('messages').add({
      'sender': 'admin', // ✅ PENTING
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2️⃣ update summary chat
    await chatRef.set({
      'userId': userId.value,
      'userName': userName.value,
      'lastMessage': text,
      'lastSender': 'admin', // ✅
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    messageC.clear();
  }

  @override
  void onClose() {
    messageC.dispose();
    super.onClose();
  }
}
