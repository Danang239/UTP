import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMessagesViewModel extends GetxController {
  final TextEditingController messageC = TextEditingController();

  final _db = FirebaseFirestore.instance;

  // room yang sedang dibuka
  final selectedUserId = ''.obs;
  final selectedUserName = ''.obs;

  // ===============================
  //  PILIH ROOM (DARI LIST)
  // ===============================
  void openRoom(String userId, String userName) {
    selectedUserId.value = userId;
    selectedUserName.value = userName;
    messageC.clear();
  }

  // ===============================
  //  BALAS PESAN (ADMIN)
  // ===============================
  Future<void> sendReply() async {
    final text = messageC.text.trim();
    if (text.isEmpty) return;
    if (selectedUserId.value.isEmpty) return;

    final chatRef =
        _db.collection('admin_chats').doc(selectedUserId.value);

    final messagesRef = chatRef.collection('messages');

    // kirim pesan admin
    await messagesRef.add({
      'sender': 'admin',
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // update ringkasan chat
    await chatRef.update({
      'lastMessage': text,
      'lastSender': 'admin',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    messageC.clear();
  }

  @override
  void onClose() {
    messageC.dispose();
    super.onClose();
  }
}
