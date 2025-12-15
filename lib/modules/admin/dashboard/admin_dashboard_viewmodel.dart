import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔥 TAMBAHAN (AMAN)
import 'package:utp_flutter/app_session.dart';
import 'package:utp_flutter/app/routes/app_routes.dart';

// ✅ Booking & Payment VM (TIDAK DIUBAH)
import '../booking_payment/admin_booking_payment_viewmodel.dart';

class AdminDashboardViewModel extends GetxController {
  // =========================
  // PROFIL ADMIN
  // =========================
  final name = ''.obs;
  final email = ''.obs;

  // =========================
  // SEARCH
  // =========================
  final searchController = TextEditingController();
  final searchText = ''.obs;

  // =========================
  // SIDEBAR MENU
  // =========================
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

  // =========================
  // STATISTIK
  // =========================
  final totalVilla = 0.obs;
  final totalPesanan = 0.obs;
  final totalReschedule = 0.obs;

  // =========================
  // DATA VILLA
  // =========================
  final villas = <Map<String, dynamic>>[].obs;

  // =========================
  // PENDAPATAN
  // =========================
  final totalPendapatan = 0.0.obs;
  final pendapatanAdmin = 0.0.obs;
  final pendapatanOwner = 0.0.obs;
  final ownerPendapatanMap = <String, double>{}.obs;

  // =========================
  // FILTER BULAN & TAHUN
  // =========================
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  // =========================
  // INIT
  // =========================
  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    loadDashboardStats();
    _syncPeriodToBookingVM();
  }

  // =========================
  // LOAD PROFILE
  // =========================
  void _loadProfile() {
    name.value = AppSession.name ?? 'Admin Stay&Co';
    email.value = AppSession.email ?? '-';
  }

  // =========================
  // SIDEBAR
  // =========================
  void selectMenu(int index) {
    selectedMenuIndex.value = index;
  }

  String get currentMenuTitle => menuItems[selectedMenuIndex.value];

  // =========================
  // SEARCH
  // =========================
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

  // =========================
  // SYNC PERIOD TO BOOKING VM
  // =========================
  void _syncPeriodToBookingVM() {
    try {
      if (Get.isRegistered<AdminBookingPaymentViewModel>()) {
        final bookingVM = Get.find<AdminBookingPaymentViewModel>();
        bookingVM.setMonthYear(
          month: selectedMonth.value,
          year: selectedYear.value,
        );
      }
    } catch (_) {}
  }

  void setMonthYear({required int month, required int year}) {
    selectedMonth.value = month;
    selectedYear.value = year;
    loadDashboardStats();
    _syncPeriodToBookingVM();
  }

  DateTime _startOfMonth(int year, int month) => DateTime(year, month, 1);
  DateTime _startOfNextMonth(int year, int month) =>
      DateTime(year, month + 1, 1);

  // =========================
  // LOAD DASHBOARD STATS
  // =========================
  Future<void> loadDashboardStats() async {
    try {
      // ----- VILLA -----
      final villasSnap =
          await FirebaseFirestore.instance.collection('villas').get();
      totalVilla.value = villasSnap.size;

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

      // ----- BOOKING -----
      final from = _startOfMonth(selectedYear.value, selectedMonth.value);
      final to = _startOfNextMonth(selectedYear.value, selectedMonth.value);

      final bookingsSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('created_at',
              isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('created_at', isLessThan: Timestamp.fromDate(to))
          .get();

      totalPesanan.value = bookingsSnap.size;

      int rescheduleCount = 0;
      double total = 0;
      double adminFeeTotal = 0;
      final Map<String, double> tempOwnerMap = {};

      for (final doc in bookingsSnap.docs) {
        final data = doc.data();
        if ((data['status'] ?? '') == 'reschedule') rescheduleCount++;

        final amount = (data['total_price'] ?? 0).toDouble();
        final adminFee = (data['admin_fee'] ?? 0).toDouble();

        total += amount;
        adminFeeTotal += adminFee;

        final ownerId = data['owner_id'] ?? '';
        if (ownerId.toString().isNotEmpty) {
          tempOwnerMap[ownerId] =
              (tempOwnerMap[ownerId] ?? 0) + (amount * 0.9);
        }
      }

      totalReschedule.value = rescheduleCount;
      totalPendapatan.value = total;
      pendapatanAdmin.value = adminFeeTotal;
      pendapatanOwner.value = total * 0.9;
      ownerPendapatanMap.assignAll(tempOwnerMap);
    } catch (e) {
      debugPrint('Error loadDashboardStats: $e');
    }
  }

  // =========================
  // DETAIL VILLA
  // =========================
  Future<Map<String, String>> getVillaDetails(String villaId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('villas')
          .doc(villaId)
          .get();

      if (!snap.exists) return {'villaName': 'N/A', 'ownerName': 'N/A'};

      final data = snap.data()!;
      return {
        'villaName': data['name'] ?? 'Unknown',
        'ownerName': data['owner_name'] ?? 'Unknown',
      };
    } catch (_) {
      return {'villaName': 'Error', 'ownerName': 'Error'};
    }
  }

  // =====================================================
  // 🔥 LOGOUT (DITAMBAHKAN – AMAN)
  // =====================================================
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await AppSession.clear();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
