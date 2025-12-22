import 'package:get/get.dart';
import 'villa_repository.dart';
import 'villa_viewmodel.dart';

class VillaBinding extends Bindings {
  @override
  void dependencies() {
    // 🔥 REGISTER REPOSITORY DULU
    Get.lazyPut<VillaRepository>(() => VillaRepository());

    // 🔥 BARU VIEWMODEL (boleh Get.find di dalamnya)
    Get.lazyPut<OwnerVillaViewModel>(() => OwnerVillaViewModel());
  }
}
