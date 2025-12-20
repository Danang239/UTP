import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_dashboard_viewmodel.dart';
import 'widgets/sidebar_widget.dart';
import 'widgets/top_bar_widget.dart';
import 'widgets/stats_section_widget.dart';
import 'widgets/content_area_widget.dart';

class AdminDashboardView extends GetView<AdminDashboardViewModel> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9FF),

      // ===============================
      // FLOATING ACTION BUTTON
      // ===============================
      floatingActionButton: Obx(() {
        final title = controller.currentMenuTitle.toLowerCase();

        // ❌ TIDAK ADA FAB UNTUK MENU PESAN
        if (title == 'pesan') {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: () {
            Get.snackbar(
              'Aksi',
              'Tambah ${controller.currentMenuTitle}',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          icon: const Icon(Icons.add),
          label: Text('Tambah ${controller.currentMenuTitle}'),
          backgroundColor: const Color(0xFF673AB7),
        );
      }),

      body: SafeArea(
        child: Row(
          children: [
            const SidebarWidget(),

            Expanded(
              child: Column(
                children: [
                  const TopBarWidget(),

                  const SizedBox(height: 16),

                  // ===============================
                  // STATS (HILANGKAN DI MENU PESAN)
                  // ===============================
                  Obx(() {
                    if (controller.currentMenuTitle.toLowerCase() == 'pesan') {
                      return const SizedBox.shrink();
                    }
                    return const StatsSectionWidget();
                  }),

                  const SizedBox(height: 16),

                  // ===============================
                  // CONTENT AREA (INTI)
                  // ===============================
                  const Expanded(
                    child: ContentAreaWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
