import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../owner_dashboard_viewmodel.dart';
import 'dashboard_viewmodel.dart';

class OwnerDashboardTabView extends GetView<OwnerDashboardTabViewModel> {
  const OwnerDashboardTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(child: Text(controller.errorMessage.value!));
        }

        final pendapatan = controller.totalPendapatanBulanIni.value;
        final booking = controller.totalBookingBulanIni.value;
        final totalVilla = controller.totalVillaTerdaftar.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Owner',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _summaryCard(
                    title: 'Total Pendapatan\nBulan ini',
                    value: 'Rp ${pendapatan.toStringAsFixed(0)}',
                  ),
                  _summaryCard(
                    title: 'Total Booking\nBulan ini',
                    value: booking.toString(),
                  ),
                  _summaryCard(
                    title: 'Total Villa\nTerdaftar',
                    value: totalVilla.toString(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _quickActionSection(),

              const SizedBox(height: 20),

              _sectionBox(
                title: 'Pendapatan bulanan per villa',
                child: Column(
                  children: const [
                    _TableRowHeader(),
                    _TableRowData('Villa Rayya\'s', 30, 'Rp 38.000.000'),
                    _TableRowData('Villa Agave', 25, 'Rp 55.000.000'),
                    _TableRowData('Villa Bodas', 21, 'Rp 45.000.000'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _summaryCard({required String title, required String value}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _quickActionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Aksi Cepat Villa', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // pindah ke tab villa
                Get.find<OwnerDashboardViewModel>().changeTab(1);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('+ Tambah Villa Baru'),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Get.find<OwnerDashboardViewModel>().changeTab(1);
            },
            child: const Text(
              'Lihat Semua Villa',
              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kelola harga dan ketersediaan',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _sectionBox extends StatelessWidget {
  final String title;
  final Widget child;

  const _sectionBox({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TableRowHeader extends StatelessWidget {
  const _TableRowHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Nama Villa', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Booking', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Pendapatan bersih', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _TableRowData extends StatelessWidget {
  final String nama;
  final int booking;
  final String pendapatan;

  const _TableRowData(this.nama, this.booking, this.pendapatan);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(nama)),
          Expanded(flex: 2, child: Text('$booking')),
          Expanded(flex: 3, child: Text(pendapatan)),
        ],
      ),
    );
  }
}
