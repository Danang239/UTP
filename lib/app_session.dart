import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static String? userDocId;
  static String? phone;
  static String? name;
  static String? email;
  static String? role;
  static String? profileImg;
  static String? ownerId;

  static Future<bool> saveUser(String phoneNumber) async {
    try {
      if (phoneNumber.startsWith("0")) {
        phoneNumber = phoneNumber.substring(1);
      }

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

      userDocId = doc.id;
      phone = data['phone'] ?? "";
      name = data['name'] ?? "";
      email = data['email'] ?? "";
      role = data['role'] ?? "user";
      profileImg = data['profile_img'] ?? "";

      // 🔥 FIX UTAMA DI SINI
      ownerId = data['owner_id']?.toString().trim() ?? "";

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userDocId', userDocId!);
      await prefs.setString('phone', phone!);
      await prefs.setString('name', name!);
      await prefs.setString('email', email!);
      await prefs.setString('role', role!);
      await prefs.setString('profile_img', profileImg ?? "");
      await prefs.setString('ownerId', ownerId ?? "");

      print(
        "User session saved | role=$role | ownerId=$ownerId",
      );

      return true;
    } catch (e) {
      print("ERROR saveUser: $e");
      return false;
    }
  }

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
