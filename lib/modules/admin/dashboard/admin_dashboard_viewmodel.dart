import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utp_flutter/app_session.dart';

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
  ].obs;

  final selectedMenuIndex = 0.obs;

  // Statistik utama
  final totalVilla = 0.obs;
  final totalPesanan = 0.obs;
  final totalReschedule = 0.obs;

  // 🔥 LIST DATA VILLA UNTUK HALAMAN "DATA VILLA"
  final villas = <Map<String, dynamic>>[].obs;

  // Pendapatan
  final totalPendapatan = 0.0.obs;      // total semua (100%)
  final pendapatanAdmin = 0.0.obs;      // 10% (platform)
  final pendapatanOwner = 0.0.obs;      // 90% (semua owner)
  final ownerPendapatanMap = <String, double>{}.obs; // per owner_id

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    loadDashboardStats();
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

  Future<void> loadDashboardStats() async {
    try {
      // ===== HITUNG DATA VILLA =====
      final villasSnap = await FirebaseFirestore.instance.collection('villas').get();
      totalVilla.value = villasSnap.size;

      // ===== HITUNG TOTAL PESANAN =====
      final bookingsSnap = await FirebaseFirestore.instance.collection('bookings').get();
      totalPesanan.value = bookingsSnap.size;

      // ===== HITUNG RESCHEDULE =====
      final rescheduleSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('status', isEqualTo: 'reschedule')
          .get();
      totalReschedule.value = rescheduleSnap.size;

      // ===== HITUNG PENDAPATAN & PER OWNER =====
      double total = 0;
      double totalAdminFee = 0; // Total Admin Fee
      final Map<String, double> tempOwnerMap = {};

      for (final doc in bookingsSnap.docs) {
        final data = doc.data();
        final amount = (data['total_price'] ?? 0).toDouble();  // Ubah total_amount ke total_price
        final adminFee = (data['admin_fee'] ?? 0).toDouble();  // Admin Fee per booking
        total += amount;
        totalAdminFee += adminFee;

        // Ambil owner_id dari booking
        final ownerCode = (data['owner_id'] ?? '').toString();
        if (ownerCode.isNotEmpty) {
          final ownerShare = amount * 0.90; // 90% untuk owner
          tempOwnerMap[ownerCode] = (tempOwnerMap[ownerCode] ?? 0) + ownerShare;
        }
      }

      // Update values
      totalPendapatan.value = total;
      pendapatanAdmin.value = totalAdminFee;  // Gunakan admin fee untuk total pendapatan admin
      pendapatanOwner.value = total * 0.90;  // Total pendapatan untuk owner
      ownerPendapatanMap.assignAll(tempOwnerMap); // Pendapatan per owner

    } catch (e) {
      debugPrint('Error loadDashboardStats: $e');
    }
  }

  // Mengambil Nama Villa dan Pemilik berdasarkan ID Villa
  Future<Map<String, String>> getVillaDetails(String villaId) async {
    try {
      DocumentSnapshot villaSnapshot = await FirebaseFirestore.instance
          .collection('villas')
          .doc(villaId)
          .get();
      
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
