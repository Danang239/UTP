// lib/modules/explore/explore_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/card_item.dart';
import 'explore_viewmodel.dart';

class ExploreView extends GetView<ExploreViewModel> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Explore")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null) {
          return Center(
            child: Text(
              controller.errorMessage.value!,
              textAlign: TextAlign.center,
            ),
          );
        }

        final villas = controller.villas;

        if (villas.isEmpty) {
          return const Center(child: Text("Belum ada villa"));
        }

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
              child: const CardItem(), // ⬅️ UI kartunya tetap pakai punyamu
            );
          },
        );
      }),
    );
  }
}
