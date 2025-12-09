// lib/modules/edit_profile/edit_profile_viewmodel.dart
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utp_flutter/app_session.dart';

// >>> TAMBAH INI
import 'package:utp_flutter/modules/user/profile/profile_viewmodel.dart';

class EditProfileViewModel extends GetxController {
  // TEXT CONTROLLER (dipakai di EditProfileView)
  final nameC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  // STATE
  final isLoading = false.obs;
  final imageBytes = Rx<Uint8List?>(null);

  final _db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  String get uid {
    final id = AppSession.userDocId;
    if (id == null) {
      throw 'Session user tidak ditemukan. Silakan login ulang.';
    }
    return id;
  }

  @override
  void onInit() {
    super.onInit();
    // isi awal dari AppSession
    nameC.text = AppSession.name ?? "";
    emailC.text = AppSession.email ?? "";
    passwordC.text = ""; // opsional
  }

  @override
  void onClose() {
    nameC.dispose();
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }

  // ==========================
  // PILIH FOTO DARI GALERI
  // ==========================
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        imageBytes.value = bytes;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih gambar: $e');
    }
  }

  // ==========================
  // UPLOAD FOTO KE SUPABASE
  // ==========================
  Future<String?> _uploadImage() async {
    if (imageBytes.value == null) return null;

    try {
      // path tetap pakai uid -> file selalu di-overwrite
      final String path = 'profile_images/$uid.jpg';

      await _supabase.storage
          .from('profile')
          .uploadBinary(
            path,
            imageBytes.value!,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      // BASE URL
      final String baseUrl = _supabase.storage
          .from('profile')
          .getPublicUrl(path);

      // Tambahkan query param untuk bust cache
      final String publicUrl =
          '$baseUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      return publicUrl;
    } catch (e) {
      Get.snackbar('Error', 'Gagal upload foto: $e');
      return null;
    }
  }

  // ==========================
  // SIMPAN PROFIL
  // ==========================
  Future<void> save() async {
    isLoading.value = true;

    try {
      final userRef = _db.collection('users').doc(uid);

      final updatedName = nameC.text.trim();
      final updatedEmail = emailC.text.trim();
      final updatedPassword = passwordC.text.trim();

      // Upload foto kalau ada yang baru
      final profileUrl = await _uploadImage();

      final Map<String, dynamic> updateData = {
        'name': updatedName,
        'email': updatedEmail,
      };

      if (updatedPassword.isNotEmpty) {
        updateData['password'] = updatedPassword;
      }

      if (profileUrl != null) {
        updateData['profile_img'] = profileUrl;
      }

      // simpan ke Firestore
      await userRef.update(updateData);

      // update AppSession lokal supaya ProfileView bisa pakai juga
      AppSession.name = updatedName;
      AppSession.email = updatedEmail;
      if (profileUrl != null) {
        AppSession.profileImg = profileUrl;
      }

      // ==== TRIGGER REFRESH PROFILE VIEW ====
      try {
        Get.find<ProfileViewModel>().refreshFromSession();
      } catch (_) {
        // kalau ProfileViewModel belum ter-register, abaikan saja
      }

      isLoading.value = false;

      // kembali ke halaman sebelumnya
      Get.back(); // ga perlu result lagi, karena kita sudah refresh manual

      Get.snackbar('Berhasil', 'Profil berhasil diperbarui');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Gagal menyimpan profil: $e');
    }
  }
}
