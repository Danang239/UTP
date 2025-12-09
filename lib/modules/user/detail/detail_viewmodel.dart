import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app_session.dart';
import 'package:utp_flutter/services/user_collections.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailViewModel extends GetxController {
  final String villaId;
  final Map<String, dynamic> villaData;

  DetailViewModel(this.villaId, this.villaData);

  String get uid {
    final id = AppSession.userDocId;
    if (id == null) throw 'User belum login';
    return id;
  }
  String? get firstImageUrl {
  final dynamic rawImages = villaData['images'];

  if (rawImages is List && rawImages.isNotEmpty && rawImages.first is String) {
    return rawImages.first as String;
  } else if (rawImages is String) {
    // kalau data lama masih string tunggal
    return rawImages;
  }
  return null;
  }
  // ================== STATE SLIDER FOTO ==================
  /// index foto yang sedang aktif di PageView
  final currentImageIndex = 0.obs;

  /// controller untuk PageView foto
  late final PageController imagePageController;

  /// ambil list URL gambar dari villaData['images']
  List<String> get images {
    final raw = villaData['images'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }

  void onImagePageChanged(int index) {
    currentImageIndex.value = index;
  }

  // ================== STATE TANGGAL ==================
  final checkIn = Rxn<DateTime>();
  final checkOut = Rxn<DateTime>();

  late DateTime focusedDay;
  late DateTime firstDay;
  late DateTime lastDay;
  late DateTime todayNorm;

  // hari-hari yang sudah dibayar
  final bookedDates = <DateTime>[].obs;

  final loadingCalendar = true.obs;
  final loadingBooking = false.obs;

  @override
  void onInit() {
    super.onInit();

    // init controller untuk slider foto
    imagePageController = PageController();

    final now = DateTime.now();
    focusedDay = DateTime(now.year, now.month, now.day);
    firstDay = DateTime(now.year, now.month, now.day);
    lastDay = DateTime(now.year + 2, 12, 31);
    todayNorm = _normalize(now);

    _loadBookedDates();
  }

  @override
  void onClose() {
    // dispose controller slider foto
    imagePageController.dispose();
    super.onClose();
  }

  // ================== UTIL ==================

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  String formatDate(DateTime? date) {
    if (date == null) return 'Pilih tanggal';
    return '${date.day}/${date.month}/${date.year}';
  }

  int parsePrice(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  int calculateTotalPrice() {
    if (checkIn.value == null || checkOut.value == null) return 0;

    final int weekdayPrice = parsePrice(villaData['weekday_price']);
    final int weekendPrice = parsePrice(villaData['weekend_price']);

    DateTime day = _normalize(checkIn.value!);
    DateTime last = _normalize(checkOut.value!);

    // kalau check-in == check-out → tetap hitung 1 malam
    if (!day.isBefore(last)) {
      final bool isWeekend =
          day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
      return isWeekend ? weekendPrice : weekdayPrice;
    }

    int total = 0;
    while (day.isBefore(last)) {
      final bool isWeekend =
          day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
      total += isWeekend ? weekendPrice : weekdayPrice;
      day = day.add(const Duration(days: 1));
    }

    return total;
  }

  bool isBooked(DateTime day) {
    final d = _normalize(day);
    return bookedDates.any((e) => _normalize(e) == d);
  }

  bool isSelected(DateTime day) {
    final d = _normalize(day);
    return (checkIn.value != null && _normalize(checkIn.value!) == d) ||
        (checkOut.value != null && _normalize(checkOut.value!) == d);
  }

  bool isInSelectedRange(DateTime day) {
    if (checkIn.value == null || checkOut.value == null) return false;
    final d = _normalize(day);
    final start = _normalize(checkIn.value!);
    final end = _normalize(checkOut.value!);
    return d.isAfter(start) && d.isBefore(end);
  }

  // ================== LOAD BOOKED DATES ==================

  Future<void> _loadBookedDates() async {
    try {
      loadingCalendar.value = true;

      final snap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('villa_id', isEqualTo: villaId)
          .get();

      final List<DateTime> booked = [];

      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = (data['status'] ?? '').toString();

        if (status != 'paid') continue;

        final checkInRaw = data['check_in'];
        final checkOutRaw = data['check_out'];

        if (checkInRaw is! Timestamp || checkOutRaw is! Timestamp) continue;

        final checkInTs = checkInRaw;
        final checkOutTs = checkOutRaw;

        DateTime day = _normalize(checkInTs.toDate());
        final last = _normalize(checkOutTs.toDate());

        while (day.isBefore(last)) {
          booked.add(day);
          day = day.add(const Duration(days: 1));
        }
      }

      bookedDates.assignAll(booked);
    } finally {
      loadingCalendar.value = false;
    }
  }

  // ================== PILIH TANGGAL DI KALENDER ==================

  void onSelectDay(DateTime day, BuildContext context) {
    final normalizedDay = _normalize(day);

    // tidak boleh pilih hari lampau
    if (normalizedDay.isBefore(todayNorm)) return;

    // CASE 1: belum punya check-in / sudah lengkap → mulai baru
    if (checkIn.value == null ||
        (checkIn.value != null && checkOut.value != null)) {
      if (isBooked(normalizedDay)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tanggal ini sudah dibooking, tidak bisa untuk check-in.',
            ),
          ),
        );
        return;
      }
      checkIn.value = normalizedDay;
      checkOut.value = null;
      return;
    }

    // CASE 2: sudah ada check-in, belum ada check-out
    if (checkIn.value != null && checkOut.value == null) {
      if (normalizedDay.isBefore(checkIn.value!)) {
        if (isBooked(normalizedDay)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tanggal ini sudah dibooking, tidak bisa untuk check-in.',
              ),
            ),
          );
          return;
        }
        checkIn.value = normalizedDay;
        checkOut.value = null;
        return;
      }

      // cek apakah di tengah range [checkIn, day) ada tanggal booked
      DateTime cursor = _normalize(checkIn.value!);
      bool hasBooked = false;

      while (cursor.isBefore(normalizedDay)) {
        if (isBooked(cursor)) {
          hasBooked = true;
          break;
        }
        cursor = cursor.add(const Duration(days: 1));
      }

      if (hasBooked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Range tanggal ini melewati tanggal yang sudah dibooking. Silakan pilih range lain.',
            ),
          ),
        );
        return;
      }

      checkOut.value = normalizedDay;
    }
  }

  void onPageChanged(DateTime newFocused) {
    focusedDay = newFocused;
  }

  // ================== CEK RANGE KE FIRESTORE ==================

  Future<bool> isDateRangeAvailable() async {
    if (checkIn.value == null || checkOut.value == null) return false;

    final DateTime start = _normalize(checkIn.value!);
    final DateTime end = _normalize(checkOut.value!);

    final snap = await FirebaseFirestore.instance
        .collection('bookings')
        .where('villa_id', isEqualTo: villaId)
        .get();

    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = (data['status'] ?? '').toString();
      if (status != 'paid') continue;

      final inRaw = data['check_in'];
      final outRaw = data['check_out'];
      if (inRaw is! Timestamp || outRaw is! Timestamp) continue;

      final existingIn = _normalize(inRaw.toDate());
      final existingOut = _normalize(outRaw.toDate());

      final bool overlap =
          existingIn.isBefore(end) && existingOut.isAfter(start);

      if (overlap) return false;
    }

    return true;
  }

  // ================== ACTION: BOOKING ==================

  Future<void> createBooking(BuildContext context) async {
    // CEK INPUT DULU
    if (checkIn.value == null || checkOut.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi tanggal check-in & check-out')),
      );
      return;
    }

    final userId = AppSession.userDocId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    // owner_id WAJIB ADA
    final String? ownerId = villaData['owner_id']?.toString();
    if (ownerId == null || ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data pemilik villa tidak valid. Hubungi admin aplikasi.',
          ),
        ),
      );
      return;
    }

    final String villaName = villaData['name']?.toString() ?? 'Tanpa Nama';
    final String villaLocation = villaData['location']?.toString() ?? '-';

    final int totalPrice = calculateTotalPrice();
    if (totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan dalam perhitungan harga.'),
        ),
      );
      return;
    }

    late DocumentReference bookingRef;

    try {
      loadingBooking.value = true;

      // CEK RANGE SEKALI LAGI
      final available = await isDateRangeAvailable();
      if (!available) {
        loadingBooking.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tanggal ini sudah dibooking orang lain.\nSilakan pilih tanggal lain.',
            ),
          ),
        );
        _loadBookedDates();
        return;
      }

      // BANGUN DATA BOOKING TANPA NILAI NULL
      final Map<String, dynamic> data = {
        'user_id': userId,
        'villa_id': villaId,
        'owner_id': ownerId,
        'villa_name': villaName,
        'villa_location': villaLocation,
        'status': 'pending',
        'check_in': Timestamp.fromDate(checkIn.value!),
        'check_out': Timestamp.fromDate(checkOut.value!),
        'total_price': totalPrice,
        // untuk menghindari problem di web, pakai Timestamp.now()
        'created_at': Timestamp.now(),
      };

      data.removeWhere((key, value) => value == null);

      debugPrint('=== DATA BOOKING YANG DIKIRIM ===');
      data.forEach((k, v) => debugPrint('$k : $v'));
      debugPrint('=================================');

      // SIMPAN KE FIRESTORE
      bookingRef = await FirebaseFirestore.instance
          .collection('bookings')
          .add(data);

      loadingBooking.value = false;
    } catch (e, st) {
      loadingBooking.value = false;
      debugPrint('ERROR CREATE BOOKING: $e');
      debugPrint('$st');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat booking di server: $e')),
      );
      return; // jangan lanjut ke payment
    }

    // kalau sampai sini berarti booking berhasil dibuat
    Get.toNamed(
      '/payment',
      arguments: {
        'bookingId': bookingRef.id,
        'villaName': villaName,
        'totalPrice': totalPrice,
        'checkIn': checkIn.value!,
        'checkOut': checkOut.value!,
        'imageUrl': firstImageUrl,
      },
    );
  }

  // ================== ACTION: CHAT & MAPS ==================

  void openChatRoom(BuildContext context) {
    final String? ownerId = villaData['owner_id']?.toString();

    if (ownerId == null || ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pemilik villa tidak tersedia')),
      );
      return;
    }

    final userId = AppSession.userDocId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    Get.toNamed(
      '/chat-room',
      arguments: {'villaId': villaId, 'ownerId': ownerId, 'userId': userId},
    );
  }

  Future<void> openMaps(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link lokasi belum tersedia')),
      );
      return;
    }

    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.platformDefault);

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error saat membuka Maps: $e')),
      );
    }
  }

  // ================== FAVORIT ==================

  Stream<bool> favoriteStream() {
    return UserCollections.isFavoriteStream(villaId);
  }

  Future<void> toggleFavorite(BuildContext context) async {
    try {
      await UserCollections.toggleFavorite(villaId);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengubah favorit: $e')));
    }
  }
}
