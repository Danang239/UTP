import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app/routes/app_routes.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_data_owner_viewmodel.dart';

class AdminDataOwnerView
    extends
        GetView<
          AdminDataOwnerViewModel
        > {
  const AdminDataOwnerView({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Owner',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
            ),
            tooltip: 'Tambah Owner',
            onPressed: () => _showCreateOwnerDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Obx(
          () {
            // =============================
            // LOADING
            // =============================
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // =============================
            // ERROR
            // =============================
            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Text(
                  controller.errorMessage.value,
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            // =============================
            // EMPTY STATE
            // =============================
            if (controller.owners.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada data owner',
                ),
              );
            }

            // =============================
            // DATA TABLE
            // =============================
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  16,
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 4,
                    offset: Offset(
                      0,
                      2,
                    ),
                    color: Colors.black12,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  headingRowColor: MaterialStateProperty.all(
                    const Color(
                      0xFFF4F0FF,
                    ),
                  ),
                  columns: const [
                    DataColumn(
                      label: Text(
                        'No',
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Nama Owner',
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Email',
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Nomor Telepon',
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Peran',
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Aksi',
                      ),
                    ),
                  ],
                  rows: List.generate(
                    controller.owners.length,
                    (
                      index,
                    ) {
                      final owner = controller.owners[index];
                      final aktif = owner.isActive;

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${index + 1}',
                            ),
                          ),
                          DataCell(
                            Text(
                              owner.name,
                            ),
                          ),
                          DataCell(
                            Text(
                              owner.email,
                            ),
                          ),
                          DataCell(
                            Text(
                              owner.phone,
                            ),
                          ),
                          DataCell(
                            Text(
                              owner.role,
                            ),
                          ),
                          DataCell(
                            Text(
                              aktif
                                  ? 'Aktif'
                                  : 'Nonaktif',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: aktif
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                // =============================
                                // DETAIL (✅ route fix)
                                // =============================
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF673AB7,
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Get.toNamed(
                                      Routes.adminOwnerDetail,
                                      arguments: owner.id,
                                    );
                                  },
                                  child: const Text(
                                    'Detail',
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),

                                // =============================
                                // AKTIF / NONAKTIF (TOGGLE)
                                // =============================
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: aktif
                                        ? const Color(
                                            0xFFFF4D4D,
                                          )
                                        : Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final bool confirm =
                                        await showDialog<
                                          bool
                                        >(
                                          context: context,
                                          builder:
                                              (
                                                ctx,
                                              ) => AlertDialog(
                                                title: Text(
                                                  aktif
                                                      ? 'Nonaktifkan Owner'
                                                      : 'Aktifkan Owner',
                                                ),
                                                content: Text(
                                                  aktif
                                                      ? 'Yakin ingin menonaktifkan "${owner.name}"?'
                                                      : 'Yakin ingin mengaktifkan kembali "${owner.name}"?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(
                                                      ctx,
                                                      false,
                                                    ),
                                                    child: const Text(
                                                      'Batal',
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(
                                                      ctx,
                                                      true,
                                                    ),
                                                    child: Text(
                                                      aktif
                                                          ? 'Nonaktifkan'
                                                          : 'Aktifkan',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        ) ??
                                        false;

                                    if (!confirm) return;

                                    await controller.toggleActiveOwner(
                                      ownerId: owner.id,
                                      makeActive: !aktif,
                                    );
                                  },
                                  child: Text(
                                    aktif
                                        ? 'Nonaktifkan'
                                        : 'Aktifkan',
                                  ),
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                // =============================
                                // HAPUS (HARD DELETE FIRESTORE)
                                // =============================
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    final bool confirm =
                                        await showDialog<
                                          bool
                                        >(
                                          context: context,
                                          builder:
                                              (
                                                ctx,
                                              ) => AlertDialog(
                                                title: const Text(
                                                  'Hapus Owner',
                                                ),
                                                content: Text(
                                                  'Hapus permanen data owner "${owner.name}" dari Firestore?\n\nCatatan: ini hanya menghapus dokumen users/${owner.id}.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(
                                                      ctx,
                                                      false,
                                                    ),
                                                    child: const Text(
                                                      'Batal',
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(
                                                      ctx,
                                                      true,
                                                    ),
                                                    child: const Text(
                                                      'Hapus',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        ) ??
                                        false;

                                    if (!confirm) return;

                                    await controller.hardDeleteOwner(
                                      owner.id,
                                    );
                                  },
                                  child: const Text(
                                    'Hapus',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // =====================================================
  // DIALOG CREATE OWNER
  // =====================================================
  void _showCreateOwnerDialog() {
    final nameC = TextEditingController();
    final emailC = TextEditingController();
    final phoneC = TextEditingController();
    final passwordC = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text(
          'Tambah Owner',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameC,
              decoration: const InputDecoration(
                labelText: 'Nama',
              ),
            ),
            TextField(
              controller: emailC,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: phoneC,
              decoration: const InputDecoration(
                labelText: 'No. Telepon',
              ),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: passwordC,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Batal',
            ),
          ),
          ElevatedButton(
            child: const Text(
              'Simpan',
            ),
            onPressed: () async {
              final name = nameC.text.trim();
              final email = emailC.text.trim();
              final phone = phoneC.text.trim();
              final password = passwordC.text;

              if (name.isEmpty ||
                  email.isEmpty ||
                  phone.isEmpty ||
                  password.isEmpty) {
                Get.snackbar(
                  'Validasi',
                  'Semua field wajib diisi',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              // 🔥 TUTUP DIALOG DULU (AMAN)
              Get.back();

              await controller.createOwner(
                name: name,
                email: email,
                phone: phone,
                password: password,
              );
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
