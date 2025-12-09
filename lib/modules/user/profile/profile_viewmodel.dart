import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app_session.dart';
import 'package:utp_flutter/app/routes/app_routes.dart'; // ⬅️ TAMBAH INI

class ProfileViewModel extends GetxController {
  final name = ''.obs;
  final email = ''.obs;
  final profileImg = ''.obs;
  final isLoggedIn = false.obs;

  final _db = FirebaseFirestore.instance;

  String? get uid => AppSession.userDocId;

  @override
  void onInit() {
    super.onInit();
    loadUser(); // pertama kali: baca dari Session + Firestore
  }

  /// HANYA baca dari AppSession (tanpa ke Firestore)
  /// Dipakai setelah Edit Profile sukses.
  void refreshFromSession() {
    final id = AppSession.userDocId;

    if (id == null) {
      isLoggedIn.value = false;
      name.value = '';
      email.value = '';
      profileImg.value = '';
      return;
    }

    isLoggedIn.value = true;
    name.value = AppSession.name ?? '';
    email.value = AppSession.email ?? '';
    profileImg.value = AppSession.profileImg ?? '';
  }

  /// Ambil data user dari Firestore + AppSession
  Future<void> loadUser() async {
    // Isi dulu dari session supaya cepat muncul
    refreshFromSession();

    final id = uid;
    if (id == null) return;

    try {
      final snap = await _db.collection('users').doc(id).get();
      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;

        name.value = (data['name'] ?? name.value).toString();
        email.value = (data['email'] ?? email.value).toString();
        profileImg.value =
            (data['profile_img'] ?? profileImg.value).toString();

        // update Session juga
        AppSession.name = name.value;
        AppSession.email = email.value;
        AppSession.profileImg = profileImg.value;
      }
    } catch (_) {
      // kalau gagal, biarkan pakai data dari AppSession
    }
  }

  /// Logout
  Future<void> logout() async {
    // bersihkan session lokal
    await AppSession.clear();
    isLoggedIn.value = false;
    name.value = '';
    email.value = '';
    profileImg.value = '';

    // KUNCI: balik ke halaman login via route name,
    // supaya LoginBinding jalan dan LoginViewModel di-inject
    Get.offAllNamed(Routes.login);
  }
}
