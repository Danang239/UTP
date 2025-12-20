import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:utp_flutter/app_session.dart';
import 'package:utp_flutter/app/routes/app_routes.dart';
import 'package:utp_flutter/main.dart';
import 'package:utp_flutter/modules/user/main/main_page.dart';

class LoginViewModel extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  // =====================================================
  // LOGIN (EMAIL / PHONE + PASSWORD)
  // =====================================================
  Future<void> login(String identifier, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      if (identifier.isEmpty || password.isEmpty) {
        errorMessage.value = 'Email / Nomor HP dan password wajib diisi';
        return;
      }

      // =====================================================
      // 1️⃣ JIKA LOGIN VIA PHONE → AMBIL EMAIL DARI FIRESTORE
      // =====================================================
      String emailToLogin = identifier.trim();

      if (!identifier.contains('@')) {
        String phone = identifier.trim();
        if (phone.startsWith('0')) {
          phone = phone.substring(1);
        }

        final snap = await FirebaseFirestore.instance
            .collection('users')
            .where('phone', isEqualTo: phone)
            .limit(1)
            .get();

        if (snap.docs.isEmpty) {
          errorMessage.value = 'Akun tidak ditemukan';
          return;
        }

        emailToLogin = snap.docs.first['email'];
      }

      // =====================================================
      // 2️⃣ LOGIN KE FIREBASE AUTH
      // =====================================================
      final credential = await _auth.signInWithEmailAndPassword(
        email: emailToLogin,
        password: password,
      );

      final uid = credential.user!.uid;

      // =====================================================
      // 3️⃣ AMBIL DATA USER DARI FIRESTORE (BERDASARKAN UID)
      // =====================================================
      final ok = await AppSession.saveUserFromUid(uid);
      if (!ok) {
        errorMessage.value = 'Gagal memuat data akun';
        await _auth.signOut();
        return;
      }

      // =====================================================
      // 4️⃣ REDIRECT SESUAI ROLE
      // =====================================================
      final role = AppSession.role ?? 'user';

      if (role == 'admin') {
        Get.offAllNamed(Routes.adminDashboard);
      } else if (role == 'owner') {
        Get.offAllNamed(Routes.ownerDashboard);
      } else {
        Get.offAll(() => const MainPage());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage.value = 'Akun tidak ditemukan';
      } else if (e.code == 'wrong-password') {
        errorMessage.value = 'Password salah';
      } else {
        errorMessage.value = e.message;
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
