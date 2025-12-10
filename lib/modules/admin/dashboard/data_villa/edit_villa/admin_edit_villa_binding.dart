import 'package:get/get.dart';

import 'admin_edit_villa_viewmodel.dart';

class AdminEditVillaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminEditVillaViewModel>(() {
      final String villaId = Get.arguments as String;
      return AdminEditVillaViewModel(villaId: villaId);
    });
  }
}
