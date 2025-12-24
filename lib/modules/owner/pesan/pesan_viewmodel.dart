import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app_session.dart';

/// Ringkasan satu chat (untuk list di tab Pesan owner)
class OwnerChatSummary {
  final String chatId;
  final String userId;
  final String ownerId;
  final String villaId;
  final String userName; // ✅ sekarang REAL dari collection users
  final String villaName;
  final String lastMessage;
  final DateTime? lastTimestamp;
  final int unreadCount;

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

  String get timeText {
    if (lastTimestamp == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastTimestamp!);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt';
    if (diff.inHours < 24) return '${diff.inHours} jam';

    return '${lastTimestamp!.day}/${lastTimestamp!.month}';
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

  /// ================================
  /// AMBIL NAMA USER DARI COLLECTION users
  /// ================================
  Future<String> _getUserName(String userId) async {
    try {
      final doc =
          await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['name'] ?? userId;
      }
      return userId;
    } catch (_) {
      return userId;
    }
  }

  /// ================================
  /// LISTEN CHAT OWNER
  /// ================================
  void _listenOwnerChats() {
    isLoading.value = true;

    _db
        .collection('chats') // sesuaikan kalau nama koleksi beda
        .where('owner_id', isEqualTo: ownerId)
        .snapshots()
        .listen(
      (snapshot) async {
        final List<OwnerChatSummary> temp = [];

        for (final doc in snapshot.docs) {
          final data = doc.data();

          final userId = data['user_id']?.toString() ?? '';
          final userName = await _getUserName(userId);

          temp.add(
            OwnerChatSummary(
              chatId: doc.id,
              userId: userId,
              ownerId: data['owner_id']?.toString() ?? '',
              villaId: data['villa_id']?.toString() ?? '',
              userName: userName, // 🔥 NAMA ASLI USER
              villaName: data['villa_name']?.toString() ?? '',
              lastMessage: data['last_message']?.toString() ?? '',
              lastTimestamp: (data['last_timestamp'] is Timestamp)
                  ? (data['last_timestamp'] as Timestamp).toDate()
                  : null,
              unreadCount: 0,
            ),
          );
        }

        chats.assignAll(temp);
        isLoading.value = false;

        // debug
        // ignore: avoid_print
        print(
          'OwnerPesanViewModel: loaded ${temp.length} chat(s) with real user names',
        );
      },
      onError: (e) {
        // ignore: avoid_print
        print('OwnerPesanViewModel error: $e');
        isLoading.value = false;
      },
    );
  }
}
