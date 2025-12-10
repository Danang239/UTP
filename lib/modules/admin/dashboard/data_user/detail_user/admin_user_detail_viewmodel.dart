import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../admin_data_user_viewmodel.dart';

class UserBookingItem {
  final String id;
  final String villaName;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final num totalPrice;
  final String status;

  UserBookingItem({
    required this.id,
    required this.villaName,
    required this.checkIn,
    required this.checkOut,
    required this.totalPrice,
    required this.status,
  });
}

class AdminUserDetailViewModel extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final AdminUserItem user;

  final isLoading = false.obs;
  final bookings = <UserBookingItem>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    user = Get.arguments as AdminUserItem;
    loadBookings();
  }

  Future<void> loadBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _db
          .collection('bookings')
          .where('user_id', isEqualTo: user.id)
          .orderBy('created_at', descending: true)
          .get();

      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        DateTime? checkIn;
        DateTime? checkOut;
        if (data['check_in'] is Timestamp) {
          checkIn = (data['check_in'] as Timestamp).toDate();
        }
        if (data['check_out'] is Timestamp) {
          checkOut = (data['check_out'] as Timestamp).toDate();
        }
        return UserBookingItem(
          id: doc.id,
          villaName: (data['villa_name'] ?? '-') as String,
          checkIn: checkIn,
          checkOut: checkOut,
          totalPrice: (data['total_price'] ?? 0) as num,
          status: (data['status'] ?? '-') as String,
        );
      }).toList();

      bookings.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
      bookings.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
