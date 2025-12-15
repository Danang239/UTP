import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/detail_owner/admin_owner_detail_viewmodel.dart';

class AdminOwnerDetailView extends StatefulWidget {
  const AdminOwnerDetailView({super.key});

  @override
  State<AdminOwnerDetailView> createState() => _AdminOwnerDetailViewState();
}

class _AdminOwnerDetailViewState extends State<AdminOwnerDetailView> {
  late final String ownerId;
  late final AdminOwnerDetailViewModel controller;

  @override
  void initState() {
    super.initState();

    ownerId = Get.arguments as String;
    controller = Get.find<AdminOwnerDetailViewModel>();

    // 🔥 PANGGIL SEKALI SAJA
    controller.loadOwnerAndVillas(ownerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final owner = controller.owner.value;
          return Text(
            owner == null
                ? 'Detail Owner'
                : 'Detail Owner - ${owner.name}',
          );
        }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() {
          // =============================
          // LOADING
          // =============================
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // =============================
          // ERROR
          // =============================
          if (controller.errorMessage.value.isNotEmpty) {
            return Center(
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final owner = controller.owner.value;

          if (owner == null) {
            return const Center(
              child: Text('Data owner tidak tersedia'),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =============================
              // OWNER INFO
              // =============================
              Text(
                owner.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(owner.email),
              const SizedBox(height: 4),
              Text(owner.phone),

              const SizedBox(height: 20),

              const Text(
                'Villa milik owner:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // =============================
              // VILLA LIST
              // =============================
              Expanded(
                child: controller.villas.isEmpty
                    ? const Center(
                        child: Text('Owner ini belum memiliki villa'),
                      )
                    : ListView.builder(
                        itemCount: controller.villas.length,
                        itemBuilder: (ctx, index) {
                          final villa = controller.villas[index];

                          return Card(
                            margin:
                                const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                villa['name'] ??
                                    'Nama villa tidak tersedia',
                              ),
                              subtitle: Text(
                                villa['location'] ??
                                    villa['address'] ??
                                    'Alamat tidak tersedia',
                              ),
                              trailing: Text(
                                'Rp ${villa['price'] ?? villa['weekday_price'] ?? 0}',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
