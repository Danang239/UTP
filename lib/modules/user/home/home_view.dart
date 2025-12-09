import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:utp_flutter/modules/user/detail/detail_view.dart';
import 'package:utp_flutter/modules/user/home/home_viewmodel.dart';
import 'package:utp_flutter/services/user_collections.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference villasRef =
        FirebaseFirestore.instance.collection('villas');

    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/chatbot');
        },
        backgroundColor: Colors.black,
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text("Chatbot"),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= HEADER =================
              Row(
                children: [
                  SizedBox(
                    height: 48,
                    width: 48,
                    child: Image.asset(
                      'assets/images/logo_stayco.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchVillaPage(),
                          ),
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 4,
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: Colors.black54),
                            SizedBox(width: 10),
                            Text(
                              "Mulai Pencarian",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ============== PENGINAPAN POPULER ==============
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Penginapan populer di Puncak",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(">", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 230,
                child: StreamBuilder<QuerySnapshot>(
                  stream: villasRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Belum ada villa"));
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _VillaCard(
                          villaId: doc.id,
                          data: data,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailView(
                                  villaId: doc.id,
                                  villaData: data,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ============== TERSEDIA MINGGU INI ==============
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Tersedia pada minggu ini",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(">", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 230,
                child: StreamBuilder<QuerySnapshot>(
                  stream: villasRef.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("Belum ada villa"));
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _VillaCard(
                          villaId: doc.id,
                          data: data,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailView(
                                  villaId: doc.id,
                                  villaData: data,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu villa di home (list horizontal) + icon favorit
class _VillaCard extends StatelessWidget {
  const _VillaCard({
    required this.villaId,
    required this.data,
    required this.onTap,
  });

  final String villaId;
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  int _parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// Ambil URL foto pertama (kalau ada).
  /// Bisa handle:
  /// - images: ["url1","url2"]
  /// - images: "url1"   (data lama)
  String? _getFirstImageUrl() {
    final dynamic rawImages = data['images'];

    if (rawImages is List) {
      if (rawImages.isNotEmpty && rawImages.first is String) {
        return rawImages.first as String;
      }
    } else if (rawImages is String) {
      return rawImages;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Tanpa Nama';
    final weekday = _parsePrice(data['weekday_price']);
    final String? firstImageUrl = _getFirstImageUrl();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // foto + icon favorit
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: firstImageUrl != null &&
                            firstImageUrl.isNotEmpty
                        ? Image.network(
                            firstImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.home_work_outlined),
                          ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: StreamBuilder<bool>(
                    stream: UserCollections.isFavoriteStream(villaId),
                    builder: (context, snapshot) {
                      final isFav = snapshot.data ?? false;
                      return GestureDetector(
                        onTap: () async {
                          try {
                            await UserCollections.toggleFavorite(villaId);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Gagal mengubah favorit: $e'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? Colors.red : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // nama + harga
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Text(
                "Rp $weekday",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// =============================
// HALAMAN SEARCH (Homepage 2)
// =============================
class SearchVillaPage extends StatefulWidget {
  const SearchVillaPage({super.key});

  @override
  State<SearchVillaPage> createState() => _SearchVillaPageState();
}

class _SearchVillaPageState extends State<SearchVillaPage> {
  final TextEditingController _searchController = TextEditingController();
  final CollectionReference villasRef =
      FirebaseFirestore.instance.collection('villas');

  bool _loading = false;
  List<QueryDocumentSnapshot> _results = [];

  final List<_CategoryItem> _categories = const [
    _CategoryItem(id: 'pool', label: 'Kolam renang', icon: Icons.pool_outlined),
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

  String? _selectedCategoryId;

  // --- fungsi search, filter, nearest tetap sama seperti semula (dipotong biar singkat) ---
  // (semua logika di bawah ini sama persis dengan kode kamu, hanya bagian tampilan list item yang kutambah gambar)

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

      setState(() {
        _results = snap.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mencari villa: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

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
      setState(() {
        _results = snap.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat kategori: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadNearest() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Fitur lokasi hanya tersedia di aplikasi mobile.\n'
            'Silakan coba di emulator / HP.',
          ),
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak. Tidak bisa mencari villa terdekat.',
            ),
          ),
        );
        setState(() => _loading = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final allSnap = await villasRef.get();
      final docs = allSnap.docs;

      final List<_VillaDistance> list = [];
      for (final doc in docs) {
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

      setState(() {
        _results = list.map((e) => e.doc).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat villa terdekat: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

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
            // ===== CARD SEARCH + KATEGORI =====
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
                    // search
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
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: "Cari penginapan",
                                border: InputBorder.none,
                              ),
                              textInputAction: TextInputAction.search,
                              onSubmitted: _searchByName,
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

                    // Tile terdekat
                    ListTile(
                      onTap: _loadNearest,
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

                    // kategori
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final selected = cat.id == _selectedCategoryId;
                          return _CategoryChip(
                            item: cat,
                            selected: selected,
                            onTap: () => _filterByCategory(cat.id),
                          );
                        },
                      ),
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

            // ===== LIST HASIL =====
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? const Center(child: Text("Belum ada data"))
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final doc = _results[index];
                            final data =
                                doc.data() as Map<String, dynamic>;

                            final name = data['name'] ?? 'Tanpa Nama';
                            final location = data['location'] ?? '-';
                            final weekdayPrice = data['weekday_price'];

                            // ambil foto pertama juga untuk search list
                            String? firstImageUrl;
                            final dynamic rawImages = data['images'];
                            if (rawImages is List &&
                                rawImages.isNotEmpty &&
                                rawImages.first is String) {
                              firstImageUrl = rawImages.first as String;
                            } else if (rawImages is String) {
                              firstImageUrl = rawImages;
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailView(
                                      villaId: doc.id,
                                      villaData: data,
                                    ),
                                  ),
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
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: firstImageUrl != null &&
                                                firstImageUrl.isNotEmpty
                                            ? Image.network(
                                                firstImageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                      Icons.image_not_supported),
                                                ),
                                              )
                                            : Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.home_work_outlined,
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.bold,
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
                                              fontWeight:
                                                  FontWeight.w600,
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
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
