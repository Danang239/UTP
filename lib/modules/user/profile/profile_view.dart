import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:utp_flutter/modules/auth/login_view.dart';
import 'package:utp_flutter/modules/user/my_bookings/my_bookings_binding.dart';
import 'package:utp_flutter/modules/user/my_bookings/my_bookings_view.dart';
import 'package:utp_flutter/modules/user/edit_profile/edit_profile_binding.dart';
import 'package:utp_flutter/modules/user/edit_profile/edit_profile_view.dart';
import 'package:utp_flutter/modules/user/profile/profile_viewmodel.dart';

import 'package:utp_flutter/app/routes/app_routes.dart';
import 'package:utp_flutter/app/theme/theme_controller.dart';

class ProfileView extends GetView<ProfileViewModel> {
  final VoidCallback onTapFavorite;

  const ProfileView({super.key, required this.onTapFavorite});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Obx(() {
        return controller.isLoggedIn.value
            ? _buildLoggedInUI(context)
            : _buildLoggedOutUI(context);
      }),
    );
  }

  // ===============================
  // BELUM LOGIN
  // ===============================
  Widget _buildLoggedOutUI(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => Get.offAll(() => const LoginView()),
        child: const Text("Masuk / Daftar"),
      ),
    );
  }

  // ===============================
  // SUDAH LOGIN
  // ===============================
  Widget _buildLoggedInUI(BuildContext context) {
    final theme = Theme.of(context);

    final name =
        controller.name.value.isNotEmpty ? controller.name.value : "Pengguna";
    final email =
        controller.email.value.isNotEmpty ? controller.email.value : "-";
    final profileImg = controller.profileImg.value.toString();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ================= PROFILE CARD =================
        _elevatedCard(
          context,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 26),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  backgroundImage:
                      profileImg.isNotEmpty ? NetworkImage(profileImg) : null,
                  child: profileImg.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 44,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        )
                      : null,
                ),
                const SizedBox(height: 14),
                Text(name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // ================= MENU CARD =================
        _elevatedCard(
          context,
          child: Column(
            children: [
              _menuItem(
                context,
                Icons.shopping_bag_outlined,
                "Pesanan Saya",
                () => Get.to(
                  () => const MyBookingsView(),
                  binding: MyBookingsBinding(),
                ),
              ),
              _menuItem(
                context,
                Icons.favorite_border,
                "Favorit",
                onTapFavorite,
              ),
              _menuItem(
                context,
                Icons.settings_outlined,
                "Pengaturan",
                _showThemeBottomSheet,
              ),
              _menuItem(
                context,
                Icons.person_outline,
                "Lihat / Edit Profil",
                () => Get.to(
                  () => const EditProfileView(),
                  binding: EditProfileBinding(),
                ),
              ),
              _menuItem(
                context,
                Icons.help_outline,
                "Bantuan",
                _showBantuanBottomSheet,
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ================= LOGOUT =================
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () async {
            await controller.logout();
            Get.offAll(() => const LoginView());
          },
          child: const Text("Logout"),
        ),
      ],
    );
  }

  // ===============================
  // ELEVATED CARD (THEME AWARE)
  // ===============================
  Widget _elevatedCard(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.black.withOpacity(0.18),
            blurRadius: isDark ? 12 : 18,
            spreadRadius: isDark ? 0 : 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  // ===============================
  // MENU ITEM
  // ===============================
  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: theme.colorScheme.onSurface),
      title: Text(title, style: theme.textTheme.bodyLarge),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    );
  }

  // ===============================
  // THEME BOTTOM SHEET
  // ===============================
  void _showThemeBottomSheet() {
    final themeC = Get.find<ThemeController>();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Pengaturan Tema",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: themeC.isDark,
                onChanged: (_) => themeC.toggleTheme(),
                title: const Text("Mode Gelap"),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ===============================
  // BANTUAN
  // ===============================
  void _showBantuanBottomSheet() {
    Get.bottomSheet(
      ListTile(
        leading: const Icon(Icons.chat_bubble_outline),
        title: const Text("Hubungi Admin"),
        onTap: () {
          Get.back();
          Get.toNamed(Routes.userChatAdmin, arguments: {
            'userId': controller.uid,
            'userName': controller.name.value,
          });
        },
      ),
    );
  }
}
