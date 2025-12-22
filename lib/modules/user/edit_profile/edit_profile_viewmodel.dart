import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// ✅ SATU-SATUNYA FORMAT GAMBAR (WEB + MOBILE)
  final imageBytes = Rx<Uint8List?>(null);

  /// 🔑 SATU SUMBER KEBENARAN UID
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
  // PICK IMAGE (WEB + MOBILE)
  // =====================
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );

      if (picked != null) {
        imageBytes.value = await picked.readAsBytes();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih foto');
    }
  }

  // =====================
  // SAVE PROFILE
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
          role: AppSession.role ?? 'user',
          bytes: imageBytes.value!, // 🔥 FIX UTAMA
        );
      }

      // =====================
      // UPDATE FIRESTORE
      // =====================
      final updateData = <String, dynamic>{
        'name': name,
        if (photoUrl != null) 'profile_img': photoUrl,
        'updated_at': FieldValue.serverTimestamp(),
      };

      await repo.updateUserProfile(userId: uid, data: updateData);

      // =====================
      // UPDATE SESSION
      // =====================
      AppSession.name = name;
      if (photoUrl != null) {
        AppSession.profileImg = photoUrl;
      }

      // =====================
      // REFRESH PROFILE VIEW
      // =====================
      if (Get.isRegistered<ProfileViewModel>()) {
        Get.find<ProfileViewModel>().refreshFromSession();
      }

      Get.back(result: true);
      Get.snackbar('Berhasil', 'Profil berhasil diperbarui');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
