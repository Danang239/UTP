import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_viewmodel.dart';

class OwnerEditProfileView extends GetView<OwnerProfileViewModel> {
  const OwnerEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;

      return Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // ================= HEADER =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 32),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 255, 255, 255),
                          Color.fromARGB(255, 255, 255, 255),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
                            ),
                            const Spacer(),
                            const Text(
                              'Edit Profil',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // AVATAR
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white24,
                                backgroundImage:
                                    controller.profileImg.value.isNotEmpty
                                        ? NetworkImage(
                                            controller.profileImg.value,
                                          )
                                        : null,
                                child: controller.profileImg.value.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 46,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap:
                                    controller.pickAndUploadProfileImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Color(0xFF6C63FF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= FORM CARD =================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _ProfileFormCard(controller: controller),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            // ================= LOADING =================
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// =======================================================
/// CARD FORM EDIT PROFILE
/// =======================================================
class _ProfileFormCard extends StatefulWidget {
  final OwnerProfileViewModel controller;

  const _ProfileFormCard({required this.controller});

  @override
  State<_ProfileFormCard> createState() => _ProfileFormCardState();
}

class _ProfileFormCardState extends State<_ProfileFormCard> {
  late final TextEditingController nameC;
  late final TextEditingController phoneC;
  late final TextEditingController passwordC;
  late final TextEditingController confirmPasswordC;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.controller.name.value);
    phoneC = TextEditingController(text: widget.controller.phone.value);
    passwordC = TextEditingController();
    confirmPasswordC = TextEditingController();

    ever<String>(widget.controller.name, (v) => nameC.text = v);
    ever<String>(widget.controller.phone, (v) => phoneC.text = v);
  }

  @override
  void dispose() {
    nameC.dispose();
    phoneC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _input(
            controller: nameC,
            label: 'Nama',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),

          Obx(
            () => _readOnly(
              label: 'Email',
              value: widget.controller.email.value,
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 14),

          _input(
            controller: phoneC,
            label: 'Nomor Telepon',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),

          const Divider(height: 32),

          _input(
            controller: passwordC,
            label: 'Password Baru (opsional)',
            icon: Icons.lock_outline,
            obscure: true,
          ),
          const SizedBox(height: 14),

          _input(
            controller: confirmPasswordC,
            label: 'Konfirmasi Password',
            icon: Icons.lock_reset,
            obscure: true,
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Simpan Perubahan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: _onSavePressed,
            ),
          ),
        ],
      ),
    );
  }

  // ================= ACTION =================
  Future<void> _onSavePressed() async {
    final newName = nameC.text.trim();
    final newPhone = phoneC.text.trim();
    final newPassword = passwordC.text.trim();
    final confirmPassword = confirmPasswordC.text.trim();

    if (newName.isEmpty || newPhone.isEmpty) {
      Get.snackbar('Validasi', 'Nama dan nomor HP wajib diisi');
      return;
    }

    if (newPassword.isNotEmpty) {
      if (newPassword.length < 6) {
        Get.snackbar('Error', 'Password minimal 6 karakter');
        return;
      }
      if (newPassword != confirmPassword) {
        Get.snackbar('Error', 'Konfirmasi password tidak cocok');
        return;
      }

      try {
        await FirebaseAuth.instance.currentUser!
            .updatePassword(newPassword);
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal mengganti password, silakan login ulang',
        );
        return;
      }
    }

    await widget.controller.updateProfile(
      newName: newName,
      newPhone: newPhone,
    );
  }

  // ================= UI HELPERS =================
  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF7F8FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _readOnly({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextField(
      enabled: false,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF0F1F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
