import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_data_owner_viewmodel.dart';

class AdminOwnerEditBinding extends Bindings {
  @override
  void dependencies() {
    // Mendaftarkan ViewModel untuk halaman edit owner
    Get.put(AdminDataOwnerViewModel());
  }
}
