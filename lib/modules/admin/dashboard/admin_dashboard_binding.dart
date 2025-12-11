import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/booking_payment/admin_booking_payment_viewmodel.dart';
import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_viewmodel.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // register ViewModel untuk halaman admin
    Get.lazyPut<AdminDashboardViewModel>(
      () => AdminDashboardViewModel(),
    );
    Get.lazyPut<AdminBookingPaymentViewModel>(
  () => AdminBookingPaymentViewModel(),
);
  }
}
