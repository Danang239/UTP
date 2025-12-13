import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_data_owner_viewmodel.dart';

class AdminOwnerEditView extends StatelessWidget {
  final String ownerId = Get.arguments;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDataOwnerViewModel>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    // Memanggil fungsi untuk mengambil data owner dan mengisi formulir
    controller.loadOwners();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Owner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama Owner'),
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Nomor Telepon'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.updateOwner(
                  ownerId,
                  nameController.text,
                  emailController.text,
                  phoneController.text,
                );
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }
}
