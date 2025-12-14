import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utp_flutter/app_session.dart';

// ✅ TAMBAHAN: import Booking VM supaya bisa ikut diset periodenya
// GANTI PATH ini kalau lokasi file kamu beda:
import '../booking_payment/admin_booking_payment_viewmodel.dart';


class AdminDashboardViewModel extends GetxController {
  // Profil admin
  final name = ''.obs;
  final email = ''.obs;

  // Search bar
  final searchController = TextEditingController();
  final searchText = ''.obs;

  // Sidebar menu (Booking & Pembayaran digabung)
  final menuItems = <String>[
    'Dashboard',
    'Data Villa',
    'Data User',
    'Booking & Pembayaran',
    'Pesan',
    'Bikin Akun Owner',
    'Bikin Akun Owner',
  ].obs;

  final selectedMenuIndex = 0.obs;

  // Statistik utama
  final totalVilla = 0.obs;
  final totalPesanan = 0.obs;
  final totalReschedule = 0.obs;

  // LIST DATA VILLA UNTUK HALAMAN "DATA VILLA"
  final villas = <Map<String, dynamic>>[].obs;

  // Pendapatan
  final totalPendapatan = 0.0.obs; // total semua (100%) => total_price
  final pendapatanAdmin = 0.0.obs; // total admin_fee
  final pendapatanOwner = 0.0.obs; // total owner (90%)
  final ownerPendapatanMap = <String, double>{}.obs; // per owner_id

  // FILTER BULAN & TAHUN (DINAMIS)
  final selectedMonth = DateTime.now().month.obs; // 1-12
  final selectedYear = DateTime.now().year.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    loadDashboardStats(); // default: bulan & tahun saat ini

    // ✅ TAMBAHAN: sinkronkan periode awal ke Booking VM (kalau sudah ada)
    _syncPeriodToBookingVM();
  }

  void _loadProfile() {
    name.value = AppSession.name ?? 'Admin Stay&Co';
    email.value = AppSession.email ?? '-';
  }

  void selectMenu(int index) {
    selectedMenuIndex.value = index;
  }

  String get currentMenuTitle => menuItems[selectedMenuIndex.value];

  void onSearchSubmitted(String value) {
    searchText.value = value.trim();
    if (searchText.value.isNotEmpty) {
      Get.snackbar(
        'Search',
        'Kamu mencari: "${searchText.value}"',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ✅ TAMBAHAN: helper untuk sync periode ke BookingPayment VM
  void _syncPeriodToBookingVM() {
    try {
      if (Get.isRegistered<AdminBookingPaymentViewModel>()) {
        final bookingVM = Get.find<AdminBookingPaymentViewModel>();
        bookingVM.setMonthYear(
          month: selectedMonth.value,
          year: selectedYear.value,
        );
      }
    } catch (_) {
      // biarkan saja kalau belum ada / path import beda
    }
  }

  // ganti bulan/tahun lalu reload
  void setMonthYear({required int month, required int year}) {
    selectedMonth.value = month; // 1-12
    selectedYear.value = year; // contoh 2026

    // ✅ reload dashboard
    loadDashboardStats();

    // ✅ TAMBAHAN: ikut ubah periode Booking & Pembayaran
    _syncPeriodToBookingVM();
  }

  // helper range bulan
  DateTime _startOfMonth(int year, int month) => DateTime(year, month, 1);
  DateTime _startOfNextMonth(int year, int month) => DateTime(year, month + 1, 1);

  Future<void> loadDashboardStats() async {
    try {
      // ===== DATA VILLA =====
      final villasSnap = await FirebaseFirestore.instance.collection('villas').get();
      totalVilla.value = villasSnap.size;

      // simpan list villa untuk halaman "Data Villa"
      final List<Map<String, dynamic>> villaList = [];
      for (final doc in villasSnap.docs) {
        final data = doc.data();
        villaList.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          'location': data['location'] ?? '',
          'weekdayPrice': (data['weekday_price'] ?? 0).toDouble(),
          'weekendPrice': (data['weekend_price'] ?? 0).toDouble(),
          'capacity': data['capacity'] ?? 0,
        });
      }
      villas.assignAll(villaList);

      // ===== FILTER booking berdasarkan bulan & tahun terpilih (created_at) =====
      final int m = selectedMonth.value;
      final int y = selectedYear.value;

      final DateTime from = _startOfMonth(y, m);
      final DateTime to = _startOfNextMonth(y, m);

      final Timestamp fromTs = Timestamp.fromDate(from);
      final Timestamp toTs = Timestamp.fromDate(to);

      // ===== AMBIL SEMUA BOOKING DI BULAN TERPILIH =====
      final bookingsSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('created_at', isGreaterThanOrEqualTo: fromTs)
          .where('created_at', isLessThan: toTs)
          .get();

      totalPesanan.value = bookingsSnap.size;

      // ===== RESCHEDULE (TANPA QUERY BARU, BIAR TIDAK BUTUH INDEX) =====
      int rescheduleCount = 0;

      // ===== HITUNG PENDAPATAN & PER OWNER =====
      double total = 0;
      double totalAdminFee = 0;
      final Map<String, double> tempOwnerMap = {};

      for (final doc in bookingsSnap.docs) {
        final data = doc.data();

        // hitung reschedule dari data yang sama
        final status = (data['status'] ?? '').toString().toLowerCase();
        if (status == 'reschedule') rescheduleCount++;

        final double amount = (data['total_price'] ?? 0).toDouble();
        final double adminFee = (data['admin_fee'] ?? 0).toDouble();

        total += amount;
        totalAdminFee += adminFee;

        // Pendapatan owner = 90% dari total_price
        final ownerCode = (data['owner_id'] ?? '').toString();
        if (ownerCode.isNotEmpty) {
          final ownerShare = amount * 0.90;
          tempOwnerMap[ownerCode] = (tempOwnerMap[ownerCode] ?? 0) + ownerShare;
        }
      }

      totalReschedule.value = rescheduleCount;

      // Update values
      totalPendapatan.value = total;
      pendapatanAdmin.value = totalAdminFee;
      pendapatanOwner.value = total * 0.90;
      ownerPendapatanMap.assignAll(tempOwnerMap);
    } catch (e) {
      debugPrint('Error loadDashboardStats: $e');
    }
  }

  // Mengambil Nama Villa dan Pemilik berdasarkan ID Villa
  Future<Map<String, String>> getVillaDetails(String villaId) async {
    try {
      DocumentSnapshot villaSnapshot =
          await FirebaseFirestore.instance.collection('villas').doc(villaId).get();

      if (villaSnapshot.exists) {
        var villaData = villaSnapshot.data() as Map<String, dynamic>;
        String villaName = villaData['name'] ?? 'Unknown Villa';
        String ownerName = villaData['owner_name'] ?? 'Unknown Owner';
        return {'villaName': villaName, 'ownerName': ownerName};
      } else {
        return {'villaName': 'N/A', 'ownerName': 'N/A'};
      }
    } catch (e) {
      return {'villaName': 'Error', 'ownerName': 'Error'};
    }
  }
}
