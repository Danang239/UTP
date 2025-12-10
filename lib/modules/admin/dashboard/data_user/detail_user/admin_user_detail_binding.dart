import 'package:get/get.dart';

import 'admin_user_detail_viewmodel.dart';

class AdminUserDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminUserDetailViewModel>(
      () => AdminUserDetailViewModel(),
    );
  }
}
