import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../admin_dashboard_viewmodel.dart';

class TopBarWidget extends GetView<AdminDashboardViewModel> {
  const TopBarWidget({super.key});

  void _showMonthYearPicker(BuildContext context) {
    int tempMonth = controller.selectedMonth.value;
    int tempYear = controller.selectedYear.value;

    final years = List<int>.generate(10, (i) {
      final now = DateTime.now().year;
      return (now - 5) + i;
    });

    Get.dialog(
      AlertDialog(
        title: const Text('Filter Periode'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text('Bulan', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<int>(
                          value: tempMonth,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: List.generate(12, (i) {
                            final m = i + 1;
                            return DropdownMenuItem(
                              value: m,
                              child: Text(m.toString().padLeft(2, '0')),
                            );
                          }),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => tempMonth = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(
                        flex: 2,
                        child: Text('Tahun', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<int>(
                          value: tempYear,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: years.map((y) {
                            return DropdownMenuItem(value: y, child: Text(y.toString()));
                          }).toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => tempYear = v);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              controller.setMonthYear(month: tempMonth, year: tempYear);
              Get.back();
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 900;

        Widget titleAndPeriod() {
          return Obx(() {
            final m = controller.selectedMonth.value.toString().padLeft(2, '0');
            final y = controller.selectedYear.value.toString();

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    controller.currentMenuTitle,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Text(
                    'Periode: $m/$y',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          });
        }

        Widget searchBox() {
          return SizedBox(
            height: 42,
            child: TextField(
              controller: controller.searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: controller.onSearchSubmitted,
              decoration: InputDecoration(
                hintText: 'Cari (villa, user, booking...)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF7F7F7),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                ),
              ),
            ),
          );
        }

        Widget filterButton() {
          return OutlinedButton.icon(
            onPressed: () => _showMonthYearPicker(context),
            icon: const Icon(Icons.calendar_month),
            label: const Text('Filter Bulan'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: const BorderSide(color: Color(0xFFE0E0E0)),
              foregroundColor: Colors.black87,
            ),
          );
        }

        Widget profile() {
          return Obx(() {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF1E88E5)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.name.value.isEmpty ? 'Admin' : controller.name.value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    Text(
                      controller.email.value.isEmpty ? '-' : controller.email.value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            );
          });
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEAEAEA))),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: titleAndPeriod()),
                        const SizedBox(width: 12),
                        profile(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: searchBox()),
                        const SizedBox(width: 12),
                        filterButton(),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 4, child: titleAndPeriod()),
                    const SizedBox(width: 12),
                    Expanded(flex: 5, child: searchBox()),
                    const SizedBox(width: 12),
                    filterButton(),
                    const SizedBox(width: 16),
                    profile(),
                  ],
                ),
        );
      },
    );
  }
}
