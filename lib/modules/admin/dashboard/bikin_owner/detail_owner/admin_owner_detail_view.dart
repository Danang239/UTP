import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/detail_owner/admin_owner_detail_viewmodel.dart';

class AdminOwnerDetailView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ambil ownerId dari parameter
    final String ownerId = Get.arguments;

    // Ambil ViewModel
    final controller = Get.find<AdminOwnerDetailViewModel>();

    // Memanggil fungsi loadOwnerAndVillas untuk mengambil data owner dan villa
    controller.loadOwnerAndVillas(ownerId);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          'Detail Owner - ${controller.owner.value.name}',
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Owner
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Text(
                    'Error: ${controller.errorMessage.value}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final owner = controller.owner.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    owner.name ?? 'Tidak ada nama',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(owner.email ?? 'Tidak ada email'),
                  const SizedBox(height: 4),
                  Text(owner.phone ?? 'Tidak ada telepon'),
                  const SizedBox(height: 16),
                  const Text(
                    'Villas owned by this owner:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),

            // Tampilkan daftar villa yang dimiliki oleh owner
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final villas = controller.villas;

              if (villas.isEmpty) {
                return const Center(
                  child: Text('This owner has no villas.'),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: villas.length,
                  itemBuilder: (ctx, index) {
                    final villa = villas[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(villa['name'] ?? 'Nama villa tidak tersedia'),
                        subtitle: Text(villa['address'] ?? 'Alamat tidak tersedia'),
                        trailing: Text('Rp ${villa['price'] != null ? villa['price'].toStringAsFixed(0) : '0'}'),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
