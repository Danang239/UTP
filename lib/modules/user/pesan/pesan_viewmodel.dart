import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app_session.dart';
import 'package:utp_flutter/data/repositories/chat_repository.dart';

class PesanViewModel extends GetxController {
  final ChatRepository _repository;

  PesanViewModel(this._repository);

  final userId = RxnString();
  Stream<QuerySnapshot<Map<String, dynamic>>>? chatsStream;

  @override
  void onInit() {
    super.onInit();
    final uid = AppSession.userDocId;
    userId.value = uid;

    if (uid != null) {
      chatsStream = _repository.getChatsForUser(uid);
    }
  }

  Future<Map<String, dynamic>?> getVillaDetail(String villaId) async {
    if (villaId.isEmpty) return null;
    final snap = await _repository.getVillaDetail(villaId);
    if (!snap.exists) return null;
    return snap.data();
  }
}
