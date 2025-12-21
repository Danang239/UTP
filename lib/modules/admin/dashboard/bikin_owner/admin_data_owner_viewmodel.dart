import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_owner_item.dart';

class AdminDataOwnerViewModel
    extends
        GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxList<
    AdminOwnerItem
  >
  owners =
      <
            AdminOwnerItem
          >[]
          .obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadOwners();
  }

  // =====================================================
  // LOAD OWNER
  // =====================================================
  Future<
    void
  >
  loadOwners() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _db
          .collection(
            'users',
          )
          .where(
            'role',
            isEqualTo: 'owner',
          )
          .get();

      owners.assignAll(
        snapshot.docs
            .map(
              (
                d,
              ) => AdminOwnerItem.fromFirestore(
                d.data(),
                d.id,
              ),
            )
            .toList(),
      );
    } catch (
      e
    ) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // CREATE OWNER (AUTH + FIRESTORE | ADMIN SAFE)
  // =====================================================
  Future<
    void
  >
  createOwner({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (isLoading.value) return;

    FirebaseApp? secondaryApp;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final emailTrim = email.trim();

      // 🔎 cek email di firestore
      final exist = await _db
          .collection(
            'users',
          )
          .where(
            'email',
            isEqualTo: emailTrim,
          )
          .limit(
            1,
          )
          .get();

      if (exist.docs.isNotEmpty) {
        throw 'Email sudah terdaftar';
      }

      // =====================================================
      // INIT SECONDARY FIREBASE APP
      // =====================================================
      secondaryApp = await Firebase.initializeApp(
        name: 'Secondary',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(
        app: secondaryApp,
      );

      // =====================================================
      // CREATE AUTH USER
      // =====================================================
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: emailTrim,
        password: password,
      );

      final uid = credential.user!.uid;

      // =====================================================
      // SAVE TO FIRESTORE
      // =====================================================
      await _db
          .collection(
            'users',
          )
          .doc(
            uid,
          )
          .set(
            {
              'uid': uid,
              'name': name.trim(),
              'email': emailTrim,
              'phone': phone.trim(),
              'role': 'owner',
              'profile_img': '',
              'is_active': true,
              'created_by': 'admin',
              'created_at': FieldValue.serverTimestamp(),
              'updated_at': FieldValue.serverTimestamp(),
            },
          );

      await secondaryAuth.signOut();
      await secondaryApp.delete();

      await loadOwners();

      Get.snackbar(
        'Berhasil',
        'Akun owner berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (
      e
    ) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // UPDATE OWNER (Firestore only)
  // =====================================================
  Future<
    void
  >
  updateOwner({
    required String ownerId,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      isLoading.value = true;

      await _db
          .collection(
            'users',
          )
          .doc(
            ownerId,
          )
          .update(
            {
              'name': name.trim(),
              'phone': phone.trim(),
              'updated_at': FieldValue.serverTimestamp(),
            },
          );

      await loadOwners();
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // SOFT DELETE (NONAKTIFKAN)
  // =====================================================
  Future<
    void
  >
  deleteOwner(
    String ownerId,
  ) async {
    try {
      isLoading.value = true;

      await _db
          .collection(
            'users',
          )
          .doc(
            ownerId,
          )
          .update(
            {
              'is_active': false,
              'updated_at': FieldValue.serverTimestamp(),
            },
          );

      await loadOwners();
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // TOGGLE ACTIVE / NONACTIVE
  // =====================================================
  Future<
    void
  >
  toggleActiveOwner({
    required String ownerId,
    required bool makeActive,
  }) async {
    try {
      isLoading.value = true;

      await _db
          .collection(
            'users',
          )
          .doc(
            ownerId,
          )
          .update(
            {
              'is_active': makeActive,
              'updated_at': FieldValue.serverTimestamp(),
            },
          );

      await loadOwners();

      Get.snackbar(
        'Berhasil',
        makeActive
            ? 'Owner diaktifkan'
            : 'Owner dinonaktifkan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (
      e
    ) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // HARD DELETE OWNER (Firestore only)
  // =====================================================
  Future<
    void
  >
  hardDeleteOwner(
    String ownerId,
  ) async {
    try {
      isLoading.value = true;

      await _db
          .collection(
            'users',
          )
          .doc(
            ownerId,
          )
          .delete();

      await loadOwners();

      Get.snackbar(
        'Berhasil',
        'Owner dihapus dari Firestore',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (
      e
    ) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        errorMessage.value,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
