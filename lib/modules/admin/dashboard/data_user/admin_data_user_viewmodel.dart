import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminUserItem {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime? createdAt;
  final bool isActive;
  final DateTime? bannedUntil;

  AdminUserItem({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.createdAt,
    required this.isActive,
    required this.bannedUntil,
  });

  bool get isCurrentlyBanned {
    if (bannedUntil == null) return false;
    return bannedUntil!.isAfter(DateTime.now());
  }
}

class AdminDataUserViewModel extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final users = <AdminUserItem>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'user') // hanya user biasa
          .orderBy('created_at', descending: false)
          .get();

      final items = snapshot.docs.map(_mapUserDoc).toList();
      users.assignAll(items);
    } catch (e, st) {
      print('ERROR loadUsers: $e\n$st');
      errorMessage.value = e.toString();
      users.clear();
    } finally {
      isLoading.value = false;
    }
  }

  AdminUserItem _mapUserDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    DateTime? createdAt;
    if (data['created_at'] is Timestamp) {
      createdAt = (data['created_at'] as Timestamp).toDate();
    }

    DateTime? bannedUntil;
    if (data['banned_until'] is Timestamp) {
      bannedUntil = (data['banned_until'] as Timestamp).toDate();
    }

    return AdminUserItem(
      id: doc.id,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      phone: (data['phone'] ?? '-') as String,
      // kalau field alamat-mu di Firestore namanya beda, ganti di sini
      address: (data['alamat'] ?? data['address'] ?? '-') as String,
      createdAt: createdAt,
      isActive: (data['is_active'] ?? true) as bool,
      bannedUntil: bannedUntil,
    );
  }

  /// Toggle aktif/nonaktif permanen (blokir akun)
  Future<void> toggleActive(AdminUserItem user) async {
    final newValue = !user.isActive;
    await _db.collection('users').doc(user.id).update({
      'is_active': newValue,
      // kalau diblokir permanen, hapus ban sementara
      'banned_until': null,
      'updated_at': FieldValue.serverTimestamp(),
    });
    await loadUsers();
  }

  /// Ban sementara (N hari ke depan)
  Future<void> banUserForDays(AdminUserItem user, int days) async {
    final now = DateTime.now();
    final until = now.add(Duration(days: days));

    await _db.collection('users').doc(user.id).update({
      'is_active': true, // tetap active, tapi sedang dibanned sementara
      'banned_until': Timestamp.fromDate(until),
      'updated_at': FieldValue.serverTimestamp(),
    });

    await loadUsers();
  }

  /// Hapus ban (kembalikan normal)
  Future<void> clearBan(AdminUserItem user) async {
    await _db.collection('users').doc(user.id).update({
      'banned_until': null,
      'updated_at': FieldValue.serverTimestamp(),
    });

    await loadUsers();
  }
}
