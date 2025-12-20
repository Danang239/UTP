import 'package:get/get.dart';

// MAIN
import 'main_viewmodel.dart';

// TAB VIEWMODELS (HANYA YANG TANPA PARAMETER)
import '../favorite/favorite_viewmodel.dart';
import '../profile/profile_viewmodel.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // MAIN
    Get.put(MainViewModel());

    // TAB CONTROLLERS
    // ❌ JANGAN PUT HomeViewModel DI SINI
    // ❌ JANGAN PUT PesanViewModel DI SINI

    Get.put(FavoriteViewModel());
    Get.put(ProfileViewModel());
  }
}
