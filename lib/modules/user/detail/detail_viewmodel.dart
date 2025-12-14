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
      return rawImages;
    }
    return null;
  }

  // ================== SLIDER FOTO ==================
  final currentImageIndex = 0.obs;
  late final PageController imagePageController;

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

  // ================== TANGGAL ==================
  final checkIn = Rxn<DateTime>();
  final checkOut = Rxn<DateTime>();

  late DateTime focusedDay;
  late DateTime firstDay;
  late DateTime lastDay;
  late DateTime todayNorm;

  /// 🔴 Semua tanggal yang TERKUNCI (pending / confirmed / paid)
  final bookedDates = <DateTime>[].obs;

  final loadingCalendar = true.obs;
  final loadingBooking = false.obs;

  @override
  void onInit() {
    super.onInit();
    imagePageController = PageController();

    final now = DateTime.now();
    focusedDay = DateTime(now.year, now.month, now.day);
    firstDay = focusedDay;
    lastDay = DateTime(now.year + 2, 12, 31);
    todayNorm = _normalize(now);

    _loadBookedDates();
  }

  @override
  void onClose() {
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

    if (!day.isBefore(last)) {
      final isWeekend =
          day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
      return isWeekend ? weekendPrice : weekdayPrice;
    }

    int total = 0;
    while (day.isBefore(last)) {
      final isWeekend =
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
    return d.isAfter(_normalize(checkIn.value!)) &&
        d.isBefore(_normalize(checkOut.value!));
  }

  // ================== LOAD BOOKED DATES ==================
  /// 🔥 pending / confirmed / paid = TERKUNCI
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

        // ❌ hanya cancelled yang membuka tanggal
        if (status == 'cancelled') continue;

        final inRaw = data['check_in'];
        final outRaw = data['check_out'];
        if (inRaw is! Timestamp || outRaw is! Timestamp) continue;

        DateTime day = _normalize(inRaw.toDate());
        final last = _normalize(outRaw.toDate());

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

  // ================== KALENDER SELECT ==================

  void onSelectDay(DateTime day, BuildContext context) {
    final d = _normalize(day);

    if (d.isBefore(todayNorm)) return;

    if (isBooked(d)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal ini sudah dibooking.'),
        ),
      );
      return;
    }

    if (checkIn.value == null ||
        (checkIn.value != null && checkOut.value != null)) {
      checkIn.value = d;
      checkOut.value = null;
      return;
    }

    if (checkIn.value != null && checkOut.value == null) {
      if (d.isBefore(checkIn.value!)) {
        checkIn.value = d;
        checkOut.value = null;
        return;
      }

      DateTime cursor = _normalize(checkIn.value!);
      while (cursor.isBefore(d)) {
        if (isBooked(cursor)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Range tanggal melewati tanggal yang sudah dibooking.',
              ),
            ),
          );
          return;
        }
        cursor = cursor.add(const Duration(days: 1));
      }

      checkOut.value = d;
    }
  }

  void onPageChanged(DateTime newFocused) {
    focusedDay = newFocused;
  }

  // ================== CEK RANGE ==================
  Future<bool> isDateRangeAvailable() async {
    if (checkIn.value == null || checkOut.value == null) return false;

    final start = _normalize(checkIn.value!);
    final end = _normalize(checkOut.value!);

    final snap = await FirebaseFirestore.instance
        .collection('bookings')
        .where('villa_id', isEqualTo: villaId)
        .get();

    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = (data['status'] ?? '').toString();

      if (status == 'cancelled') continue;

      final inRaw = data['check_in'];
      final outRaw = data['check_out'];
      if (inRaw is! Timestamp || outRaw is! Timestamp) continue;

      final existingIn = _normalize(inRaw.toDate());
      final existingOut = _normalize(outRaw.toDate());

      if (existingIn.isBefore(end) && existingOut.isAfter(start)) {
        return false;
      }
    }
    return true;
  }

  // ================== BOOKING ==================

  Future<void> createBooking(BuildContext context) async {
    if (checkIn.value == null || checkOut.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi tanggal booking')),
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

    final ownerId = villaData['owner_id']?.toString();
    if (ownerId == null || ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pemilik villa tidak valid'),
        ),
      );
      return;
    }

    final totalPrice = calculateTotalPrice();
    if (totalPrice <= 0) return;

    loadingBooking.value = true;

    final available = await isDateRangeAvailable();
    if (!available) {
      loadingBooking.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal sudah dibooking.'),
        ),
      );
      _loadBookedDates();
      return;
    }

    final data = {
      'user_id': userId,
      'user_name': AppSession.name,
      'villa_id': villaId,
      'owner_id': ownerId,
      'villa_name': villaData['name'],
      'villa_location': villaData['location'],
      'status': 'pending',
      'payment_status': 'waiting_payment',
      'check_in': Timestamp.fromDate(checkIn.value!),
      'check_out': Timestamp.fromDate(checkOut.value!),
      'total_price': totalPrice,
      'created_at': Timestamp.now(),
    };

    final bookingRef = await FirebaseFirestore.instance
        .collection('bookings')
        .add(data);

    loadingBooking.value = false;

    Get.toNamed(
      '/payment',
      arguments: {
        'bookingId': bookingRef.id,
        'villaName': villaData['name'],
        'totalPrice': totalPrice,
        'checkIn': checkIn.value!,
        'checkOut': checkOut.value!,
        'imageUrl': firstImageUrl,
      },
    );
  }

  // ================== CHAT & MAPS ==================

  void openChatRoom(BuildContext context) {
    final ownerId = villaData['owner_id']?.toString();
    final userId = AppSession.userDocId;
    if (ownerId == null || userId == null) return;

    Get.toNamed(
      '/chat-room',
      arguments: {'villaId': villaId, 'ownerId': ownerId, 'userId': userId},
    );
  }

  Future<void> openMaps(BuildContext context, String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  // ================== FAVORIT ==================

  Stream<bool> favoriteStream() {
    return UserCollections.isFavoriteStream(villaId);
  }

  Future<void> toggleFavorite(BuildContext context) async {
    await UserCollections.toggleFavorite(villaId);
  }
}
