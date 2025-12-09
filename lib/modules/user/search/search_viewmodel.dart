import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class SearchViewModel extends GetxController {
  final isLoading = false.obs;
  final selectedCategoryId = RxnString();
  final results = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  final CollectionReference<Map<String, dynamic>> villasRef =
      FirebaseFirestore.instance.collection('villas');

  // ================== SEARCH NAMA ==================
  Future<void> searchByName(String text) async {
    text = text.trim();
    selectedCategoryId.value = null;

    if (text.isEmpty) {
      results.clear();
      return;
    }

    isLoading.value = true;

    try {
      final snap = await villasRef
          .where('name', isGreaterThanOrEqualTo: text)
          .where('name', isLessThanOrEqualTo: '$text\uf8ff')
          .get();

      results.assignAll(snap.docs);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mencari villa: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================== FILTER KATEGORI ==================
  Future<void> filterByCategory(String id) async {
    selectedCategoryId.value = id;
    results.clear();
    isLoading.value = true;

    try {
      Query<Map<String, dynamic>> query = villasRef;

      switch (id) {
        case 'pool':
          query = query.where('facilities', arrayContains: 'pool');
          break;
        case 'big_yard':
          query = query.where('facilities', arrayContains: 'big_yard');
          break;
        case 'billiard':
          query = query.where('facilities', arrayContains: 'billiard');
          break;
        case 'big_villa':
          query = query.where('capacity', isGreaterThanOrEqualTo: 20);
          break;
        case 'small_villa':
          query = query.where('capacity', isLessThanOrEqualTo: 15);
          break;
      }

      final snap = await query.get();
      results.assignAll(snap.docs);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat kategori: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================== TERDEKAT DARI LOKASI ==================
  Future<void> loadNearest() async {
    if (kIsWeb) {
      Get.snackbar(
        'Info',
        'Fitur lokasi hanya tersedia di emulator / device (Android / iOS).',
      );
      return;
    }

    isLoading.value = true;
    results.clear();
    selectedCategoryId.value = null;

    try {
      // izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar('Error', 'Izin lokasi ditolak.');
        isLoading.value = false;
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final allSnap = await villasRef.get();
      final docs = allSnap.docs;

      final List<_VillaDistance> list = [];
      for (final doc in docs) {
        final data = doc.data();
        final lat = data['lat'];
        final lng = data['lng'];
        if (lat is num && lng is num) {
          final distance = Geolocator.distanceBetween(
            pos.latitude,
            pos.longitude,
            lat.toDouble(),
            lng.toDouble(),
          );
          list.add(_VillaDistance(doc: doc, distance: distance));
        }
      }

      list.sort((a, b) => a.distance.compareTo(b.distance));
      results.assignAll(list.map((e) => e.doc).toList());
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat villa terdekat: $e');
    } finally {
      isLoading.value = false;
    }
  }
}

class _VillaDistance {
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;
  final double distance;

  _VillaDistance({required this.doc, required this.distance});
}
