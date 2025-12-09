import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_messages_viewmodel.dart';

class AdminMessagesView extends GetView<AdminMessagesViewModel> {
  const AdminMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan (Admin)'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null) {
          return Center(
            child: Text(
              controller.errorMessage.value!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (controller.chats.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada chat.\nUser yang menghubungi admin akan muncul di sini.',
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.chats.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, index) {
            final chat = controller.chats[index];
            final userName = chat['userName'] ?? 'User';
            final lastMessage = chat['lastMessage'] ?? '';

            return ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(userName),
              subtitle: Text(
                lastMessage.isEmpty ? '(Belum ada pesan)' : lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => controller.openChatDetail(chat),
            );
          },
        );
      }),
    );
  }
}
