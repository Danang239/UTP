import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:utp_flutter/modules/user/detail/detail_view.dart';
import 'package:utp_flutter/modules/user/home/home_viewmodel.dart';
import 'package:utp_flutter/services/user_collections.dart';

class HomeView extends GetView<HomeViewModel> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final villasRef = FirebaseFirestore.instance.collection('villas');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/chatbot'),
        backgroundColor: theme.colorScheme.primary,
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

                  /// 🔥 SEARCH → PINDAH KE SEARCH VIEW
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/search'),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: theme.iconTheme.color?.withOpacity(0.6),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Mulai Pencarian",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ================= POPULER =================
              _sectionTitle(theme, "Penginapan populer di Puncak"),
              const SizedBox(height: 12),

              _villaHorizontalList(villasRef),

              const SizedBox(height: 24),

              // ================= TERSEDIA =================
              _sectionTitle(theme, "Tersedia pada minggu ini"),
              const SizedBox(height: 12),

              _villaHorizontalList(villasRef),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== SECTION TITLE =====================
  Widget _sectionTitle(ThemeData theme, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          ">",
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }

  // ===================== LIST VILLA =====================
  Widget _villaHorizontalList(CollectionReference villasRef) {
    return SizedBox(
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
                  Get.to(
                    () => DetailView(
                      villaId: doc.id,
                      villaData: data,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// ===================== VILLA CARD =====================
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
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String? _getFirstImageUrl() {
    final images = data['images'];
    if (images is List && images.isNotEmpty) return images.first;
    if (images is String) return images;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = data['name'] ?? 'Tanpa Nama';
    final price = _parsePrice(data['weekday_price']);
    final imageUrl = _getFirstImageUrl();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE + FAVORITE
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.home_work_outlined),
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
                        onTap: () => UserCollections.toggleFavorite(villaId),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: theme.cardColor,
                          child: Icon(
                            isFav
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 16,
                            color: isFav ? Colors.red : theme.iconTheme.color,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              child: Text(
                "Rp $price",
                style: theme.textTheme.bodyMedium?.copyWith(
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
