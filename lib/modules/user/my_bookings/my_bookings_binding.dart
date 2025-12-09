import 'package:get/get.dart';
import 'my_bookings_viewmodel.dart';

class MyBookingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MyBookingsViewModel());
  }
}
