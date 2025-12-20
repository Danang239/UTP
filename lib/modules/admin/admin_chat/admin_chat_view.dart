import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_chat_viewmodel.dart';

class AdminChatView extends GetView<AdminChatViewModel> {
  const AdminChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.userName.value.isEmpty
                ? 'Chat Admin'
                : 'Chat dengan ${controller.userName.value}',
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // ======================
          // LIST PESAN (1 USER)
          // ======================
          Expanded(
            child: Obx(() {
              // Pastikan userId sudah ada
              if (controller.userId.value.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('admin_chats')
                    .doc(controller.userId.value)
                    .collection('messages')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada pesan',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final data =
                          messages[index].data() as Map<String, dynamic>;

                      final bool isAdmin =
                          data['sender'] == 'admin';

                      return Align(
                        alignment: isAdmin
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin:
                              const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          constraints:
                              const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Text(
                            data['text'] ?? '',
                            style: TextStyle(
                              color: isAdmin
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }),
          ),

          // ======================
          // INPUT BALASAN ADMIN
          // ======================
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.messageC,
                      decoration: const InputDecoration(
                        hintText: 'Balas pesan...',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.blueAccent,
                    onPressed: controller.sendAdminMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
