import 'package:get/get.dart';

class MainViewModel extends GetxController {
  /// index navbar
  final selectedIndex = 0.obs;

  void changeTab(int index) {
    if (selectedIndex.value == index) return;
    selectedIndex.value = index;
  }

  void goToFavorite() {
    selectedIndex.value = 1;
  }
}
