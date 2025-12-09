import 'package:get/get.dart';
import 'package:utp_flutter/data/repositories/chat_repository.dart';
import 'package:utp_flutter/data/services/chat_service.dart';
import 'pesan_viewmodel.dart';

class PesanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatService>(() => ChatService());
    Get.lazyPut<ChatRepository>(() => ChatRepository(Get.find<ChatService>()));
    Get.lazyPut<PesanViewModel>(
      () => PesanViewModel(Get.find<ChatRepository>()),
    );
  }
}
