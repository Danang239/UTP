// lib/modules/explore/explore_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/card_item.dart';
import 'explore_viewmodel.dart';

class ExploreView extends GetView<ExploreViewModel> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // 🔥 biarkan Scaffold ambil dari theme
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Explore"),
        centerTitle: true,
        elevation: 0,
        // 🔥 warna otomatis dari theme (light / dark)
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),

      body: Obx(() {
        // ================= LOADING =================
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          );
        }

        // ================= ERROR =================
        if (controller.errorMessage.value != null) {
          return Center(
            child: Text(
              controller.errorMessage.value!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        final villas = controller.villas;

        // ================= EMPTY =================
        if (villas.isEmpty) {
          return Center(
            child: Text(
              "Belum ada villa",
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        // ================= GRID =================
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: villas.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final villa = villas[index];

            return GestureDetector(
              onTap: () => controller.openDetail(villa),
              child: const CardItem(), // ⬅️ UI card TIDAK DIUBAH
            );
          },
        );
      }),
    );
  }
}
