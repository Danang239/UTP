import 'package:get/get.dart';
import 'admin_chat_viewmodel.dart';

class AdminChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminChatViewModel>(() => AdminChatViewModel());
  }
}
