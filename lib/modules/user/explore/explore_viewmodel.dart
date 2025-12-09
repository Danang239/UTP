// lib/modules/explore/explore_viewmodel.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../detail/detail_view.dart';

class ExploreViewModel extends GetxController {
  final _db = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  /// List villa: setiap item punya key 'id' + data Firestore lainnya
  final villas = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadVillas();
  }

  Future<void> loadVillas() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final snap = await _db.collection('villas').get();

      villas.assignAll(
        snap.docs.map((d) {
          final data = d.data();
          return {'id': d.id, ...data};
        }).toList(),
      );
    } catch (e) {
      errorMessage.value = 'Gagal memuat villa: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Buka DetailView dengan villaId + data lengkap
  void openDetail(Map<String, dynamic> villa) {
    final villaId = villa['id'] as String;

    // kita buang field 'id' supaya villaData isinya sama kayak di Firestore
    final data = Map<String, dynamic>.from(villa)..remove('id');

    Get.to(() => DetailView(villaId: villaId, villaData: data));
  }
}
