import 'package:get/get.dart';
import 'owner_bookings_viewmodel.dart';

class OwnerBookingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OwnerBookingsViewModel>(() => OwnerBookingsViewModel());
  }
}
