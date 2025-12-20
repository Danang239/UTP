import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utp_flutter/app/routes/app_routes.dart';

class AdminMessagesView extends StatelessWidget {
  const AdminMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan User'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('admin_chats')
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada pesan'));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final data =
                  chats[index].data() as Map<String, dynamic>;

              final userId = data['userId'];
              final userName = data['userName'] ?? 'User';
              final lastMessage = data['lastMessage'] ?? '';

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(userName),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // 🔥 PINDAH KE HALAMAN CHAT ROOM
                  Get.toNamed(
                    Routes.adminChat,
                    arguments: {
                      'userId': userId,
                      'userName': userName,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
