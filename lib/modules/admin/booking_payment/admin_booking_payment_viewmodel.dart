import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminBookingItem {
  final String id;
  final String userId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String villaId;
  final String villaName;
  final String villaLocation;
  final String ownerId;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String paymentMethod; // "transfer" / "qris"
  final String bank; // "BRI" / "BCA" / "OVO" / dll
  final int totalPrice;
  final int adminFee;
  final int ownerIncome;
  final String paymentStatus; // "waiting_verification" / ...
  final String status; // "pending" / "confirmed"
  final DateTime? createdAt;
  final bool hasPaymentProof;
  final String? paymentProofUrl;
  final String? paymentProofFileName;

  AdminBookingItem({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.villaId,
    required this.villaName,
    required this.villaLocation,
    required this.ownerId,
    required this.checkIn,
    required this.checkOut,
    required this.paymentMethod,
    required this.bank,
    required this.totalPrice,
    required this.adminFee,
    required this.ownerIncome,
    required this.paymentStatus,
    required this.status,
    required this.createdAt,
    required this.hasPaymentProof,
    required this.paymentProofUrl,
    required this.paymentProofFileName,
  });

  String get bankOrWallet => bank;

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get canConfirm => isPending && hasPaymentProof;
}

class AdminBookingPaymentViewModel extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final bookings = <AdminBookingItem>[].obs;
  final errorMessage = ''.obs;
  final totalAdminIncome = 0.obs; // Pendapatan Admin
  final totalOwnerIncome = 0.obs; // Pendapatan Owner
  final totalRevenue = 0.obs; // Total Omset Bulanan

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  int _numToInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  DateTime? _tsToDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return null;
  }

  Future<void> loadBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snap = await _db
          .collection('bookings')
          .orderBy('created_at', descending: true)
          .get();

      final Map<String, String> userNameCache = {};
      final List<AdminBookingItem> items = [];
      for (final doc in snap.docs) {
        items.add(await _mapBookingDoc(doc, userNameCache));
      }

      bookings.assignAll(items);
      calculateIncome(); // update pendapatan & omset setelah data booking dimuat
    } catch (e, st) {
      print('ERROR loadBookings: $e\n$st');
      errorMessage.value = e.toString();
      bookings.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<AdminBookingItem> _mapBookingDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, String> userNameCache,
  ) async {
    final data = doc.data();

    final String userId = (data['user_id'] ?? '') as String;
    String customerName = (data['customer_name'] ?? '') as String;

    if (customerName.trim().isEmpty && userId.isNotEmpty) {
      if (userNameCache.containsKey(userId)) {
        customerName = userNameCache[userId]!;
      } else {
        final userDoc = await _db.collection('users').doc(userId).get();
        if (userDoc.exists) {
          customerName = (userDoc.data()?['name'] ?? '-') as String;
          userNameCache[userId] = customerName;
        } else {
          customerName = '-';
        }
      }
    }
    if (customerName.trim().isEmpty) customerName = '-';

    final String customerEmail = (data['customer_email'] ?? '-') as String;
    final String customerPhone = (data['customer_phone'] ?? '-') as String;

    final String villaId = (data['villa_id'] ?? '') as String;
    final String villaName = (data['villa_name'] ?? '-') as String;
    final String villaLocation = (data['villa_location'] ?? '-') as String;
    final String ownerId = (data['owner_id'] ?? '') as String;

    final String paymentMethod = (data['payment_method'] ?? '-') as String;
    final String bank = (data['bank'] ?? '-') as String;

    final int totalPrice = _numToInt(data['total_price']);
    final int adminFee = _numToInt(data['admin_fee']);
    final int ownerIncome = _numToInt(data['owner_income']);

    final String paymentStatus =
        (data['payment_status'] ?? 'waiting_verification') as String;
    final String status = (data['status'] ?? 'pending') as String;

    final bool hasPaymentProof = (data['has_payment_proof'] ?? false) as bool;
    final String? proofFileName = data['payment_proof_file_name'] as String?;
    final String? proofUrl = data['payment_proof_url'] as String?;

    return AdminBookingItem(
      id: doc.id,
      userId: userId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      villaId: villaId,
      villaName: villaName,
      villaLocation: villaLocation,
      ownerId: ownerId,
      checkIn: _tsToDate(data['check_in']),
      checkOut: _tsToDate(data['check_out']),
      createdAt: _tsToDate(data['created_at']),
      paymentMethod: paymentMethod,
      bank: bank,
      totalPrice: totalPrice,
      adminFee: adminFee,
      ownerIncome: ownerIncome,
      paymentStatus: paymentStatus,
      status: status,
      hasPaymentProof: hasPaymentProof,
      paymentProofUrl: proofUrl ?? '',
      paymentProofFileName: proofFileName ?? '',
    );
  }

  /// Method untuk menghitung total pendapatan admin, owner, dan omset
  /// ✅ SEKARANG: hanya hitung booking yang status-nya CONFIRMED
  Future<void> calculateIncome() async {
    try {
      final snap = await _db.collection('bookings').get();
      int adminIncome = 0;
      int ownerIncome = 0;
      int revenue = 0;

      for (final doc in snap.docs) {
        final data = doc.data();

        // ✅ FILTER: hanya confirmed yang dihitung
        final status = (data['status'] ?? '').toString();
        if (status != 'confirmed') continue;

        adminIncome += _numToInt(data['admin_fee']);
        ownerIncome += _numToInt(data['owner_income']);
        revenue += _numToInt(data['total_price']);
      }

      totalAdminIncome.value = adminIncome;
      totalOwnerIncome.value = ownerIncome;
      totalRevenue.value = revenue;
    } catch (e) {
      print('ERROR calculateIncome: $e');
    }
  }

  /// dipanggil dari tombol REFRESH di halaman
  Future<void> refresh() async {
    await loadBookings();
  }

  /// 🔥 KONFIRMASI BOOKING
  Future<void> confirmBooking(AdminBookingItem booking) async {
    try {
      isLoading.value = true;

      final int total = booking.totalPrice;
      final int adminFee = (total * 0.10).round();
      final int ownerIncome = total - adminFee;

      await _db.collection('bookings').doc(booking.id).update({
        'status': 'confirmed',
        'payment_status': 'paid',
        'admin_fee': adminFee,
        'owner_income': ownerIncome,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await loadBookings();
    } catch (e, st) {
      print('ERROR confirmBooking: $e\n$st');
      Get.snackbar(
        'Gagal',
        'Gagal mengkonfirmasi booking: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Batalkan konfirmasi: status jadi pending lagi + reset uang
  Future<void> setPending(AdminBookingItem booking) async {
    try {
      isLoading.value = true;

      await _db.collection('bookings').doc(booking.id).update({
        'status': 'pending',
        'payment_status': 'waiting_verification',
        'admin_fee': 0,
        'owner_income': 0,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await loadBookings();
    } catch (e, st) {
      print('ERROR setPending: $e\n$st');
      Get.snackbar(
        'Gagal',
        'Gagal membatalkan konfirmasi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
