import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:utp_flutter/modules/user/detail/detail_view.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final CollectionReference villasRef =
      FirebaseFirestore.instance.collection('villas');

  bool _loading = false;
  List<QueryDocumentSnapshot> _results = [];
  String? _selectedCategoryId;

  final List<_CategoryItem> _categories = const [
    _CategoryItem(id: 'pool', label: 'Kolam renang', icon: Icons.pool_outlined),
    _CategoryItem(id: 'big_yard', label: 'Halaman luas', icon: Icons.park_outlined),
    _CategoryItem(id: 'billiard', label: 'Meja billiard', icon: Icons.sports_bar),
    _CategoryItem(id: 'big_villa', label: 'Villa besar (≥20)', icon: Icons.group_outlined),
    _CategoryItem(id: 'small_villa', label: 'Villa kecil (≤15)', icon: Icons.person_outline),
  ];

  // ================= SEARCH BY NAME =================
  Future<void> _searchByName(String text) async {
    text = text.trim();
    _selectedCategoryId = null;

    if (text.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _loading = true);

    try {
      final snap = await villasRef
          .where('name', isGreaterThanOrEqualTo: text)
          .where('name', isLessThanOrEqualTo: '$text\uf8ff')
          .get();

      setState(() => _results = snap.docs);
    } finally {
      setState(() => _loading = false);
    }
  }

  // ================= FILTER CATEGORY =================
  Future<void> _filterByCategory(String id) async {
    setState(() {
      _loading = true;
      _results = [];
      _selectedCategoryId = id;
      _searchController.clear();
    });

    try {
      Query query = villasRef;

      switch (id) {
        case 'pool':
          query = query.where('facilities', arrayContains: 'pool');
          break;
        case 'big_yard':
          query = query.where('facilities', arrayContains: 'big_yard');
          break;
        case 'billiard':
          query = query.where('facilities', arrayContains: 'billiard');
          break;
        case 'big_villa':
          query = query.where('capacity', isGreaterThanOrEqualTo: 20);
          break;
        case 'small_villa':
          query = query.where('capacity', isLessThanOrEqualTo: 15);
          break;
      }

      final snap = await query.get();
      setState(() => _results = snap.docs);
    } finally {
      setState(() => _loading = false);
    }
  }

  // ================= NEAREST =================
  Future<void> _loadNearest() async {
    if (kIsWeb) {
      Get.snackbar('Info', 'Fitur lokasi hanya tersedia di aplikasi mobile.');
      return;
    }

    setState(() {
      _loading = true;
      _results = [];
      _selectedCategoryId = null;
      _searchController.clear();
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Izin lokasi ditolak');
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      final allSnap = await villasRef.get();

      final List<_VillaDistance> list = [];

      for (final doc in allSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final lat = data['lat'];
        final lng = data['lng'];

        if (lat is num && lng is num) {
          final distance = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            lat.toDouble(),
            lng.toDouble(),
          );
          list.add(_VillaDistance(doc: doc, distance: distance));
        }
      }

      list.sort((a, b) => a.distance.compareTo(b.distance));
      setState(() => _results = list.map((e) => e.doc).toList());
    } finally {
      setState(() => _loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Cari Penginapan"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ================= SEARCH CARD =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onSubmitted: _searchByName,
                    decoration: InputDecoration(
                      hintText: "Cari penginapan",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    onTap: _loadNearest,
                    leading: Icon(Icons.navigation_outlined,
                        color: theme.colorScheme.primary),
                    title: const Text("Terdekat dari lokasi anda"),
                    subtitle: const Text("Cari villa di sekitar kamu"),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return _CategoryChip(
                          item: cat,
                          selected: cat.id == _selectedCategoryId,
                          onTap: () => _filterByCategory(cat.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= RESULT LIST =================
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Center(child: Text("Belum ada hasil"))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final doc = _results[index];
                          final data =
                              doc.data() as Map<String, dynamic>;

                          final name = data['name'] ?? '-';
                          final location = data['location'] ?? '-';
                          final price = data['weekday_price'] ?? '-';
                          final images =
                              (data['images'] as List?)?.cast<String>() ?? [];

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Get.to(() => DetailView(
                                    villaId: doc.id,
                                    villaData: data,
                                  ));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                        isDark ? 0.4 : 0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // FOTO
                                  ClipRRect(
                                    borderRadius: const BorderRadius.horizontal(
                                        left: Radius.circular(16)),
                                    child: images.isNotEmpty
                                        ? Image.network(
                                            images.first,
                                            width: 120,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 120,
                                            height: 100,
                                            color: theme
                                                .colorScheme.surfaceVariant,
                                            child: const Icon(
                                                Icons.image_not_supported),
                                          ),
                                  ),

                                  // INFO
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            location,
                                            style: theme.textTheme.bodySmall,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Rp $price / malam",
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ================= HELPER =================
class _VillaDistance {
  final QueryDocumentSnapshot doc;
  final double distance;
  _VillaDistance({required this.doc, required this.distance});
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
  const _CategoryChip({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _CategoryItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 16,
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.iconTheme.color,
            ),
            const SizedBox(width: 6),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
