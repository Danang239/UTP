import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:utp_flutter/app_session.dart';

class OwnerProfileViewModel extends GetxController {
  // =====================
  // STATE
  // =====================
  final name = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final profileImg = ''.obs;
  final isLoading = false.obs;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  static const String _baseUrl = 'http://localhost:3000';

  String? get uid => _auth.currentUser?.uid;
  String? get userDocId => AppSession.userDocId;

  // =====================
  // INIT
  // =====================
  @override
  void onInit() {
    super.onInit();
    _loadFromSession();
    loadFromFirestore();
  }

  void _loadFromSession() {
    name.value = AppSession.name ?? '';
    email.value = AppSession.email ?? '';
    phone.value = AppSession.phone ?? '';
    profileImg.value = AppSession.profileImg ?? '';
  }

  // =====================
  // LOAD FIRESTORE
  // =====================
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

      AppSession.name = name.value;
      AppSession.email = email.value;
      AppSession.phone = phone.value;
      AppSession.profileImg = profileImg.value;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // UPDATE NAMA & PHONE (LAMA)
  // ============================
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

  // ============================
  // 🔥 UPDATE + KEMBALI KE PROFILE
  // ============================
  Future<void> updateProfileAndBack({
    required String newName,
    required String newPhone,
  }) async {
    await updateProfile(
      newName: newName,
      newPhone: newPhone,
    );

    // 👉 langsung kembali ke halaman profile owner
    Get.offNamed('/owner-profile');
  }

  // ============================
  // UPLOAD FOTO PROFIL → BACKEND
  // ============================
  Future<void> pickAndUploadProfileImage() async {
    final id = userDocId;
    if (id == null) {
      Get.snackbar('Error', 'User tidak ditemukan.');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      isLoading.value = true;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload/profile'),
      )
        ..fields['userId'] = id
        ..fields['role'] = 'owner';

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path!,
          ),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw Exception(body);
      }

      final json = jsonDecode(body);
      final url = json['url'] as String;

      await _db.collection('users').doc(id).update({
        'profile_img': url,
        'updated_at': FieldValue.serverTimestamp(),
      });

      profileImg.value = url;
      AppSession.profileImg = url;

      Get.snackbar('Berhasil', 'Foto profil diperbarui');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // GANTI PASSWORD
  // ============================
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      Get.snackbar('Error', 'User tidak valid');
      return;
    }

    isLoading.value = true;
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      Get.snackbar(
        'Berhasil',
        'Password berhasil diubah',
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Gagal mengubah password');
    } finally {
      isLoading.value = false;
    }
  }

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout() async {
    await _auth.signOut();
    await AppSession.clear();
    Get.offAllNamed('/login');
  }
}
