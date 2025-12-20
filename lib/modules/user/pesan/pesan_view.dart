import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:utp_flutter/modules/user/pesan/pesan_viewmodel.dart';

class PesanView extends GetView<PesanViewModel> {
  const PesanView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final userId = controller.userId.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // ===== JUDUL =====
                Text(
                  'Pesan',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: userId == null
                      ? Center(
                          child: Text(
                            'Silakan login untuk melihat pesan',
                            style: theme.textTheme.bodyMedium,
                          ),
                        )
                      : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: controller.chatsStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Terjadi kesalahan:\n${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Text(
                                  'Belum ada percakapan',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              );
                            }

                            final chatDocs = snapshot.data!.docs;

                            return ListView.separated(
                              itemCount: chatDocs.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final chatDoc = chatDocs[index];
                                final data = chatDoc.data();

                                final villaId = data['villa_id'] ?? '';
                                final ownerId = data['owner_id'] ?? '';
                                final lastMessage =
                                    data['last_message'] ?? '';

                                return FutureBuilder<Map<String, dynamic>?>(
                                  future:
                                      controller.getVillaDetail(villaId),
                                  builder: (context, villaSnap) {
                                    String name = 'Chat Villa';

                                    if (villaSnap.hasData &&
                                        villaSnap.data != null) {
                                      final villa = villaSnap.data!;
                                      name =
                                          villa['name'] ?? 'Chat Villa';
                                    }

                                    final message = lastMessage.isEmpty
                                        ? "Tap untuk membuka chat"
                                        : lastMessage;

                                    return _chatTile(
                                      context,
                                      name,
                                      message,
                                      0,
                                      villaId,
                                      ownerId,
                                      userId.toString(),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // =========================
  //  CHAT TILE (THEME AWARE)
  // =========================
  Widget _chatTile(
    BuildContext context,
    String name,
    String message,
    int unread,
    String villaId,
    String ownerId,
    String userId,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Get.toNamed(
          '/chat-room',
          arguments: {
            'villaId': villaId,
            'ownerId': ownerId,
            'userId': userId,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // ===== AVATAR =====
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'C',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ===== TEXT =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // ===== UNREAD =====
            if (unread > 0)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unread.toString(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
