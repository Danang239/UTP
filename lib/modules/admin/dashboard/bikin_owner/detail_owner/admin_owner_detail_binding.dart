import 'package:get/get.dart';
import 'admin_owner_detail_viewmodel.dart';

class AdminOwnerDetailBinding
    extends
        Bindings {
  @override
  void dependencies() {
    Get.lazyPut<
      AdminOwnerDetailViewModel
    >(
      () => AdminOwnerDetailViewModel(),
      fenix: false,
    );
  }
}
