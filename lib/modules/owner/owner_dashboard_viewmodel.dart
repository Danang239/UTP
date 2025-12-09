import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utp_flutter/app_session.dart';

class OwnerDashboardViewModel extends GetxController {
  // Profil owner
  final name = ''.obs;
  final email = ''.obs;
  final ownerCode = ''.obs; // contoh: "owner_1"

  // Statistik atas (sesuai desain kamu)
  final totalPendapatanOwner = 0.0.obs;       // total pendapatan bulan ini (90%)
  final totalBookingBulanIni = 0.obs;         // jumlah booking bulan ini
  final totalVillaTerdaftar = 0.obs;          // berapa villa milik owner ini

  // Date filter (awal & akhir bulan)
  final selectedStartDate = Rxn<DateTime>();
  final selectedEndDate = Rxn<DateTime>();

  // Controller text kalau nanti kamu mau pakai filter manual
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    _initDefaultDateRange();
    loadOwnerStats();
  }

  void _loadProfile() {
  name.value = AppSession.name ?? 'Owner';
  email.value = AppSession.email ?? '-';
  ownerCode.value = AppSession.ownerId ?? ''; // <-- "owner_1" dari AppSession
}


  void _initDefaultDateRange() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final nextMonth = (now.month == 12)
        ? DateTime(now.year + 1, 1, 1)
        : DateTime(now.year, now.month + 1, 1);

    selectedStartDate.value = firstDay;
    selectedEndDate.value = nextMonth.subtract(const Duration(days: 1));

    startDateController.text =
        '${firstDay.day}-${firstDay.month}-${firstDay.year}';
    endDateController.text =
        '${selectedEndDate.value!.day}-${selectedEndDate.value!.month}-${selectedEndDate.value!.year}';
  }

  Future<void> loadOwnerStats() async {
    try {
      final code = ownerCode.value; // "owner_1"
      if (code.isEmpty) {
        debugPrint('Owner code kosong, pastikan owner_id di users terisi.');
        return;
      }

      // ================== 1. HITUNG JUMLAH VILLA MILIK OWNER ==================
      final villasSnap = await FirebaseFirestore.instance
          .collection('villas')
          .where('ownerid', isEqualTo: code)
          .get();
      totalVillaTerdaftar.value = villasSnap.size;

      // ================== 2. BOOKING BULAN INI UNTUK OWNER INI ==================
      final start = selectedStartDate.value!;
      final end = selectedEndDate.value!;

      final bookingsSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('owner_id', isEqualTo: code)
          .where('created_at',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('created_at',
              isLessThanOrEqualTo:
                  Timestamp.fromDate(end.add(const Duration(days: 1))))
          .get();

      totalBookingBulanIni.value = bookingsSnap.size;

      // ================== 3. HITUNG TOTAL PENDAPATAN OWNER (90%) ==================
      double totalOwner = 0;
      for (final doc in bookingsSnap.docs) {
        final data = doc.data();
        final amount = (data['total_amount'] ?? 0).toDouble();
        final ownerShare = amount * 0.90; // 90% untuk owner
        totalOwner += ownerShare;
      }

      totalPendapatanOwner.value = totalOwner;
    } catch (e) {
      debugPrint('Error loadOwnerStats: $e');
    }
  }

  // nanti bisa dipakai kalau kamu mau ganti tanggal via date picker
  Future<void> pickStartDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate.value ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      selectedStartDate.value = picked;
      startDateController.text =
          '${picked.day}-${picked.month}-${picked.year}';
      await loadOwnerStats();
    }
  }

  Future<void> pickEndDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate.value ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      selectedEndDate.value = picked;
      endDateController.text =
          '${picked.day}-${picked.month}-${picked.year}';
      await loadOwnerStats();
    }
  }
}
