import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../admin_data_user_viewmodel.dart';
import 'admin_user_detail_viewmodel.dart';

class AdminUserDetailView extends GetView<AdminUserDetailViewModel> {
  const AdminUserDetailView({super.key});

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final AdminUserItem user = controller.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3E9FF),
        elevation: 0,
        title: Text(
          'Detail User - ${user.name}',
          style: const TextStyle(color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info user
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 4),
            Text('Terdaftar: ${_fmtDate(user.createdAt)}'),
            const SizedBox(height: 16),
            const Text(
              'Riwayat Booking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text(
                      'Terjadi kesalahan:\n${controller.errorMessage.value}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final list = controller.bookings;
                if (list.isEmpty) {
                  return const Center(
                    child: Text('Belum ada booking dari user ini.'),
                  );
                }

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (ctx, index) {
                    final b = list[index];
                    return ListTile(
                      title: Text(b.villaName),
                      subtitle: Text(
                        'Check-in: ${_fmtDate(b.checkIn)}  |  '
                        'Check-out: ${_fmtDate(b.checkOut)}\n'
                        'Status: ${b.status}',
                      ),
                      trailing: Text('Rp ${b.totalPrice}'),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
