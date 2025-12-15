import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_owner_item.dart';

class AdminDataOwnerViewModel extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxList<AdminOwnerItem> owners = <AdminOwnerItem>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOwners();
  }

  // =====================================================
  // LOAD OWNER (role = owner)
  // =====================================================
  Future<void> loadOwners() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'owner')
          .get();

      final items = snapshot.docs
          .map((doc) => AdminOwnerItem.fromFirestore(doc.data(), doc.id))
          .toList();

      owners.assignAll(items);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // CREATE OWNER (FINAL & AMAN)
  // =====================================================
  Future<void> createOwner({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (isLoading.value) return; // 🔥 cegah double submit

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // 🔎 optional: cek email duplikat
      final existing = await _db
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw 'Email sudah terdaftar';
      }

      // 🔥 BUAT doc ID SENDIRI
      final ownerRef = _db.collection('users').doc();
      final ownerId = ownerRef.id;

      await ownerRef.set({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password, // sesuai sistem kamu
        'role': 'owner',      // 🔥 FIX
        'owner_id': ownerId,  // 🔥 KUNCI RELASI
        'profile_img': '',
        'created_at': FieldValue.serverTimestamp(), // ✅ FIX
        'updated_at': FieldValue.serverTimestamp(),
      });

      await loadOwners();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Gagal',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // UPDATE OWNER
  // =====================================================
  Future<void> updateOwner({
    required String ownerId,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _db.collection('users').doc(ownerId).update({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'updated_at': Timestamp.now(),
      });

      await loadOwners();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // DELETE OWNER
  // =====================================================
  Future<void> deleteOwner(String ownerId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _db.collection('users').doc(ownerId).delete();
      await loadOwners();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}
