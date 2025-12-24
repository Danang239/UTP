import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  /// 🔐 PASSWORD BARU
  final passwordC = TextEditingController();
  final confirmPasswordC = TextEditingController();

  // =====================
  // STATE
  // =====================
  final isLoading = false.obs;

  /// FOTO PROFIL (WEB + MOBILE)
  final imageBytes = Rx<Uint8List?>(null);

  final _auth = FirebaseAuth.instance;

  /// UID dari session (single source of truth)
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
    confirmPasswordC.text = '';
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    confirmPasswordC.dispose();
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
    } catch (_) {
      Get.snackbar('Error', 'Gagal memilih foto');
    }
  }

  // =====================
  // SAVE PROFILE (NAMA + FOTO + PASSWORD)
  // =====================
  Future<void> save() async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final name = nameC.text.trim();
      final newPassword = passwordC.text.trim();
      final confirmPassword = confirmPasswordC.text.trim();

      if (name.isEmpty) {
        throw 'Nama wajib diisi';
      }

      // =====================
      // VALIDASI PASSWORD (JIKA DIISI)
      // =====================
      if (newPassword.isNotEmpty || confirmPassword.isNotEmpty) {
        if (newPassword.length < 6) {
          throw 'Password minimal 6 karakter';
        }
        if (newPassword != confirmPassword) {
          throw 'Konfirmasi password tidak cocok';
        }
      }

      // =====================
      // UPLOAD FOTO (OPTIONAL)
      // =====================
      String? photoUrl;
      if (imageBytes.value != null) {
        photoUrl = await repo.uploadProfileImage(
          userId: uid,
          role: AppSession.role ?? 'user',
          bytes: imageBytes.value!,
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

      await repo.updateUserProfile(
        userId: uid,
        data: updateData,
      );

      // =====================
      // UPDATE PASSWORD (FIREBASE AUTH)
      // =====================
      if (newPassword.isNotEmpty) {
        final user = _auth.currentUser;
        if (user == null) {
          throw 'User tidak ditemukan. Silakan login ulang.';
        }

        try {
          await user.updatePassword(newPassword);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            throw 'Untuk keamanan, silakan login ulang lalu ganti password kembali.';
          }
          rethrow;
        }
      }

      // =====================
      // UPDATE SESSION
      // =====================
      AppSession.name = name;
      if (photoUrl != null) {
        AppSession.profileImg = photoUrl;
      }

      // =====================
      // REFRESH PROFILE VIEW (JIKA ADA)
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
