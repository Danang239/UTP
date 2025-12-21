import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_owner_detail_viewmodel.dart';

class AdminOwnerDetailView
    extends
        GetView<
          AdminOwnerDetailViewModel
        > {
  const AdminOwnerDetailView({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Owner',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed: controller.loadDetail,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16,
        ),
        child: Obx(
          () {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

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

            return ListView(
              children: [
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Owner',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _row(
                        'UID',
                        controller.ownerId.value,
                      ),
                      _row(
                        'Nama',
                        controller.name.value,
                      ),
                      _row(
                        'Email',
                        controller.email.value,
                      ),
                      _row(
                        'Telepon',
                        controller.phone.value,
                      ),
                      _row(
                        'Role',
                        controller.role.value,
                      ),
                      _row(
                        'Status',
                        controller.isActive.value
                            ? 'Aktif'
                            : 'Nonaktif',
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Villa Milik Owner',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        'Total Villa: ${controller.totalVilla.value}',
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      if (controller.villaNames.isEmpty)
                        const Text(
                          'Owner ini belum punya villa.',
                        )
                      else
                        ...controller.villaNames.map(
                          (
                            n,
                          ) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 6,
                            ),
                            child: Text(
                              '• $n',
                            ),
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
    );
  }

  Widget _card({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
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
      child: child,
    );
  }

  Widget _row(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
            ),
          ),
        ],
      ),
    );
  }
}
