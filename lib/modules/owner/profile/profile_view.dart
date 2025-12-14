import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_viewmodel.dart';
import 'owner_edit_profile_view.dart';
import '../bookings/owner_bookings_view.dart';
import '../bookings/owner_bookings_binding.dart';


class OwnerProfileView extends GetView<OwnerProfileViewModel> {
  const OwnerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;

      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // TITLE
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Profil Owner',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // AVATAR + NAMA + EMAIL (tanpa form)
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                controller.profileImg.value.isNotEmpty
                                    ? NetworkImage(controller.profileImg.value)
                                    : null,
                            child: controller.profileImg.value.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.name.value.isEmpty
                                ? 'Owner'
                                : controller.name.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.email.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ================== BUTTON: EDIT PROFIL ==================
                    _menuButton(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profil',
                      onTap: () {
                        Get.to(() => const OwnerEditProfileView());
                      },
                    ),

                    const SizedBox(height: 12),

                    // ================== BUTTON: BOOKINGS (NANTI) ==================
                    _menuButton(
                      icon: Icons.receipt_long_outlined,
                      title: 'Bookings',
                      onTap: () {
                        Get.to(
                          () => const OwnerBookingsView(),
                          binding: OwnerBookingsBinding(),
                        );
                      },
                    ),


                    const SizedBox(height: 24),

                    // LOGOUT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Get.dialog(
                            AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text(
                                  'Apakah Anda yakin ingin logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.logout();
                                  },
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Overlay loading
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.15),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _menuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
