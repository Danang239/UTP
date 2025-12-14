import 'dart:async';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utp_flutter/app_session.dart';

class OwnerBookingsViewModel extends GetxController {
  final bookings = <QueryDocumentSnapshot>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  final _db = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  void loadBookings() {
    final ownerId = AppSession.ownerId;

    if (ownerId == null || ownerId.isEmpty) {
      errorMessage.value = "Data owner tidak ditemukan. Silakan login ulang.";
      return;
    }

    isLoading.value = true;

    _subscription = _db
        .collection('bookings')
        .where('owner_id', isEqualTo: ownerId)
        .where('status', isEqualTo: 'confirmed') // 🔥 FILTER ADMIN CONFIRM
        .snapshots()
        .listen(
      (snapshot) {
        final docs = snapshot.docs.toList();

        // Urutkan manual (aman, tanpa index)
        docs.sort((a, b) {
          final ta =
              (a.data()['created_at'] as Timestamp?)?.toDate() ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final tb =
              (b.data()['created_at'] as Timestamp?)?.toDate() ??
              DateTime.fromMillisecondsSinceEpoch(0);

          return tb.compareTo(ta);
        });

        bookings.assignAll(docs);
        isLoading.value = false;
      },
      onError: (e) {
        errorMessage.value = e.toString();
        isLoading.value = false;
      },
    );
  }
}
