import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../admin_dashboard_viewmodel.dart';
import '../utils/format_helper.dart';

class DataVillaPage extends GetView<AdminDashboardViewModel> {
  const DataVillaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Data Villa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: controller.loadDashboardStats,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh data',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
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

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Lokasi')),
                    DataColumn(label: Text('Weekday')),
                    DataColumn(label: Text('Weekend')),
                    DataColumn(label: Text('Kapasitas')),
                  ],
                  rows: villas.map((v) {
                    final name = v['name'] ?? '';
                    final location = v['location'] ?? '';
                    final weekday = FormatHelper.formatRupiah(
                        (v['weekdayPrice'] ?? 0).toDouble());
                    final weekend = FormatHelper.formatRupiah(
                        (v['weekendPrice'] ?? 0).toDouble());
                    final capacity = v['capacity'] ?? 0;

                    return DataRow(
                      cells: [
                        DataCell(Text(name)),
                        DataCell(Text(location)),
                        DataCell(Text('Rp $weekday')),
                        DataCell(Text('Rp $weekend')),
                        DataCell(Text('$capacity org')),
                      ],
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}