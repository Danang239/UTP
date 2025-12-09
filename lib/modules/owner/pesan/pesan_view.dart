import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pesan_viewmodel.dart';

// pakai ChatRoom milik user
import 'package:utp_flutter/modules/user/chat_room/chat_room_view.dart';
import 'package:utp_flutter/modules/user/chat_room/chat_room_binding.dart';

class OwnerPesanView extends GetView<OwnerPesanViewModel> {
  const OwnerPesanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'STAY & Co',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final chats = controller.chats;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chats.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada pesan.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: chats.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final chat = chats[index];

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person),
                ),
                title: Text(
                  chat.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  chat.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // teks waktu terakhir chat
                    Text(
                      chat.timeText,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // badge jumlah pesan belum dibaca
                    if (chat.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${chat.unreadCount}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                // KETIKA OWNER TAP CHAT -> MASUK KE CHAT ROOM
                onTap: () {
                  Get.to(
                    () => const ChatRoomView(),
                    binding: ChatRoomBinding(),
                    arguments: {
                      'villaId': chat.villaId,
                      'ownerId': chat.ownerId,
                      'userId': chat.userId,
                    },
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
