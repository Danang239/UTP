import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_data_owner_viewmodel.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_owner_item.dart';

class AdminOwnerEditView extends StatefulWidget {
  const AdminOwnerEditView({super.key});

  @override
  State<AdminOwnerEditView> createState() => _AdminOwnerEditViewState();
}

class _AdminOwnerEditViewState extends State<AdminOwnerEditView> {
  late final String ownerId;
  late final AdminDataOwnerViewModel controller;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    ownerId = Get.arguments as String;
    controller = Get.find<AdminDataOwnerViewModel>();

    // 🔥 Pastikan data owner sudah ada
    if (controller.owners.isEmpty) {
      controller.loadOwners();
    }

    // 🔥 Isi form setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final AdminOwnerItem? owner = controller.owners
          .firstWhereOrNull((o) => o.id == ownerId);

      if (owner != null) {
        nameController.text = owner.name;
        emailController.text = owner.email;
        phoneController.text = owner.phone;
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Owner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Owner',
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await controller.updateOwner(
                      ownerId: ownerId,
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      phone: phoneController.text.trim(),
                    );

                    Get.back(); // kembali ke list owner
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
