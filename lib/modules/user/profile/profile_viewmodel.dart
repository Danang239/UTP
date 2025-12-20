import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app_session.dart';
import 'package:utp_flutter/app/routes/app_routes.dart';

// ⬇️ TAMBAHAN UNTUK CHAT ADMIN
import 'package:firebase_auth/firebase_auth.dart';

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

  // ===============================
  //  REFRESH DARI SESSION
  // ===============================
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

  // ===============================
  //  LOAD USER DARI FIRESTORE
  // ===============================
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

  // ===============================
  //  HUBUNGI ADMIN (FITUR BARU)
  // ===============================
  Future<void> hubungiAdmin() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final String userId = currentUser.uid;

    // ambil nama user (sudah ada di state)
    final String userName =
        name.value.isNotEmpty ? name.value : 'User';

    final chatRef =
        _db.collection('admin_chats').doc(userId);

    final chatSnap = await chatRef.get();

    // jika chat belum ada, buat dulu
    if (!chatSnap.exists) {
      await chatRef.set({
        'userId': userId,
        'userName': userName,
        'lastMessage': '',
        'lastSender': '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // masuk ke halaman chat admin
    Get.toNamed(
      Routes.adminChat, // ⬅️ pastikan route ini ada
      arguments: {
        'userId': userId,
        'userName': userName,
      },
    );
  }

  // ===============================
  //  LOGOUT
  // ===============================
  Future<void> logout() async {
    // bersihkan session lokal
    await AppSession.clear();
    isLoggedIn.value = false;
    name.value = '';
    email.value = '';
    profileImg.value = '';

    // balik ke halaman login
    Get.offAllNamed(Routes.login);
  }
}
