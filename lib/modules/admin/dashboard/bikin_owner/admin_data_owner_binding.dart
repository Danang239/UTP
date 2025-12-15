import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_data_owner_viewmodel.dart';

class AdminDataOwnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminDataOwnerViewModel>(
      () => AdminDataOwnerViewModel(),
      fenix: false,
    );
  }
}
