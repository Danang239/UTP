import 'package:get/get.dart';
import 'search_viewmodel.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchViewModel>(() => SearchViewModel());
  }
}
