import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app_session.dart';

import 'edit_profile_viewmodel.dart';

class EditProfileView extends GetView<EditProfileViewModel> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        return Stack(
          children: [
            _buildContent(context),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.15),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      }),
    );
  }

  // ===============================
  // MAIN CONTENT
  // ===============================
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // ================= FOTO PROFIL =================
            Obx(() {
              final bytes = controller.imageBytes.value;

              ImageProvider? avatarImage;
              if (bytes != null) {
                avatarImage = MemoryImage(bytes);
              } else if (AppSession.profileImg != null &&
                  AppSession.profileImg!.isNotEmpty) {
                avatarImage = NetworkImage(AppSession.profileImg!);
              }

              return GestureDetector(
                onTap: controller.pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? Icon(
                              Icons.person,
                              size: 48,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                            )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 30),

            // ================= NAMA =================
            _inputField(
              context,
              controller: controller.nameC,
              label: "Nama",
            ),

            const SizedBox(height: 18),

            // ================= EMAIL =================
            _inputField(
              context,
              controller: controller.emailC,
              label: "Email",
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 18),

            // ================= PASSWORD =================
            _inputField(
              context,
              controller: controller.passwordC,
              label: "Password Baru (opsional)",
              obscureText: true,
            ),

            const SizedBox(height: 30),

            // ================= SIMPAN =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  // INPUT FIELD (THEME AWARE)
  // ===============================
  Widget _inputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
