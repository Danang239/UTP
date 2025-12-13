import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_data_owner_viewmodel.dart';

class AdminDataOwnerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDataOwnerViewModel>();

    // Memanggil fungsi untuk mengambil data owner saat halaman dibuka
    controller.loadOwners();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Owner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menampilkan status loading atau error jika ada
            Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Text(
                    'Terjadi kesalahan:\n${controller.errorMessage.value}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final owners = controller.owners;

              if (owners.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada data owner.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 4,
                      offset: Offset(0, 2),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowColor: MaterialStateProperty.all(
                      const Color(0xFFF4F0FF),
                    ),
                    columns: const [
                      DataColumn(label: Text('No')),
                      DataColumn(label: Text('Nama Owner')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Nomor Telepon')),
                      DataColumn(label: Text('Peran')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: List.generate(owners.length, (index) {
                      final owner = owners[index];

                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(owner.name)),
                          DataCell(Text(owner.email)),
                          DataCell(Text(owner.phone)),
                          DataCell(Text(owner.role)),
                          DataCell(
                            Row(
                              children: [
                                // Tombol Detail
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFF673AB7),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    // Aksi Detail: Pindah ke halaman detail
                                    Get.toNamed('/ownerDetail', arguments: owner.id);
                                  },
                                  child: const Text('Detail'),
                                ),
                                const SizedBox(width: 8),
                                // Tombol Edit
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC83A),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    // Aksi Edit: Pindah ke halaman edit dengan data owner
                                    Get.toNamed('/editOwner', arguments: owner.id);
                                  },
                                  child: const Text('Edit'),
                                ),
                                const SizedBox(width: 8),
                                // Tombol Hapus
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF4D4D),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Hapus Owner'),
                                            content: Text('Yakin ingin menghapus "${owner.name}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, false),
                                                child: const Text('Batal'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(ctx, true),
                                                child: const Text('Hapus'),
                                              ),
                                            ],
                                          ),
                                        ) ??
                                        false;

                                    if (confirm) {
                                      await controller.deleteOwner(owner.id);  // Hapus owner
                                    }
                                  },
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
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
