// lib/modules/pesan/pesan_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:utp_flutter/modules/user/pesan/pesan_viewmodel.dart';

class PesanView extends GetView<PesanViewModel> {
  const PesanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final userId = controller.userId.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // FILTER BUTTON (UI sama)
                Row(
                  children: [
                    _filterButton("Semua", selected: true),
                    const SizedBox(width: 8),
                    _filterButton("Belum dibaca"),
                    const SizedBox(width: 8),
                    _filterButton("Selesai"),
                  ],
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: userId == null
                      ? const Center(
                          child: Text('Silakan login untuk melihat pesan'),
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
                                  'Terjadi kesalahan: ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text('Belum ada percakapan'),
                              );
                            }

                            final chatDocs = snapshot.data!.docs;

                            return ListView.builder(
                              itemCount: chatDocs.length,
                              itemBuilder: (context, index) {
                                final chatDoc = chatDocs[index];
                                final data = chatDoc.data();

                                final villaId = data['villa_id'] ?? '';
                                final ownerId = data['owner_id'] ?? '';
                                final lastMessage =
                                    data['last_message'] ?? '';

                                return FutureBuilder<Map<String, dynamic>?>(
                                  future: controller.getVillaDetail(villaId),
                                  builder: (context, villaSnap) {
                                    String name = 'Chat Villa';

                                    if (villaSnap.hasData &&
                                        villaSnap.data != null) {
                                      final villa = villaSnap.data!;
                                      name = villa['name'] ?? 'Chat Villa';
                                    }

                                    final message = lastMessage.isEmpty
                                        ? "Tap untuk membuka chat"
                                        : lastMessage;

                                    return _chatTile(
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

  // ==== CHAT TILE ====
  Widget _chatTile(
    String name,
    String message,
    int unread,
    String villaId,
    String ownerId,
    String userId,
  ) {
    return GestureDetector(
      onTap: () {
        // Pakai route GetX ke modules/chat_room
        Get.toNamed(
          '/chat-room',
          arguments: {
            'villaId': villaId,
            'ownerId': ownerId,
            'userId': userId,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'C',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (unread > 0)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==== FILTER BUTTON UI ====
  Widget _filterButton(String text, {bool selected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.black : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
