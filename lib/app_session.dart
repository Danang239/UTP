import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static String? userDocId;
  static String? phone;
  static String? name;
  static String? email;
  static String? role;
  static String? profileImg; // URL foto profil (boleh null)
  static String? ownerId;    // kode owner seperti "owner_1"

  /// SIMPAN DAN LOAD DATA USER
  static Future<bool> saveUser(String phoneNumber) async {
    try {
      // Normalisasi nomor (pastikan tidak ada "0" depan)
      if (phoneNumber.startsWith("0")) {
        phoneNumber = phoneNumber.substring(1);
      }

      /// CARI USER DI FIRESTORE
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        print("User tidak ditemukan.");
        return false;
      }

      final doc = snap.docs.first;
      final data = doc.data();

      // SIMPAN KE MEMORY
      userDocId = doc.id;
      phone = data['phone'] ?? "";
      name = data['name'] ?? "";
      email = data['email'] ?? "";
      role = data['role'] ?? "user";
      profileImg = data['profile_img'] ?? ""; // kosong = belum ada foto
      ownerId = data['owner_id'] ?? "";       // 🔥 PENTING: baca owner_id di Firestore

      // SIMPAN KE LOCAL STORAGE (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userDocId', userDocId!);
      await prefs.setString('phone', phone!);
      await prefs.setString('name', name!);
      await prefs.setString('email', email!);
      await prefs.setString('role', role!);
      await prefs.setString('profile_img', profileImg ?? "");
      await prefs.setString('ownerId', ownerId ?? "");

      print(
          "User data saved session: phone=$phone | email=$email | name=$name | role=$role | ownerId=$ownerId");
      return true;
    } catch (e) {
      print("ERROR saveUser: $e");
      return false;
    }
  }

  /// AMBIL SESSION SAAT APLIKASI DIBUKA
  static Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    userDocId = prefs.getString('userDocId');
    phone = prefs.getString('phone');
    name = prefs.getString('name');
    email = prefs.getString('email');
    role = prefs.getString('role');
    profileImg = prefs.getString('profile_img');
    ownerId = prefs.getString('ownerId');

    return userDocId != null;
  }

  /// HAPUS SESSION (LOGOUT)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    userDocId = null;
    phone = null;
    name = null;
    email = null;
    role = null;
    profileImg = null;
    ownerId = null;

    print("User session cleared.");
  }
}
