import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_owner_item.dart';

class AdminOwnerDetailViewModel extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ✅ PAKAI Rxn (nullable) → aman hot reload
  final owner = Rxn<AdminOwnerItem>();

  // list villa milik owner
  final villas = <Map<String, dynamic>>[].obs;

  Future<void> loadOwnerAndVillas(String ownerId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      owner.value = null;
      villas.clear();

      // =====================
      // LOAD OWNER
      // =====================
      final ownerSnapshot =
          await _db.collection('users').doc(ownerId).get();

      if (!ownerSnapshot.exists) {
        errorMessage.value = 'Owner tidak ditemukan';
        return;
      }

      owner.value = AdminOwnerItem.fromFirestore(
        ownerSnapshot.data()!,
        ownerSnapshot.id,
      );

      // =====================
      // LOAD VILLAS
      // =====================
      final villaSnapshot = await _db
          .collection('villas')
          .where('owner_id', isEqualTo: ownerId)
          .get();

      villas.assignAll(
        villaSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // optional, biar gampang dipakai di UI
          return data;
        }).toList(),
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
