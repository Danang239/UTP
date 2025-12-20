import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'favorite_viewmodel.dart';

class FavoriteView extends GetView<FavoriteViewModel> {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final isEditMode = controller.isEditMode.value;
            final favorites = controller.favorites;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================
                // HEADER
                // =====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Favorit",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.toggleEditMode,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isEditMode ? "Selesai" : "Edit",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =====================
                // GRID FAVORITE
                // =====================
                Expanded(
                  child: controller.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : favorites.isEmpty
                          ? Center(
                              child: Text(
                                "Belum ada villa favorit",
                                style: theme.textTheme.bodyMedium,
                              ),
                            )
                          : GridView.builder(
                              itemCount: favorites.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                              itemBuilder: (context, index) {
                                final fav = favorites[index];
                                final villa = fav.villaData;

                                return Stack(
                                  children: [
                                    // =====================
                                    // CARD
                                    // =====================
                                    Container(
                                      decoration: BoxDecoration(
                                        color: theme.cardColor,
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.shadowColor
                                                .withOpacity(0.15),
                                            blurRadius: 8,
                                            offset:
                                                const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // =====================
                                          // FOTO VILLA
                                          // =====================
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top:
                                                    Radius.circular(12),
                                              ),
                                              child: villa.imageUrl
                                                      .isNotEmpty
                                                  ? Image.network(
                                                      villa.imageUrl,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (_, __, ___) {
                                                        return Center(
                                                          child: Icon(
                                                            Icons
                                                                .broken_image,
                                                            color: theme
                                                                .colorScheme
                                                                .onSurface
                                                                .withOpacity(
                                                                    0.6),
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Center(
                                                      child: Icon(
                                                        Icons.home,
                                                        size: 40,
                                                        color: theme
                                                            .colorScheme
                                                            .onSurface
                                                            .withOpacity(
                                                                0.6),
                                                      ),
                                                    ),
                                            ),
                                          ),

                                          // =====================
                                          // INFO
                                          // =====================
                                          Padding(
                                            padding:
                                                const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  villa.name,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  villa.location,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.6),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // =====================
                                    // TAP DETAIL
                                    // =====================
                                    Positioned.fill(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          onTap: () =>
                                              controller.goToDetail(fav),
                                        ),
                                      ),
                                    ),

                                    // =====================
                                    // DELETE ICON
                                    // =====================
                                    if (isEditMode)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () => controller
                                              .removeFavorite(fav.id),
                                          child: Container(
                                            padding:
                                                const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: theme
                                                  .colorScheme.surface,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: theme.shadowColor
                                                      .withOpacity(0.2),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: 16,
                                              color: theme
                                                  .colorScheme.onSurface,
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
