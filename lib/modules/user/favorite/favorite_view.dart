import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'favorite_viewmodel.dart';

class FavoriteView extends GetView<FavoriteViewModel> {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final isEditMode = controller.isEditMode.value;
            final favorites = controller.favorites;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER + BUTTON EDIT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Favorit",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Tombol Edit / Selesai
                    GestureDetector(
                      onTap: controller.toggleEditMode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isEditMode ? "Selesai" : "Edit",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// LIST / GRID FAVORIT — UI 100% SAMA
                Expanded(
                  child: controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : favorites.isEmpty
                          ? const Center(
                              child: Text("Belum ada villa favorit"),
                            )
                          : GridView.builder(
                              itemCount: favorites.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                              itemBuilder: (context, index) {
                                final fav = favorites[index];
                                final villa = fav.villaData;

                                return Stack(
                                  children: [
                                    /// CARD
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Expanded(
                                            child: Center(
                                              child: Icon(
                                                Icons.home,
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            villa.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            villa.location,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// TAP UNTUK DETAIL
                                    Positioned.fill(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          // ⬇️ Sekarang kirim `fav`, bukan cuma `villa`
                                          onTap: () {
                                            controller.goToDetail(fav);
                                          },
                                        ),
                                      ),
                                    ),

                                    /// ICON DELETE (X)
                                    if (isEditMode)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: GestureDetector(
                                          onTap: () => controller
                                              .removeFavorite(fav.id),
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
