import 'package:get/get.dart';
import 'admin_data_villa_viewmodel.dart';

class AdminDataVillaBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AdminDataVillaViewModel());
  }
}
