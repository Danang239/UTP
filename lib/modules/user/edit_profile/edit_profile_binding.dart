import 'package:get/get.dart';

import 'edit_profile_repository.dart';
import 'edit_profile_viewmodel.dart';
import 'package:utp_flutter/modules/user/profile/profile_viewmodel.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Pastikan ProfileViewModel ada
    if (!Get.isRegistered<ProfileViewModel>()) {
      Get.put(ProfileViewModel(), permanent: true);
    }

    // Repository
    Get.lazyPut<EditProfileRepository>(
      () => EditProfileRepository(),
      fenix: true,
    );

    // ViewModel DENGAN REPOSITORY
    Get.lazyPut<EditProfileViewModel>(
      () => EditProfileViewModel(Get.find<EditProfileRepository>()),
      fenix: true,
    );
  }
}
