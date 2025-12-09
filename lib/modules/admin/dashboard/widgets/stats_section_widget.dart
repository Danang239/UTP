import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../admin_dashboard_viewmodel.dart';
import '../utils/format_helper.dart';
import 'stat_card_widget.dart';

class StatsSectionWidget extends GetView<AdminDashboardViewModel> {
  const StatsSectionWidget({super.key});

  void _showOwnerPendapatanDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Total Pendapatan Owner'),
        content: Obx(() {
          final entries = controller.ownerPendapatanMap.entries.toList();
          if (entries.isEmpty) {
            return const Text(
              'Belum ada data pendapatan owner.\nPastikan booking sudah punya field owner_id & total_amount.',
            );
          }
          return SizedBox(
            width: 320,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final e = entries[i];
                final ownerCode = e.key;
                final amount = FormatHelper.formatRupiah(e.value);
                return ListTile(
                  dense: true,
                  title: Text(ownerCode),
                  trailing: Text('Rp $amount'),
                );
              },
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedMenuIndex.value != 0) {
        return const SizedBox.shrink();
      }

      final villa = controller.totalVilla.value.toString();
      final pesanan = controller.totalPesanan.value.toString();
      final reschedule = controller.totalReschedule.value.toString();

      final adminPendapatan =
          FormatHelper.formatRupiah(controller.pendapatanAdmin.value);
      final ownerPendapatan =
          FormatHelper.formatRupiah(controller.pendapatanOwner.value);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'DATA VILLA',
                    value: villa,
                    color: const Color(0xFFFFF3E0),
                    accentColor: const Color(0xFFFFA726),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'TOTAL PESANAN',
                    value: pesanan,
                    color: const Color(0xFFFFEBEE),
                    accentColor: const Color(0xFFEF5350),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'RESCHEDULE',
                    value: reschedule,
                    color: const Color(0xFFE0F2F1),
                    accentColor: const Color(0xFF26A69A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'TOTAL PENDAPATAN',
                    value: 'Rp $adminPendapatan',
                    color: const Color(0xFFE3F2FD),
                    accentColor: const Color(0xFF42A5F5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'PENDAPATAN OWNER (90%)',
                    value: 'Rp $ownerPendapatan',
                    color: const Color(0xFFE8F5E9),
                    accentColor: const Color(0xFF66BB6A),
                    onTap: _showOwnerPendapatanDialog,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}