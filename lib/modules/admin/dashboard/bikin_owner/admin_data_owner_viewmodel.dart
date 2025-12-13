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
    loadOwners(); // Memanggil loadOwners() saat inisialisasi
  }

  // Load daftar owner
  Future<void> loadOwners() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final snapshot = await _db.collection('users').where('role', isEqualTo: 'owner').get();
      final List<AdminOwnerItem> items = [];
      
      for (final doc in snapshot.docs) {
        items.add(AdminOwnerItem.fromFirestore(doc.data(), doc.id));
      }

      owners.assignAll(items);  // Memperbarui daftar owner
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Create new owner
  Future<void> createOwner(String name, String email, String phone) async {
    try {
      await _db.collection('users').add({
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'owner',  // Role owner secara default
      });
      loadOwners();  // Reload the owners list after creation
    } catch (e) {
      print('Error creating owner: $e');
    }
  }

  // Update existing owner
  Future<void> updateOwner(String ownerId, String name, String email, String phone) async {
    try {
      await _db.collection('users').doc(ownerId).update({
        'name': name,
        'email': email,
        'phone': phone,
      });
      loadOwners();  // Reload the owners list after update
    } catch (e) {
      print('Error updating owner: $e');
    }
  }

  // Delete owner
  Future<void> deleteOwner(String ownerId) async {
    try {
      await _db.collection('users').doc(ownerId).delete();
      loadOwners();  // Reload the owners list after deletion
    } catch (e) {
      print('Error deleting owner: $e');
    }
  }
}
