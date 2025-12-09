import 'package:get/get.dart';
import 'profile_viewmodel.dart';

class OwnerProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OwnerProfileViewModel>(() => OwnerProfileViewModel());
  }
}
