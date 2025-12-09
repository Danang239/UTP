// lib/modules/chatbot/chatbot_binding.dart
import 'package:get/get.dart';

import 'chatbot_controller.dart';

class ChatbotBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatbotController>(() => ChatbotController());
  }
}
