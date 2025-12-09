import 'package:get/get.dart';

import 'owner_dashboard_viewmodel.dart';
import 'dashboard/dashboard_viewmodel.dart';
import 'villa/villa_viewmodel.dart';
import 'pesan/pesan_viewmodel.dart';
import 'profile/profile_viewmodel.dart';

class OwnerDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // ROOT (bottom nav)
    Get.lazyPut<OwnerDashboardViewModel>(() => OwnerDashboardViewModel());

    // ViewModel untuk tiap tab
    Get.lazyPut<OwnerDashboardTabViewModel>(() => OwnerDashboardTabViewModel());
    Get.lazyPut<OwnerVillaViewModel>(() => OwnerVillaViewModel());
    Get.lazyPut<OwnerPesanViewModel>(() => OwnerPesanViewModel());
    Get.lazyPut<OwnerProfileViewModel>(() => OwnerProfileViewModel());
  }
}
