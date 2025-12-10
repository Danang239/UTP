import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'admin_data_user_viewmodel.dart';
import 'widgets/user_table.dart';

class AdminDataUserView extends GetView<AdminDataUserViewModel> {
  const AdminDataUserView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data User',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Daftar pengguna aplikasi Stay&Co',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(
                  child: Text(
                    'Terjadi kesalahan:\n${controller.errorMessage.value}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return UserTable(users: controller.users);
            }),
          ),
        ],
      ),
    );
  }
}
