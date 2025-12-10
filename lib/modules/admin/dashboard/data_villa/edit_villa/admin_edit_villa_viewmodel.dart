// lib/modules/admin/data_villa/edit_villa/admin_edit_villa_viewmodel.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminEditVillaViewModel extends GetxController {
  final String villaId;

  AdminEditVillaViewModel({required this.villaId});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Controller untuk field form
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final maxPersonController = TextEditingController();
  final weekdayPriceController = TextEditingController();
  final weekendPriceController = TextEditingController();
  final ownerIdController = TextEditingController();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVilla();
  }

  // ----------------------------
  // LOAD DATA VILLA UNTUK EDIT
  // ----------------------------
  Future<void> _loadVilla() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final doc = await _db.collection('villas').doc(villaId).get();

      if (!doc.exists) {
        errorMessage.value = 'Data villa tidak ditemukan';
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      // --- Teks ---
      nameController.text = (data['name'] ?? '') as String;
      locationController.text = (data['location'] ?? '') as String;

      // --- max_person: bisa num atau String ---
      final dynamic maxRaw = data['max_person'];
      int maxPerson = 0;
      if (maxRaw is num) {
        maxPerson = maxRaw.toInt();
      } else if (maxRaw is String && maxRaw.trim().isNotEmpty) {
        maxPerson = int.tryParse(maxRaw.trim()) ?? 0;
      }
      maxPersonController.text =
          maxPerson > 0 ? maxPerson.toString() : '';

      // --- weekday_price: bisa num atau String ---
      final dynamic weekdayRaw = data['weekday_price'];
      num weekday = 0;
      if (weekdayRaw is num) {
        weekday = weekdayRaw;
      } else if (weekdayRaw is String && weekdayRaw.trim().isNotEmpty) {
        weekday = int.tryParse(weekdayRaw.trim()) ?? 0;
      }
      weekdayPriceController.text = weekday.toString();

      // --- weekend_price: bisa num atau String ---
      final dynamic weekendRaw = data['weekend_price'];
      num weekend = 0;
      if (weekendRaw is num) {
        weekend = weekendRaw;
      } else if (weekendRaw is String && weekendRaw.trim().isNotEmpty) {
        weekend = int.tryParse(weekendRaw.trim()) ?? 0;
      }
      weekendPriceController.text = weekend.toString();

      // --- owner_id ---
      ownerIdController.text = (data['owner_id'] ?? '') as String;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------
  // SIMPAN PERUBAHAN KE FIRESTORE
  // ----------------------------
  Future<void> saveChanges() async {
    try {
      isSaving.value = true;
      errorMessage.value = '';

      final String name = nameController.text.trim();
      final String location = locationController.text.trim();
      final String maxPersonText = maxPersonController.text.trim();
      final String weekdayText = weekdayPriceController.text.trim();
      final String weekendText = weekendPriceController.text.trim();
      final String ownerId = ownerIdController.text.trim();

      final int maxPerson = int.tryParse(maxPersonText) ?? 0;
      final int weekdayPrice = int.tryParse(weekdayText) ?? 0;
      final int weekendPrice = int.tryParse(weekendText) ?? 0;

      await _db.collection('villas').doc(villaId).update({
        'name': name,
        'location': location,
        'max_person': maxPerson,
        'weekday_price': weekdayPrice,
        'weekend_price': weekendPrice,
        'owner_id': ownerId,
      });

      Get.back(result: true);
      Get.snackbar(
        'Berhasil',
        'Data villa berhasil disimpan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    locationController.dispose();
    maxPersonController.dispose();
    weekdayPriceController.dispose();
    weekendPriceController.dispose();
    ownerIdController.dispose();
    super.onClose();
  }
}
