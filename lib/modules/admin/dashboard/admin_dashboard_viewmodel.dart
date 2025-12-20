import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:utp_flutter/app_session.dart';
import 'package:utp_flutter/app/routes/app_routes.dart';

// ✅ Booking & Payment VM
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
  // PENDAPATAN (CONFIRMED ONLY)
  // =========================
  final totalPendapatan = 0.0.obs; // total revenue confirmed
  final pendapatanAdmin = 0.0.obs; // sum admin_fee confirmed
  final pendapatanOwner = 0.0.obs; // sum owner_income confirmed
  final ownerPendapatanMap = <String, double>{}.obs; // sum owner_income per owner (confirmed)

  // =========================
  // FILTER BULAN & TAHUN
  // =========================
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    loadDashboardStats();
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
  DateTime _startOfNextMonth(int year, int month) => DateTime(year, month + 1, 1);

  int _numToInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // =========================
  // LOAD DASHBOARD STATS
  // =========================
  Future<void> loadDashboardStats() async {
    try {
      // ----- VILLA -----
      final villasSnap = await FirebaseFirestore.instance.collection('villas').get();
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

      // ----- BOOKING (PERIODE) -----
      final from = _startOfMonth(selectedYear.value, selectedMonth.value);
      final to = _startOfNextMonth(selectedYear.value, selectedMonth.value);

      final bookingsSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('created_at', isLessThan: Timestamp.fromDate(to))
          .get();

      totalPesanan.value = bookingsSnap.size;

      int rescheduleCount = 0;

      // ✅ CONFIRMED totals
      double confirmedRevenue = 0;
      double adminFeeTotal = 0;
      double ownerIncomeTotal = 0;

      final Map<String, double> tempOwnerMap = {};

      for (final doc in bookingsSnap.docs) {
        final data = doc.data();

        final status = (data['status'] ?? '').toString().toLowerCase();
        if (status == 'reschedule') rescheduleCount++;

        // ✅ hanya confirmed yang masuk pendapatan
        if (status != 'confirmed') continue;

        final int totalPrice = _numToInt(data['total_price']);
        final int adminFee = _numToInt(data['admin_fee']);
        int ownerIncome = _numToInt(data['owner_income']);

        // fallback kalau data lama belum ada owner_income
        if (ownerIncome <= 0) {
          ownerIncome = (totalPrice * 0.90).round();
        }

        confirmedRevenue += totalPrice.toDouble();
        adminFeeTotal += adminFee.toDouble();
        ownerIncomeTotal += ownerIncome.toDouble();

        final ownerId = (data['owner_id'] ?? '').toString();
        if (ownerId.isNotEmpty) {
          tempOwnerMap[ownerId] = (tempOwnerMap[ownerId] ?? 0) + ownerIncome.toDouble();
        }
      }

      totalReschedule.value = rescheduleCount;

      totalPendapatan.value = confirmedRevenue;
      pendapatanAdmin.value = adminFeeTotal;
      pendapatanOwner.value = ownerIncomeTotal;
      ownerPendapatanMap.assignAll(tempOwnerMap);
    } catch (e) {
      debugPrint('Error loadDashboardStats: $e');
    }
  }

  Future<Map<String, String>> getVillaDetails(String villaId) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('villas').doc(villaId).get();
      if (!snap.exists) return {'villaName': 'N/A', 'ownerName': 'N/A'};

      final data = snap.data()!;
      return {
        'villaName': (data['name'] ?? 'Unknown').toString(),
        'ownerName': (data['owner_name'] ?? 'Unknown').toString(),
      };
    } catch (_) {
      return {'villaName': 'Error', 'ownerName': 'Error'};
    }
  }

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