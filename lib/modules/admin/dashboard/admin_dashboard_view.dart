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
      floatingActionButton: Obx(() {
        final title = controller.currentMenuTitle;
        return FloatingActionButton.extended(
          onPressed: () {
            Get.snackbar(
              'Floating Action',
              'Aksi untuk menus "$title"',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          icon: const Icon(Icons.add),
          label: Text('Tambah ${title.toLowerCase()}'),
          backgroundColor: const Color(0xFF673AB7),
        );
      }),
      body: SafeArea(
        child: Row(
          children: [
            SidebarWidget(),
            Expanded(
              child: Column(
                children: [
                  TopBarWidget(),
                  SizedBox(height: 16),
                  StatsSectionWidget(),
                  SizedBox(height: 16),
                  Expanded(child: ContentAreaWidget()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}