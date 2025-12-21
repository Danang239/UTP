import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../owner_dashboard_viewmodel.dart';
import 'dashboard_viewmodel.dart';
import 'owner_dashboard_models.dart';

class OwnerDashboardTabView
    extends
        GetView<
          OwnerDashboardTabViewModel
        > {
  const OwnerDashboardTabView({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Obx(
      () {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final err = controller.errorMessage.value;
        if (err !=
                null &&
            err.isNotEmpty) {
          return Center(
            child: Text(
              err,
            ),
          );
        }

        final pendapatan = controller.totalPendapatanBulanIni.value;
        final booking = controller.totalBookingBulanIni.value;
        final totalVilla = controller.totalVillaTerdaftar.value;
        final villaRows = controller.villaMonthlyIncome;

        final m = controller.selectedMonth.value.toString().padLeft(
          2,
          '0',
        );
        final y = controller.selectedYear.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Dashboard Owner',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    '(Periode: $m/$y)',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      _showMonthYearPicker(
                        context,
                      );
                    },
                    icon: const Icon(
                      Icons.calendar_month,
                      size: 18,
                    ),
                    label: const Text(
                      'Filter Bulan',
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  TextButton.icon(
                    onPressed: controller.loadSummary,
                    icon: const Icon(
                      Icons.refresh,
                      size: 18,
                    ),
                    label: const Text(
                      'Refresh',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),

              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      title: 'Total Pendapatan\nBulan ini',
                      value: _formatRupiah(
                        pendapatan,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: _summaryCard(
                      title: 'Total Booking\nBulan ini',
                      value: booking.toString(),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: _summaryCard(
                      title: 'Total Villa\nTerdaftar',
                      value: totalVilla.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 20,
              ),

              _quickActionSection(),

              const SizedBox(
                height: 20,
              ),

              _sectionBox(
                title: 'Pendapatan bulanan per villa',
                child: Column(
                  children: [
                    const _TableRowHeader(),
                    const SizedBox(
                      height: 6,
                    ),
                    if (villaRows.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Belum ada pendapatan (booking terkonfirmasi) di bulan ini.',
                          ),
                        ),
                      )
                    else
                      ...villaRows.map(
                        (
                          e,
                        ) => _TableRowData(
                          e,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMonthYearPicker(
    BuildContext context,
  ) {
    int tempMonth = controller.selectedMonth.value;
    int tempYear = controller.selectedYear.value;

    showDialog(
      context: context,
      builder:
          (
            _,
          ) {
            return AlertDialog(
              title: const Text(
                'Pilih Bulan & Tahun',
              ),
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<
                      int
                    >(
                      value: tempMonth,
                      decoration: const InputDecoration(
                        labelText: 'Bulan',
                      ),
                      items: List.generate(
                        12,
                        (
                          i,
                        ) {
                          final v =
                              i +
                              1;
                          return DropdownMenuItem(
                            value: v,
                            child: Text(
                              v.toString().padLeft(
                                2,
                                '0',
                              ),
                            ),
                          );
                        },
                      ),
                      onChanged:
                          (
                            v,
                          ) {
                            if (v !=
                                null) {
                              tempMonth = v;
                            }
                          },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    DropdownButtonFormField<
                      int
                    >(
                      value: tempYear,
                      decoration: const InputDecoration(
                        labelText: 'Tahun',
                      ),
                      items: List.generate(
                        7,
                        (
                          i,
                        ) {
                          final v =
                              DateTime.now().year -
                              3 +
                              i;
                          return DropdownMenuItem(
                            value: v,
                            child: Text(
                              v.toString(),
                            ),
                          );
                        },
                      ),
                      onChanged:
                          (
                            v,
                          ) {
                            if (v !=
                                null) {
                              tempYear = v;
                            }
                          },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  child: const Text(
                    'Batal',
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                    controller.setMonthYear(
                      month: tempMonth,
                      year: tempYear,
                    );
                  },
                  child: const Text(
                    'Terapkan',
                  ),
                ),
              ],
            );
          },
    );
  }

  static String _formatRupiah(
    num value,
  ) {
    final s = value.round().toString();
    final b = StringBuffer();

    for (
      int i = 0;
      i <
          s.length;
      i++
    ) {
      final idxFromEnd =
          s.length -
          i;
      b.write(
        s[i],
      );
      if (idxFromEnd >
              1 &&
          idxFromEnd %
                  3 ==
              1) {
        b.write(
          '.',
        );
      }
    }

    return 'Rp ${b.toString()}';
  }

  static Widget _summaryCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _quickActionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat Villa',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.find<
                      OwnerDashboardViewModel
                    >()
                    .changeTab(
                      1,
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                ),
              ),
              child: const Text(
                '+ Tambah Villa Baru',
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          GestureDetector(
            onTap: () {
              Get.find<
                    OwnerDashboardViewModel
                  >()
                  .changeTab(
                    1,
                  );
            },
            child: const Text(
              'Lihat Semua Villa',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          const Text(
            'Kelola harga dan ketersediaan',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _sectionBox
    extends
        StatelessWidget {
  final String title;
  final Widget child;

  const _sectionBox({
    required this.title,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          child,
        ],
      ),
    );
  }
}

class _TableRowHeader
    extends
        StatelessWidget {
  const _TableRowHeader();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 4.0,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Nama Villa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Booking',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Pendapatan bersih',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRowData
    extends
        StatelessWidget {
  final OwnerVillaMonthlyIncomeItem item;

  const _TableRowData(
    this.item,
  );

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2.0,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.villaName,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.bookingCount}',
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              OwnerDashboardTabView._formatRupiah(
                item.income,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
