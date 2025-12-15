import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  // ==========================
  // SESSION DATA
  // ==========================
  static String? userDocId; // == UID
  static String? phone;
  static String? name;
  static String? email;
  static String? role;
  static String? profileImg;
  static String? ownerId;

  // =====================================================
  // 🔥 SIMPAN SESSION DARI FIRESTORE (UID)
  // =====================================================
  static Future<bool> saveUserFromUid(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        print('❌ Firestore user tidak ditemukan (uid=$uid)');
        return false;
      }

      final data = doc.data()!;

      await _saveToMemoryAndPrefs(
        docId: uid,
        data: data,
      );

      print(
        '✅ Session saved | role=$role | ownerId=$ownerId',
      );

      return true;
    } catch (e) {
      print('❌ ERROR saveUserFromUid: $e');
      return false;
    }
  }

  // =====================================================
  // ♻️ LEGACY (TIDAK DIPAKAI LOGIN BARU, BIARKAN)
  // =====================================================
  static Future<bool> saveUser(String phoneNumber) async {
    try {
      if (phoneNumber.startsWith('0')) {
        phoneNumber = phoneNumber.substring(1);
      }

      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return false;

      final doc = snap.docs.first;
      final data = doc.data();

      await _saveToMemoryAndPrefs(
        docId: doc.id,
        data: data,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  // =====================================================
  // 🔁 CORE SESSION METHOD
  // =====================================================
  static Future<void> _saveToMemoryAndPrefs({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    userDocId = docId;
    phone = data['phone'];
    name = data['name'];
    email = data['email'];
    role = data['role'] ?? 'user';
    profileImg = data['profile_img'];

    ownerId = role == 'owner'
        ? data['owner_id']?.toString()
        : null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userDocId', userDocId!);
    await prefs.setString('phone', phone ?? '');
    await prefs.setString('name', name ?? '');
    await prefs.setString('email', email ?? '');
    await prefs.setString('role', role ?? 'user');
    await prefs.setString('profile_img', profileImg ?? '');
    await prefs.setString('ownerId', ownerId ?? '');
  }

  // =====================================================
  // LOAD SESSION
  // =====================================================
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

  // =====================================================
  // LOGOUT
  // =====================================================
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

    print('🧹 Session cleared');
  }
}
