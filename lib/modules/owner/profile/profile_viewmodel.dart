import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:utp_flutter/app_session.dart'; // sesuaikan path-nya

class OwnerProfileViewModel extends GetxController {
  final name = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final profileImg = ''.obs;
  final isLoading = false.obs;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  String? get uid => _auth.currentUser?.uid;
  String? get userDocId => AppSession.userDocId;

  @override
  void onInit() {
    super.onInit();
    _loadFromSession();
    loadFromFirestore();
  }

  /// Tarik data awal dari AppSession biar cepat
  void _loadFromSession() {
    name.value = AppSession.name ?? '';
    email.value = AppSession.email ?? '';
    phone.value = AppSession.phone ?? '';
    profileImg.value = AppSession.profileImg ?? '';
  }

  /// Refresh dari Firestore (source of truth)
  Future<void> loadFromFirestore() async {
    final id = userDocId;
    if (id == null) return;

    isLoading.value = true;
    try {
      final doc = await _db.collection('users').doc(id).get();
      if (!doc.exists) return;

      final data = doc.data() ?? {};
      name.value = data['name'] ?? '';
      email.value = data['email'] ?? '';
      phone.value = data['phone'] ?? '';
      profileImg.value = data['profile_img'] ?? '';

      // sinkron ke session
      AppSession.name = name.value;
      AppSession.email = email.value;
      AppSession.phone = phone.value;
      AppSession.profileImg = profileImg.value;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Update nama / phone saja (email biasanya tidak diubah di sini)
  Future<void> updateProfile({
    required String newName,
    required String newPhone,
  }) async {
    final id = userDocId;
    if (id == null) return;

    isLoading.value = true;
    try {
      await _db.collection('users').doc(id).update({
        'name': newName,
        'phone': newPhone,
        'updated_at': FieldValue.serverTimestamp(),
      });

      name.value = newName;
      phone.value = newPhone;

      AppSession.name = newName;
      AppSession.phone = newPhone;

      Get.snackbar('Berhasil', 'Profil berhasil diperbarui');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick file gambar -> upload ke Supabase -> simpan URL ke Firestore & Session
  Future<void> pickAndUploadProfileImage() async {
    final id = userDocId;
    if (id == null) {
      Get.snackbar('Error', 'User tidak ditemukan. Silakan login ulang.');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final Uint8List? bytes = file.bytes;
      if (bytes == null) {
        Get.snackbar('Error', 'Gagal membaca file gambar.');
        return;
      }

      // path di Supabase Storage
      final fileExt = (file.extension ?? 'jpg').toLowerCase();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final path = 'owners/$id/$fileName';

      isLoading.value = true;

      // upload ke bucket 'profile' (ganti nama bucket kalau berbeda)
      await _supabase.storage.from('profile').uploadBinary(
            path,
            bytes,
            // versi supabase kamu kemungkinan belum support contentType di sini,
            // jadi cukup pakai FileOptions() kosong
            fileOptions: const FileOptions(),
          );

      final publicUrl = _supabase.storage.from('profile').getPublicUrl(path);

      // simpan ke Firestore
      await _db.collection('users').doc(id).update({
        'profile_img': publicUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });

      profileImg.value = publicUrl;
      AppSession.profileImg = publicUrl;

      Get.snackbar('Berhasil', 'Foto profil diperbarui.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout owner
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}

    // bersihkan session lokal
    await AppSession.clear();

    // arahkan ke halaman login (ganti route sesuai punyamu)
    Get.offAllNamed('/login');
  }
}
