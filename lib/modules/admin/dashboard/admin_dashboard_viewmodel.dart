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

  /// Ambil semua statistik dashboard + list villa
  Future<void> loadDashboardStats() async {
    try {
      // ===== 1. HITUNG DATA VILLA =====
      final villasSnap =
          await FirebaseFirestore.instance.collection('villas').get();
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

      // ===== 2. HITUNG TOTAL PESANAN =====
      final bookingsSnap =
          await FirebaseFirestore.instance.collection('bookings').get();
      totalPesanan.value = bookingsSnap.size;

      // ===== 3. HITUNG RESCHEDULE =====
      final rescheduleSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('status', isEqualTo: 'reschedule')
          .get();
      totalReschedule.value = rescheduleSnap.size;

      // ===== 4. HITUNG PENDAPATAN & PER OWNER =====
      double total = 0;
      final Map<String, double> tempOwnerMap = {};

      for (final doc in bookingsSnap.docs) {
        final data = doc.data();
        final amount = (data['total_amount'] ?? 0).toDouble();
        total += amount;

        // ambil owner_id dari booking (misal "owner_1")
        final ownerCode = (data['owner_id'] ?? '').toString();
        if (ownerCode.isNotEmpty) {
          final ownerShare = amount * 0.90; // 90% untuk owner
          tempOwnerMap[ownerCode] =
              (tempOwnerMap[ownerCode] ?? 0) + ownerShare;
        }
      }

      totalPendapatan.value = total;
      pendapatanAdmin.value = total * 0.10;
      pendapatanOwner.value = total * 0.90;

      ownerPendapatanMap.assignAll(tempOwnerMap);
    } catch (e) {
      debugPrint('Error loadDashboardStats: $e');
    }
  }

  /// Mengambil Nama Villa dan Pemilik berdasarkan ID Villa
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
