import 'package:get/get.dart';

class OwnerDashboardTabViewModel extends GetxController {
  final isLoading = false.obs;
  final errorMessage = RxnString();

  final totalPendapatanBulanIni = 0.0.obs;
  final totalBookingBulanIni = 0.obs;
  final totalVillaTerdaftar = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSummary();
  }

  Future<void> loadSummary() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // TODO: ganti dengan query firestore
      await Future.delayed(const Duration(milliseconds: 400));

      totalPendapatanBulanIni.value = 100000000;
      totalBookingBulanIni.value = 180;
      totalVillaTerdaftar.value = 15;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
