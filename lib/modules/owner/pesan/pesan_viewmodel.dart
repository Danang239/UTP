import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app_session.dart';

/// Ringkasan satu chat (untuk list di tab Pesan owner)
class OwnerChatSummary {
  final String chatId;
  final String userId;
  final String ownerId;
  final String villaId;
  final String userName;    // sementara pakai 'User' saja
  final String villaName;   // kosong kalau belum ada field-nya
  final String lastMessage;
  final DateTime? lastTimestamp;
  final int unreadCount;    // sementara 0 (belum dipakai)

  OwnerChatSummary({
    required this.chatId,
    required this.userId,
    required this.ownerId,
    required this.villaId,
    required this.userName,
    required this.villaName,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.unreadCount,
  });

  /// Teks waktu singkat untuk di UI (kanan atas tile)
  String get timeText {
    if (lastTimestamp == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastTimestamp!);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt';
    if (diff.inHours < 24) return '${diff.inHours} jam';

    return '${lastTimestamp!.day}/${lastTimestamp!.month}';
  }

  factory OwnerChatSummary.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return OwnerChatSummary(
      chatId: doc.id,
      userId: data['user_id']?.toString() ?? '',
      ownerId: data['owner_id']?.toString() ?? '',
      villaId: data['villa_id']?.toString() ?? '',
      // kalau belum ada field user_name / villa_name, pakai default simple
      userName: data['user_name']?.toString() ?? 'User',
      villaName: data['villa_name']?.toString() ?? '',
      lastMessage: data['last_message']?.toString() ?? '',
      lastTimestamp: (data['last_timestamp'] is Timestamp)
          ? (data['last_timestamp'] as Timestamp).toDate()
          : null,
      // belum ada field unread di Firestore → 0 dulu
      unreadCount: 0,
    );
  }
}

class OwnerPesanViewModel extends GetxController {
  final chats = <OwnerChatSummary>[].obs;
  final isLoading = false.obs;

  final _db = FirebaseFirestore.instance;

  String get ownerId => AppSession.userDocId ?? '';

  @override
  void onInit() {
    super.onInit();
    if (ownerId.isNotEmpty) {
      _listenOwnerChats();
    }
  }

  void _listenOwnerChats() {
    isLoading.value = true;

    // GANTI nama koleksi di sini kalau di Firestore kamu beda (misal "chat_rooms")
    _db
        .collection('chats')
        .where('owner_id', isEqualTo: ownerId)
        // sementara TANPA orderBy supaya tidak butuh index komposit
        .snapshots()
        .listen(
      (snapshot) {
        final list =
            snapshot.docs.map((d) => OwnerChatSummary.fromDoc(d)).toList();

        // debug: lihat di console berapa chat yang ketemu
        // ignore: avoid_print
        print('OwnerPesanViewModel: loaded ${list.length} chat(s) for ownerId=$ownerId');

        chats.assignAll(list);
        isLoading.value = false;
      },
      onError: (e) {
        // ignore: avoid_print
        print('OwnerPesanViewModel error: $e');
        isLoading.value = false;
      },
    );
  }
}
