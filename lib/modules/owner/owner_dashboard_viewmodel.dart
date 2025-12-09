import 'package:get/get.dart';

class OwnerDashboardViewModel extends GetxController {
  // index: 0 = Dashboard, 1 = Villa, 2 = Pesan, 3 = Profile
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
