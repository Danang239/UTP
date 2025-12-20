import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:utp_flutter/app_session.dart';
import 'package:utp_flutter/modules/user/profile/profile_viewmodel.dart';
import 'edit_profile_repository.dart';

class EditProfileViewModel extends GetxController {
  // =====================
  // DEPENDENCY
  // =====================
  final EditProfileRepository repo;
  EditProfileViewModel(this.repo);

  // =====================
  // TEXT CONTROLLER
  // =====================
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  // =====================
  // STATE
  // =====================
  final isLoading = false.obs;
  final imageBytes = Rx<Uint8List?>(null);

  /// 🔑 SATU SUMBER KEBENARAN UID (Firestore doc id)
  String get uid {
    final id = AppSession.userDocId;
    if (id == null || id.isEmpty) {
      throw 'Session user tidak valid. Silakan login ulang.';
    }
    return id;
  }

  // =====================
  // INIT
  // =====================
  @override
  void onInit() {
    super.onInit();
    nameC.text = AppSession.name ?? '';
    emailC.text = AppSession.email ?? '';
    passwordC.text = '';
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }

  // =====================
  // PICK IMAGE
  // =====================
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (file != null) {
        imageBytes.value = await file.readAsBytes();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih foto');
    }
  }

  // =====================
  // SAVE PROFILE (FINAL & STABLE)
  // =====================
  Future<void> save() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final name = nameC.text.trim();
      final email = emailC.text.trim();

      if (name.isEmpty || email.isEmpty) {
        throw 'Nama dan email wajib diisi';
      }

      // =====================
      // UPLOAD FOTO (OPTIONAL)
      // =====================
      String? photoUrl;
      if (imageBytes.value != null) {
        photoUrl = await repo.uploadProfileImage(
          userId: uid,
          bytes: imageBytes.value!,
        );
      }

      // =====================
      // UPDATE FIRESTORE
      // =====================
      final updateData = <String, dynamic>{
        'name': name,
        'email': email,
        if (photoUrl != null) 'profile_img': photoUrl,
        'updated_at': DateTime.now(),
      };

      await repo.updateUserProfile(userId: uid, data: updateData);

      // =====================
      // UPDATE SESSION
      // =====================
      AppSession.name = name;
      AppSession.email = email;
      if (photoUrl != null) {
        AppSession.profileImg = photoUrl;
      }

      // =====================
      // REFRESH PROFILE VIEW
      // =====================
      if (Get.isRegistered<ProfileViewModel>()) {
        Get.find<ProfileViewModel>().refreshFromSession();
      }

      // =====================
      // BACK TO PROFILE
      // =====================
      Get.back(result: true);
      Get.snackbar('Berhasil', 'Profil berhasil diperbarui');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
