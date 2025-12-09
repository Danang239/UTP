import 'package:get/get.dart';
import 'owner_dashboard_viewmodel.dart';

class OwnerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OwnerDashboardViewModel>(() => OwnerDashboardViewModel());
  }
}
