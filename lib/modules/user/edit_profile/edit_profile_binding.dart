import 'package:get/get.dart';
import 'edit_profile_viewmodel.dart';
import 'edit_profile_repository.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditProfileRepository>(() => EditProfileRepository());
    Get.lazyPut<EditProfileViewModel>(() => EditProfileViewModel());
  }
}
