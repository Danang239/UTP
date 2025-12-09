import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'owner_dashboard_viewmodel.dart';
import 'dashboard/dashboard_view.dart';
import 'villa/villa_view.dart';
import 'pesan/pesan_view.dart';
import 'profile/profile_view.dart';

class OwnerDashboardView extends GetView<OwnerDashboardViewModel> {
  const OwnerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    const pages = [
      OwnerDashboardTabView(),
      OwnerVillaView(),
      OwnerPesanView(),
      OwnerProfileView(),
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            'STAY & Co',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_work_outlined),
              label: 'Villa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Pesan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
