import 'package:get/get.dart';
import 'favorite_viewmodel.dart';

class FavoriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoriteViewModel>(() => FavoriteViewModel());
  }
}
