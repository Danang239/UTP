import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utp_flutter/app_session.dart';
import 'package:utp_flutter/modules/user/main/main_page.dart';

class RegisterViewModel extends GetxController {
  // =====================
  // TEXT CONTROLLERS
  // =====================
  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  // =====================
  // STATE
  // =====================
  final isLoading = false.obs;
  final errorMessage = RxnString();

  // =====================
  // SERVICES
  // =====================
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection('users');

  @override
  void onClose() {
    nameC.dispose();
    phoneC.dispose();
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }

  // =====================
  // REGISTER USER
  // =====================
  Future<void> register() async {
    String name = nameC.text.trim();
    String phone = phoneC.text.trim();
    final String email = emailC.text.trim();
    final String password = passwordC.text.trim();

    // =====================
    // VALIDASI FORM
    // =====================
    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Semua field wajib diisi.';
      return;
    }

    if (password.length < 6) {
      errorMessage.value = 'Password minimal 6 karakter.';
      return;
    }

    // Normalisasi phone → 812xxx
    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      // =====================
      // 1️⃣ FIREBASE AUTH
      // =====================
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw Exception('Registrasi gagal, user tidak ditemukan');
      }

      final String uid = user.uid;

      // =====================
      // 2️⃣ FIRESTORE USER DATA
      // =====================
      await _usersRef.doc(uid).set({
        'name': name,
        'phone': phone,
        'email': email,
        'role': 'user',
        'profile_img': '',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'is_active': true,
      });

      // =====================
      // 3️⃣ SESSION
      // =====================
      final bool ok = await AppSession.saveUserFromUid(uid);
      if (!ok) {
        throw Exception('Gagal menyimpan sesi pengguna');
      }

      // =====================
      // 4️⃣ NAVIGASI
      // =====================
      Get.offAll(() => const MainPage());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        errorMessage.value = 'Email sudah terdaftar.';
      } else if (e.code == 'weak-password') {
        errorMessage.value = 'Password terlalu lemah.';
      } else if (e.code == 'invalid-email') {
        errorMessage.value = 'Format email tidak valid.';
      } else {
        errorMessage.value = e.message;
      }
    } catch (e) {
      debugPrint('Register error: $e');
      errorMessage.value = 'Terjadi kesalahan, silakan coba lagi.';
    } finally {
      isLoading.value = false;
    }
  }
}
