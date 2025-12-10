import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'edit_villa/admin_edit_villa_view.dart';
import 'edit_villa/admin_edit_villa_binding.dart';

import 'admin_data_villa_viewmodel.dart';

class AdminDataVillaView extends GetView<AdminDataVillaViewModel> {
  const AdminDataVillaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: judul + tombol refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Villa',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tabel data villa dari Firestore',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              IconButton(
                tooltip: 'Refresh data',
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  controller.loadVillas();
                },
              ),
            ],
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final villas = controller.villas;

              if (villas.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada data villa.\n'
                    'Tambah data dari aplikasi user/owner, lalu klik refresh.',
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
                      DataColumn(label: Text('Nama Villa')),
                      DataColumn(label: Text('Alamat')),
                      DataColumn(label: Text('Kategori')),
                      DataColumn(label: Text('Harga Weekday')),
                      DataColumn(label: Text('Pemilik')),
                      DataColumn(label: Text('Aksi')),
                    ],
                    rows: List.generate(villas.length, (index) {
                      final v = villas[index];

                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(v.name)),
                          DataCell(
                            SizedBox(
                              width: 260,
                              child: Text(
                                v.address,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(v.category)),
                          DataCell(Text('Rp ${v.price.toStringAsFixed(0)}')),
                          DataCell(Text(v.ownerName)),
                          DataCell(
                            Row(
                              children: [
                                // ========= TOMBOL EDIT =========
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC83A),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final updated = await Get.to(
                                      () => const AdminEditVillaView(),
                                      binding: AdminEditVillaBinding(),
                                      arguments: v.id, // id dokumen villa
                                    );

                                    if (updated == true) {
                                      controller.loadVillas(); // refresh tabel
                                    }
                                  },
                                  child: const Text('Edit'),
                                ),
                                const SizedBox(width: 8),
                                // ========= TOMBOL HAPUS =========
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF4D4D),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final confirm =
                                        await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title:
                                                    const Text('Hapus Villa'),
                                                content: Text(
                                                  'Yakin ingin menghapus "${v.name}"?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, false),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            ctx, true),
                                                    child: const Text('Hapus'),
                                                  ),
                                                ],
                                              ),
                                            ) ??
                                            false;

                                    if (confirm) {
                                      await controller.deleteVilla(v.id);
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
          ),
        ],
      ),
    );
  }
}
