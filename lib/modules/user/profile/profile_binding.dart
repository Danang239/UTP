import 'package:get/get.dart';
import 'profile_viewmodel.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileViewModel>(() => ProfileViewModel(), fenix: true);
  }
}
