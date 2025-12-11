import 'package:get/get.dart';
import '../admin_booking_payment_viewmodel.dart';

class AdminBookingDetailViewModel extends GetxController {
  final AdminBookingItem booking;

  AdminBookingDetailViewModel(this.booking);
}

/// Binding khusus detail booking
class AdminBookingDetailBinding extends Bindings {
  final AdminBookingItem booking;

  AdminBookingDetailBinding({required this.booking});

  @override
  void dependencies() {
    Get.put<AdminBookingDetailViewModel>(
      AdminBookingDetailViewModel(booking),
    );
  }
}
