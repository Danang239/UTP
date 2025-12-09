// lib/modules/explore/explore_binding.dart
import 'package:get/get.dart';
import 'explore_viewmodel.dart';

class ExploreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExploreViewModel>(() => ExploreViewModel());
  }
}
