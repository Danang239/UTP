import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utp_flutter/app_session.dart';

import '../../../data/models/villa_favorite_model.dart';
import '../detail/detail_view.dart';

class FavoriteViewModel extends GetxController {
  final isEditMode = false.obs;
  final isLoading = false.obs;

  final favorites = <VillaFavorite>[].obs;

  final _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _favSub;

  String get uid {
    final id = AppSession.userDocId;
    if (id == null) throw 'User belum login';
    return id;
  }

  @override
  void onInit() {
    super.onInit();
    _listenFavorites(); // ⬅️ bukan load sekali, tapi listen terus
  }

  @override
  void onClose() {
    _favSub?.cancel();
    super.onClose();
  }

  /// Toggle Edit Mode
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  /// Dengarkan perubahan favorit user secara realtime
  void _listenFavorites() {
    isLoading.value = true;

    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .orderBy('createdAt', descending: true);

    _favSub = ref.snapshots().listen(
      (snap) async {
        final List<VillaFavorite> list = [];

        // setiap kali ada perubahan, kita rebuild list villa favorit
        for (var doc in snap.docs) {
          final favData = doc.data();

          final villaId = favData['villaId'] ?? doc.id;
          final villaSnap = await _db.collection('villas').doc(villaId).get();

          if (villaSnap.exists) {
            final data = villaSnap.data() as Map<String, dynamic>;

            list.add(
              VillaFavorite(
                id: doc.id,
                villaData: VillaFavoriteData(
                  id: villaId,
                  name: data['name'] ?? 'Tanpa Nama',
                  location: data['location'] ?? '-',
                ),
              ),
            );
          }
        }

        favorites.assignAll(list);
        isLoading.value = false;
      },
      onError: (e) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Gagal memuat data favorit: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  /// (Opsional) manual refresh kalau mau dipanggil dari luar
  Future<void> loadFavorites() async {
    // sekarang cukup panggil _listenFavorites lagi
    await _favSub?.cancel();
    _listenFavorites();
  }

  /// Remove favorit
  Future<void> removeFavorite(String id) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id)
        .delete();
    // tidak perlu panggil loadFavorites();
    // listener snapshots() akan otomatis terpanggil
  }

  /// Buka detail page (panggil DetailView dengan data lengkap villa)
  Future<void> goToDetail(VillaFavorite fav) async {
    try {
      final snap =
          await _db.collection('villas').doc(fav.villaData.id).get();

      if (!snap.exists) {
        Get.snackbar(
          'Villa tidak ditemukan',
          'Data villa sudah tidak tersedia.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final data = snap.data() as Map<String, dynamic>;

      Get.to(
        () => DetailView(
          villaId: fav.villaData.id,
          villaData: data,
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka detail villa: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
