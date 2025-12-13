import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/detail_owner/admin_owner_detail_viewmodel.dart';

class AdminOwnerDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Inisialisasi AdminOwnerDetailViewModel
    Get.put(AdminOwnerDetailViewModel());
  }
}
