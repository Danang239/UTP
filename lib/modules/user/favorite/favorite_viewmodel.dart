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

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _favSub;

  String get uid {
    final id = AppSession.userDocId;
    if (id == null) {
      throw 'User belum login';
    }
    return id;
  }

  @override
  void onInit() {
    super.onInit();
    _listenFavorites();
  }

  @override
  void onClose() {
    _favSub?.cancel();
    super.onClose();
  }

  // =========================
  // TOGGLE EDIT MODE
  // =========================
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
  }

  // =========================
  // LISTEN FAVORITES (REALTIME)
  // =========================
  void _listenFavorites() {
    isLoading.value = true;

    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .orderBy('createdAt', descending: true);

    _favSub = ref.snapshots().listen(
      (snap) async {
        final List<VillaFavorite> result = [];

        for (final doc in snap.docs) {
          final favData = doc.data();
          final String villaId = favData['villaId'] ?? doc.id;

          final villaSnap =
              await _db.collection('villas').doc(villaId).get();

          if (!villaSnap.exists) continue;

          final data = villaSnap.data() as Map<String, dynamic>;

          // =========================
          // 🔥 AMBIL FOTO VILLA (AMAN)
          // =========================
          String imageUrl = '';

          final imageUrls = data['image_urls'];
          final images = data['images'];
          final singleImage = data['image_url'];

          if (imageUrls is List && imageUrls.isNotEmpty) {
            imageUrl = imageUrls.first.toString();
          } else if (images is List && images.isNotEmpty) {
            imageUrl = images.first.toString();
          } else if (singleImage is String && singleImage.isNotEmpty) {
            imageUrl = singleImage;
          }

          result.add(
            VillaFavorite(
              id: doc.id,
              villaData: VillaFavoriteData(
                id: villaId,
                name: (data['name'] ?? 'Tanpa Nama').toString(),
                location: (data['location'] ?? '-').toString(),
                imageUrl: imageUrl,
              ),
            ),
          );
        }

        favorites.assignAll(result);
        isLoading.value = false;
      },
      onError: (error) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Gagal memuat data favorit',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  // =========================
  // REMOVE FAVORITE
  // =========================
  Future<void> removeFavorite(String id) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(id)
        .delete();
  }

  // =========================
  // GO TO DETAIL
  // =========================
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

      Get.to(
        () => DetailView(
          villaId: fav.villaData.id,
          villaData: snap.data()!,
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka detail villa',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
