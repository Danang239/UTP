import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:utp_flutter/app_session.dart';

class MyBookingsViewModel extends GetxController {
  final bookings = <QueryDocumentSnapshot>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  final _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  void loadBookings() {
    final userId = AppSession.userDocId;
    if (userId == null) {
      errorMessage.value = "Silakan login untuk melihat pesanan Anda";
      return;
    }

    isLoading.value = true;

    _db
        .collection('bookings')
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            bookings.assignAll(snapshot.docs);
            isLoading.value = false;
          },
          onError: (e) {
            errorMessage.value = e.toString();
            isLoading.value = false;
          },
        );
  }
}
