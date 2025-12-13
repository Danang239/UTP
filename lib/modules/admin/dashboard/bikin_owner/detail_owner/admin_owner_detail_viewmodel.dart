import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_owner_item.dart';

class AdminOwnerDetailViewModel extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<dynamic> villas = <dynamic>[].obs;
  final Rx<AdminOwnerItem> owner = Rx<AdminOwnerItem>(
    AdminOwnerItem(id: '', name: '', email: '', phone: '', role: ''),
  );

  Future<void> loadOwnerAndVillas(String ownerId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Load owner data
      final ownerSnapshot = await _db.collection('users').doc(ownerId).get();

      if (ownerSnapshot.exists) {
        owner.value = AdminOwnerItem(
          id: ownerSnapshot.id,
          name: ownerSnapshot['name'] ?? 'Tidak ada nama',
          email: ownerSnapshot['email'] ?? 'Tidak ada email',
          phone: ownerSnapshot['phone'] ?? 'Tidak ada telepon',
          role: ownerSnapshot['role'] ?? 'Tidak ada peran',
        );
      } else {
        errorMessage.value = 'Owner tidak ditemukan';
      }

      // Load villas data for this owner
      final villaSnapshot = await _db.collection('villas').where('owner_id', isEqualTo: ownerId).get();
      villas.assignAll(villaSnapshot.docs.map((doc) => doc.data()).toList());

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
