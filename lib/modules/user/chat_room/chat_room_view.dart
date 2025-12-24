import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app_session.dart';
import 'chat_room_viewmodel.dart';

class ChatRoomView extends GetView<ChatRoomViewModel> {
  const ChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat Pemilik"),
        centerTitle: true,

        // ✅ THEME AWARE (DARK / LIGHT AMAN)
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // =====================
            // LIST CHAT
            // =====================
            Expanded(
              child: controller.messages.isEmpty
                  ? const Center(child: Text("Belum ada chat"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, i) {
                        final msg = controller.messages[i].data();
                        final text = msg['text'] ?? '';
                        final String? sender = msg['sender_id'];

                        final bool isMe =
                            sender == AppSession.userDocId;

                      
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 12,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? Colors.black : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              text,
                              style: TextStyle(
                                color:
                                    isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // =====================
            // INPUT AREA
            // =====================
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "Tulis pesan...",
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (v) =>
                            controller.messageController.value = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: controller.sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
