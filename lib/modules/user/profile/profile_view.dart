// lib/modules/profile/profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:utp_flutter/modules/auth/login_view.dart';

import 'package:utp_flutter/modules/user/my_bookings/my_bookings_binding.dart';
import 'package:utp_flutter/modules/user/my_bookings/my_bookings_view.dart';

import 'package:utp_flutter/modules/user/edit_profile/edit_profile_binding.dart';
import 'package:utp_flutter/modules/user/edit_profile/edit_profile_view.dart';
import 'package:utp_flutter/modules/user/profile/profile_viewmodel.dart';

class ProfileView extends GetView<ProfileViewModel> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        // satu-satunya Obx: tentukan login / belum login
        return controller.isLoggedIn.value
            ? _buildLoggedInUI()
            : _buildLoggedOutUI();
      }),
    );
  }

  // ===============================
  //  UI Jika BELUM LOGIN
  // ===============================
  Widget _buildLoggedOutUI() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // pakai module auth/LoginView
          Get.offAll(() => const LoginView());
        },
        child: const Text("Masuk / Daftar"),
      ),
    );
  }

  // ===============================
  //  UI Jika SUDAH LOGIN
  // ===============================
  Widget _buildLoggedInUI() {
    // di sini TIDAK pakai Obx lagi, cukup baca value Rx saja
    final nameRx = controller.name.value;
    final emailRx = controller.email.value;

    final String name =
        nameRx.isNotEmpty ? nameRx : "Pengguna";
    final String email =
        emailRx.isNotEmpty ? emailRx : "-";

    // kalau di ViewModel kamu nama variabel fotonya beda,
    // ganti baris ini sesuai punya kamu
    final String profileImg =
        (controller.profileImg.value).toString(); // asumsi RxString

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        /// Foto Profil + Nama + Email (CENTER, sama persis ProfilePage lama)
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.grey[300],
                backgroundImage: (profileImg.isNotEmpty)
                    ? NetworkImage(profileImg)
                    : null,
                child: profileImg.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey[600],
                      )
                    : null,
              ),

              const SizedBox(height: 12),

              // NAMA
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // EMAIL
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        /// MENU-MENU
        _menuItem(
          Icons.shopping_bag_outlined,
          "Pesanan Saya",
          () => Get.to(
            () => const MyBookingsView(),
            binding: MyBookingsBinding(),
          ),
        ),

        _menuItem(
          Icons.favorite_border,
          "Favorit",
          () {
            // TODO: nanti kalau mau arahkan ke tab Favorit
          },
        ),

        _menuItem(
          Icons.settings_outlined,
          "Pengaturan",
          () {
            // TODO: tambah halaman pengaturan kalau diperlukan
          },
        ),

        _menuItem(
          Icons.person_outline,
          "Lihat / Edit Profil",
          () => Get.to(
            () => const EditProfileView(),
            binding: EditProfileBinding(),
          ),
        ),

        _menuItem(
          Icons.help_outline,
          "Bantuan",
          () {
            // TODO: tambah halaman bantuan
          },
        ),

        const SizedBox(height: 30),

        /// LOGOUT (abu gelap, full width)
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () async {
            await controller.logout();
            Get.offAll(() => const LoginView());
          },
          child: const Text(
            "Logout",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ===============================
  //  WIDGET ITEM MENU
  // ===============================
  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey[200],
      ),
    );
  }
}
