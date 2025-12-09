import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app_session.dart';

import 'edit_profile_viewmodel.dart';

class EditProfileView extends GetView<EditProfileViewModel> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FOTO PROFIL
            Obx(() {
              final bytes = controller.imageBytes.value;

              ImageProvider? avatarImage;
              if (bytes != null) {
                avatarImage = MemoryImage(bytes);
              } else if (AppSession.profileImg != null &&
                  AppSession.profileImg!.isNotEmpty) {
                avatarImage = NetworkImage(AppSession.profileImg!);
              }

              return GestureDetector(
                onTap: controller.pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              );
            }),

            const SizedBox(height: 25),

            // NAMA
            TextField(
              controller: controller.nameC,
              decoration: const InputDecoration(
                labelText: "Nama",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // EMAIL
            TextField(
              controller: controller.emailC,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // PASSWORD BARU (OPSIONAL)
            TextField(
              controller: controller.passwordC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password Baru (opsional)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // TOMBOL SIMPAN
            Obx(() {
              if (controller.isLoading.value) {
                return const CircularProgressIndicator();
              }

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Simpan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
