import 'package:get/get.dart';
import 'package:utp_flutter/data/services/villa_service.dart';
import 'package:utp_flutter/data/repositories/villa_repository.dart';
import 'home_viewmodel.dart';

/// Binding: tempat registrasi dependency untuk Home
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Service untuk akses Firestore (koleksi "villas")
    Get.lazyPut<VillaService>(() => VillaService());

    // Repository yang memakai VillaService
    Get.lazyPut<VillaRepository>(() => VillaRepository(Get.find<VillaService>()));

    // ViewModel yang memakai VillaRepository
    Get.lazyPut<HomeViewModel>(() => HomeViewModel(Get.find<VillaRepository>()));
  }
}
