import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:utp_flutter/app_session.dart';
import 'package:utp_flutter/modules/owner/villa/villa_repository.dart';

/// =======================
/// MODEL VILLA
/// =======================
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
      capacity: data['capacity'] ?? 0,
      maxPerson: data['max_person'] ?? 0,
      weekdayPrice: data['weekday_price'] ?? 0,
      weekendPrice: data['weekend_price'] ?? 0,
      lat: (data['lat'] as num?)?.toDouble() ?? 0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0,
      location: data['location'] ?? '',
      mapsLink: data['maps_link'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      facilities: List<String>.from(data['facilities'] ?? []),
      ownerId: data['owner_id'] ?? '',
    );
  }
}

/// =======================
/// VIEWMODEL
/// =======================
class OwnerVillaViewModel extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _baseUrl = 'http://localhost:3000';

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final villas = <OwnerVilla>[].obs;

  StreamSubscription<QuerySnapshot>? _subscription;

  String? get _ownerId =>
      AppSession.userDocId ?? FirebaseAuth.instance.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _listenVillas();
  }

  /// =======================
  /// LISTEN DATA VILLA OWNER
  /// =======================
  void _listenVillas() {
    final ownerId = _ownerId;
    if (ownerId == null) return;

    _subscription?.cancel();

    _subscription = _db
        .collection('villas')
        .where('owner_id', isEqualTo: ownerId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      villas.assignAll(snapshot.docs.map(OwnerVilla.fromDoc).toList());
    });
  }

  /// =======================
  /// UPLOAD FILE → BACKEND
  /// =======================
  Future<Map<String, List<String>>> uploadVillaFiles(
    List<PlatformFile> files,
    String villaId,
  ) async {
    final ownerId = _ownerId;
    if (ownerId == null) throw 'Owner tidak ditemukan';

    final images = <String>[];
    final videos = <String>[];

    for (final file in files) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload/villa'),
      )
        ..fields['ownerId'] = ownerId
        ..fields['villaId'] = villaId;

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path!,
          ),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        throw body;
      }

      final json = jsonDecode(body);
      final url = json['url'] as String;

      (file.extension == 'mp4' ? videos : images).add(url);
    }

    return {'images': images, 'videos': videos};
  }

  /// =======================
  /// ADD VILLA
  /// =======================
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
    required List<PlatformFile> files,
  }) async {
    final ownerId = _ownerId;
    if (ownerId == null) return;

    try {
      isLoading.value = true;

      final villaRef = _db.collection('villas').doc();
      final media = await uploadVillaFiles(files, villaRef.id);

      await villaRef.set({
        'name': name,
        'description': description,
        'capacity': capacity,
        'max_person': maxPerson,
        'weekday_price': weekdayPrice,
        'weekend_price': weekendPrice,
        'location': location,
        'lat': lat,
        'lng': lng,
        'maps_link': mapsLink,
        'facilities': facilities,
        'images': media['images'],
        'videos': media['videos'],
        'owner_id': ownerId,
        'created_at': FieldValue.serverTimestamp(),
      });

      Get.snackbar('Berhasil', 'Villa berhasil ditambahkan');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  /// =======================
  /// UPDATE VILLA (FIXED)
  /// =======================
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
        'maps_link': mapsLink,
        'facilities': facilities,
        'images': images,
        'videos': videos,
        'updated_at': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Berhasil',
        'Villa berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// =======================
  /// DELETE VILLA
  /// =======================
  Future<void> deleteVilla(String id) async {
    try {
      isLoading.value = true;

      await _db.collection('villas').doc(id).delete();

      Get.snackbar(
        'Berhasil',
        'Villa berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
