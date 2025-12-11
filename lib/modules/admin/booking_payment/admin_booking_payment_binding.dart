// lib/modules/admin/booking_payment/admin_booking_payment_binding.dart

import 'package:get/get.dart';
import 'admin_booking_payment_viewmodel.dart';

class AdminBookingPaymentBinding extends Bindings {
  @override
  void dependencies() {
    // ViewModel utama untuk halaman Data Booking & Pembayaran
    Get.lazyPut<AdminBookingPaymentViewModel>(
      () => AdminBookingPaymentViewModel(),
    );
  }
}
