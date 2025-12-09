import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'search_viewmodel.dart';
import 'package:utp_flutter/modules/user/detail/detail_view.dart';

class SearchView extends GetView<SearchViewModel> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Lokasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ====== CARD PUTIH BESAR (SEARCH + SARAN + KATEGORI) ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // search dalam card
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.black54),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              // optional: kalau di ViewModel punya TextEditingController,
                              // bisa dipakai di sini → controller: controller.searchController,
                              decoration: const InputDecoration(
                                hintText: "Cari penginapan",
                                border: InputBorder.none,
                              ),
                              textInputAction: TextInputAction.search,
                              onSubmitted: controller.searchByName,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      "Saran penginapan",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tile "terdekat dari lokasi anda"
                    ListTile(
                      onTap: controller.loadNearest,
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.navigation_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      title: const Text(
                        "Terdekat dari lokasi anda",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        "Cari tahu apa yang ada di sekitarmu",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ====== KATEGORI ======
                    SizedBox(
                      height: 40,
                      child: Obx(() {
                        final selectedId = controller.selectedCategoryId.value;

                        const categories = [
                          _CategoryItem(
                            id: 'pool',
                            label: 'Kolam renang',
                            icon: Icons.pool_outlined,
                          ),
                          _CategoryItem(
                            id: 'big_yard',
                            label: 'Halaman luas',
                            icon: Icons.park_outlined,
                          ),
                          _CategoryItem(
                            id: 'billiard',
                            label: 'Meja billiard',
                            icon: Icons.sports_bar,
                          ),
                          _CategoryItem(
                            id: 'big_villa',
                            label: 'Villa besar (≥20)',
                            icon: Icons.group_outlined,
                          ),
                          _CategoryItem(
                            id: 'small_villa',
                            label: 'Villa kecil (≤15)',
                            icon: Icons.person_outline,
                          ),
                        ];

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final cat = categories[index];
                            final selected = cat.id == selectedId;

                            return _CategoryChip(
                              item: cat,
                              selected: selected,
                              onTap: () => controller.filterByCategory(cat.id),
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Hasil pencarian",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ====== LIST HASIL ======
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.results.isEmpty) {
                  return const Center(child: Text("Belum ada data"));
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: controller.results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = controller.results[index];
                    final data =
                        doc.data() as Map<String, dynamic>; // <-- dipertegas

                    final name = data['name'] ?? 'Tanpa Nama';
                    final location = data['location'] ?? '-';
                    final weekdayPrice = data['weekday_price'];

                    return GestureDetector(
                      onTap: () {
                        Get.to(
                          () => DetailView(villaId: doc.id, villaData: data),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rp ${weekdayPrice ?? '-'}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem {
  final String id;
  final String label;
  final IconData icon;

  const _CategoryItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _CategoryChip extends StatelessWidget {
  final _CategoryItem item;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 16,
              color: selected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
