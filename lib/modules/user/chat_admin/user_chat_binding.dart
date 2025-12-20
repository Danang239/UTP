import 'package:get/get.dart';
import 'user_chat_viewmodel.dart';

class UserChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserChatViewModel>(() => UserChatViewModel());
  }
}
