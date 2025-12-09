import 'package:get/get.dart';
import 'chat_room_viewmodel.dart';

class ChatRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ChatRoomViewModel());
  }
}
