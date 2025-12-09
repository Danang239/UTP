import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app_session.dart'; // <-- TAMBAHAN

class ChatRoomViewModel extends GetxController {
  late String villaId;
  late String ownerId;
  late String userId;

  final messageController = ''.obs;
  final messages = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  final isLoading = true.obs;

  DocumentReference<Map<String, dynamic>>? chatDoc;
  CollectionReference<Map<String, dynamic>>? messagesRef;

  // helper: id user yg sedang login (bisa owner / user)
  String? get currentUserId => AppSession.userDocId;

  @override
  void onInit() {
    // Ambil arguments dari Get.to()
    final args = Get.arguments;
    villaId = args['villaId'];
    ownerId = args['ownerId'];
    userId = args['userId'];

    _loadOrCreateChat();
    super.onInit();
  }

  // =============================
  // LOAD CHAT / CREATE CHAT
  // =============================
  Future<void> _loadOrCreateChat() async {
    try {
      final q = await FirebaseFirestore.instance
          .collection('chats')
          .where('user_id', isEqualTo: userId)
          .where('owner_id', isEqualTo: ownerId)
          .where('villa_id', isEqualTo: villaId)
          .limit(1)
          .get();

      if (q.docs.isNotEmpty) {
        chatDoc = q.docs.first.reference;
      } else {
        final newId = '${userId}_${ownerId}_$villaId';
        chatDoc = FirebaseFirestore.instance.collection('chats').doc(newId);

        await chatDoc!.set({
          'villa_id': villaId,
          'owner_id': ownerId,
          'user_id': userId,
          'last_message': '',
          'last_timestamp': FieldValue.serverTimestamp(),
          'created_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      messagesRef = chatDoc!.collection('messages');

      // LISTENING / STREAM FIRESTORE
      messagesRef!
          .orderBy("timestamp", descending: false)
          .snapshots()
          .listen((snap) {
        messages.assignAll(snap.docs);
      });
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat chat: $e");
    }

    isLoading.value = false;
  }

  // =============================
  // SEND MESSAGE
  // =============================
  Future<void> sendMessage() async {
    final text = messageController.value.trim();
    if (text.isEmpty) return;

    // ambil id user yg sedang login (bisa owner / user)
    final senderId = currentUserId;
    if (senderId == null || senderId.isEmpty) {
      Get.snackbar("Error", "User belum login.");
      return;
    }

    messageController.value = "";

    try {
      await messagesRef!.add({
        'sender_id': senderId, // <-- BUKAN lagi userId argumen
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await chatDoc!.set({
        'last_message': text,
        'last_timestamp': FieldValue.serverTimestamp(),
        // field identitas room tetap sama
        'villa_id': villaId,
        'owner_id': ownerId,
        'user_id': userId,
      }, SetOptions(merge: true));
    } catch (e) {
      Get.snackbar("Error", "Gagal mengirim pesan: $e");
    }
  }
}
