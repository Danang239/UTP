import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utp_flutter/app_session.dart';

/// Model untuk dokumen villa di Firestore
class OwnerVilla {
  final String id;
  final String name;
  final String description;
  final int capacity;
  final int maxPerson;
  final int weekdayPrice;
  final int weekendPrice;
  final double lat;
  final double lng;
  final String location;
  final String mapsLink;
  final List<String> images;
  final List<String> videos;
  final List<String> facilities;
  final String ownerId;

  OwnerVilla({
    required this.id,
    required this.name,
    required this.description,
    required this.capacity,
    required this.maxPerson,
    required this.weekdayPrice,
    required this.weekendPrice,
    required this.lat,
    required this.lng,
    required this.location,
    required this.mapsLink,
    required this.images,
    required this.videos,
    required this.facilities,
    required this.ownerId,
  });

  factory OwnerVilla.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return OwnerVilla(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      capacity: (data['capacity'] ?? 0) as int,
      maxPerson: (data['max_person'] ?? 0) as int,
      weekdayPrice: (data['weekday_price'] ?? 0) as int,
      weekendPrice: (data['weekend_price'] ?? 0) as int,
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      location: data['location'] ?? '',
      mapsLink: data['maps_link'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      facilities: List<String>.from(data['facilities'] ?? []),
      ownerId: data['owner_id'] ?? '',
    );
  }
}

class OwnerVillaViewModel extends GetxController {
  final _db = FirebaseFirestore.instance;
  final _supabase = Supabase.instance.client;

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final villas = <OwnerVilla>[].obs;

  StreamSubscription<QuerySnapshot>? _subscription;

  /// Ambil ID owner:
  /// 1. AppSession.userDocId (kalau ada)
  /// 2. Fallback: FirebaseAuth.currentUser?.uid
  String? get _currentOwnerId {
    return AppSession.userDocId ?? FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void onInit() {
    super.onInit();
    _listenVillas();
  }

  /// Dengarkan perubahan data villa milik owner saat ini
  void _listenVillas() {
    final ownerId = _currentOwnerId;

    if (ownerId == null) {
      errorMessage.value = 'Silakan login sebagai owner.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    _subscription?.cancel();

    _subscription = _db
        .collection('villas')
        .where('owner_id', isEqualTo: ownerId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final items = snapshot.docs.map(OwnerVilla.fromDoc).toList();
        villas.assignAll(items);
        isLoading.value = false;
      },
      onError: (e) {
        errorMessage.value = e.toString();
        isLoading.value = false;
      },
    );
  }

  /// Upload file-file yang sudah dipilih (foto & video) ke bucket "villas"
  /// Dipanggil SAAT tombol "Simpan Villa" ditekan, baik tambah maupun edit.
  Future<Map<String, List<String>>> uploadVillaFiles(
    List<PlatformFile> selectedFiles,
  ) async {
    final ownerId = _currentOwnerId;
    if (ownerId == null) {
      Get.snackbar('Gagal', 'Owner tidak ditemukan. Silakan login ulang.');
      return {'images': [], 'videos': []};
    }

    final imageUrls = <String>[];
    final videoUrls = <String>[];

    for (final file in selectedFiles) {
      final ext = (file.extension ?? '').toLowerCase();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final storagePath = 'villas/$ownerId/$fileName';

      if (kIsWeb) {
        // WEB: pakai bytes + uploadBinary
        final bytes = file.bytes;
        if (bytes == null) continue;

        await _supabase.storage
            .from('villas')
            .uploadBinary(storagePath, bytes);
      } else {
        // MOBILE / DESKTOP: pakai File(path)
        final path = file.path;
        if (path == null) continue;

        await _supabase.storage
            .from('villas')
            .upload(storagePath, File(path));
      }

      final publicUrl =
          _supabase.storage.from('villas').getPublicUrl(storagePath);

      if (ext == 'mp4') {
        videoUrls.add(publicUrl);
      } else {
        imageUrls.add(publicUrl);
      }
    }

    return {
      'images': imageUrls,
      'videos': videoUrls,
    };
  }

  /// Tambah villa baru ke collection `villas`
  Future<void> addVilla({
    required String name,
    required String description,
    required int capacity,
    required int maxPerson,
    required int weekdayPrice,
    required int weekendPrice,
    required String location,
    required double lat,
    required double lng,
    required String mapsLink,
    required List<String> facilities,
    required List<String> images,
    required List<String> videos,
  }) async {
    final ownerId = _currentOwnerId;

    if (ownerId == null) {
      Get.snackbar('Gagal', 'Owner tidak ditemukan. Silakan login ulang.');
      return;
    }

    try {
      isLoading.value = true;

      await _db.collection('villas').add({
        'name': name,
        'description': description,
        'capacity': capacity,
        'max_person': maxPerson,
        'weekday_price': weekdayPrice,
        'weekend_price': weekendPrice,
        'location': location,
        'lat': lat,
        'lng': lng,
        'facilities': facilities,
        'images': images,
        'videos': videos,
        'maps_link': mapsLink,
        'owner_id': ownerId,
        'created_at': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Berhasil', 'Villa berhasil ditambahkan.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Update villa yang sudah ada
  Future<void> updateVilla({
    required String id,
    required String name,
    required String description,
    required int capacity,
    required int maxPerson,
    required int weekdayPrice,
    required int weekendPrice,
    required String location,
    required double lat,
    required double lng,
    required String mapsLink,
    required List<String> facilities,
    required List<String> images,
    required List<String> videos,
  }) async {
    try {
      isLoading.value = true;

      await _db.collection('villas').doc(id).update({
        'name': name,
        'description': description,
        'capacity': capacity,
        'max_person': maxPerson,
        'weekday_price': weekdayPrice,
        'weekend_price': weekendPrice,
        'location': location,
        'lat': lat,
        'lng': lng,
        'facilities': facilities,
        'images': images,
        'videos': videos,
        'maps_link': mapsLink,
        'updated_at': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Berhasil', 'Villa berhasil diperbarui.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Hapus villa berdasarkan doc id
  Future<void> deleteVilla(String id) async {
    try {
      await _db.collection('villas').doc(id).delete();
      Get.snackbar('Berhasil', 'Villa berhasil dihapus.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
