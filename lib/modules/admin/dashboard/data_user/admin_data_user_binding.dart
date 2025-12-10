import 'package:get/get.dart';
import 'admin_data_user_viewmodel.dart';

class AdminDataUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminDataUserViewModel>(() => AdminDataUserViewModel());
  }
}
