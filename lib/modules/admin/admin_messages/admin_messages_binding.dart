import 'package:get/get.dart';
import 'admin_messages_viewmodel.dart';

class AdminMessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminMessagesViewModel>(
      () => AdminMessagesViewModel(),
    );
  }
}
