import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserChatViewModel extends GetxController {
  final TextEditingController messageC = TextEditingController();

  late String userId;
  late String userName;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    userId = args['userId'];
    userName = args['userName'];
  }

  Future<void> sendUserMessage() async {
    final text = messageC.text.trim();
    if (text.isEmpty) return;

    final chatRef = FirebaseFirestore.instance
        .collection('admin_chats')
        .doc(userId);

    // 1️⃣ pesan dari USER
    await chatRef.collection('messages').add({
      'sender': 'user', // ✅ BENAR
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2️⃣ update ringkasan chat
    await chatRef.set({
      'userId': userId,
      'userName': userName,
      'lastMessage': text,
      'lastSender': 'user',
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
