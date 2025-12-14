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
  final DateTime? createdAt; // ✅ tanggal pesan (created_at)
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

  final totalAdminIncome = 0.obs; // confirmed & periode
  final totalOwnerIncome = 0.obs; // confirmed & periode
  final totalRevenue = 0.obs; // confirmed & periode

  // ✅ Filter Bulan/Tahun
  final selectedMonth = DateTime.now().month.obs; // 1-12
  final selectedYear = DateTime.now().year.obs;

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  void setMonthYear({required int month, required int year}) {
    selectedMonth.value = month;
    selectedYear.value = year;
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

  DateTime _startOfMonth(int year, int month) => DateTime(year, month, 1);
  DateTime _startOfNextMonth(int year, int month) => DateTime(year, month + 1, 1);

  Future<void> loadBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final int m = selectedMonth.value;
      final int y = selectedYear.value;

      final DateTime from = _startOfMonth(y, m);
      final DateTime to = _startOfNextMonth(y, m);

      final Timestamp fromTs = Timestamp.fromDate(from);
      final Timestamp toTs = Timestamp.fromDate(to);

      // ✅ ambil booking sesuai periode (created_at)
      final snap = await _db
          .collection('bookings')
          .where('created_at', isGreaterThanOrEqualTo: fromTs)
          .where('created_at', isLessThan: toTs)
          .orderBy('created_at', descending: true)
          .get();

      final Map<String, String> userNameCache = {};
      final List<AdminBookingItem> items = [];
      for (final doc in snap.docs) {
        items.add(await _mapBookingDoc(doc, userNameCache));
      }

      bookings.assignAll(items);

      // hitung pendapatan dari list yang sudah difilter
      calculateIncomeFromLoadedList();
    } catch (e, st) {
      // ignore: avoid_print
      print('ERROR loadBookings: $e\n$st');
      errorMessage.value = e.toString();
      bookings.clear();
      totalAdminIncome.value = 0;
      totalOwnerIncome.value = 0;
      totalRevenue.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<AdminBookingItem> _mapBookingDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, String> userNameCache,
  ) async {
    final data = doc.data();

    final String userId = (data['user_id'] ?? '').toString();
    String customerName = (data['customer_name'] ?? '').toString();

    if (customerName.trim().isEmpty && userId.isNotEmpty) {
      if (userNameCache.containsKey(userId)) {
        customerName = userNameCache[userId]!;
      } else {
        final userDoc = await _db.collection('users').doc(userId).get();
        if (userDoc.exists) {
          customerName = (userDoc.data()?['name'] ?? '-').toString();
          userNameCache[userId] = customerName;
        } else {
          customerName = '-';
        }
      }
    }
    if (customerName.trim().isEmpty) customerName = '-';

    final String customerEmail = (data['customer_email'] ?? '-').toString();
    final String customerPhone = (data['customer_phone'] ?? '-').toString();

    final String villaId = (data['villa_id'] ?? '').toString();
    final String villaName = (data['villa_name'] ?? '-').toString();
    final String villaLocation = (data['villa_location'] ?? '-').toString();
    final String ownerId = (data['owner_id'] ?? '').toString();

    final String paymentMethod = (data['payment_method'] ?? '-').toString();
    final String bank = (data['bank'] ?? '-').toString();

    final int totalPrice = _numToInt(data['total_price']);
    final int adminFee = _numToInt(data['admin_fee']);
    final int ownerIncome = _numToInt(data['owner_income']);

    final String paymentStatus =
        (data['payment_status'] ?? 'waiting_verification').toString();
    final String status = (data['status'] ?? 'pending').toString();

    final bool hasPaymentProof = (data['has_payment_proof'] ?? false) == true;
    final String? proofFileName = data['payment_proof_file_name']?.toString();
    final String? proofUrl = data['payment_proof_url']?.toString();

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
      createdAt: _tsToDate(data['created_at']), // ✅ tanggal pesan
      paymentMethod: paymentMethod,
      bank: bank,
      totalPrice: totalPrice,
      adminFee: adminFee,
      ownerIncome: ownerIncome,
      paymentStatus: paymentStatus,
      status: status,
      hasPaymentProof: hasPaymentProof,
      paymentProofUrl: proofUrl,
      paymentProofFileName: proofFileName,
    );
  }

  // ✅ hitung dari list yang sudah difilter bulan + hanya confirmed
  void calculateIncomeFromLoadedList() {
    int adminIncome = 0;
    int ownerIncome = 0;
    int revenue = 0;

    for (final b in bookings) {
      if (b.status != 'confirmed') continue;
      adminIncome += b.adminFee;
      ownerIncome += b.ownerIncome;
      revenue += b.totalPrice;
    }

    totalAdminIncome.value = adminIncome;
    totalOwnerIncome.value = ownerIncome;
    totalRevenue.value = revenue;
  }

  Future<void> refresh() async {
    await loadBookings();
  }

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
      // ignore: avoid_print
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
      // ignore: avoid_print
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
