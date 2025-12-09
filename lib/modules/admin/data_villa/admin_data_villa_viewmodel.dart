import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDataVillaViewModel extends GetxController {
  final villas = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadVillas();
  }

  Future<void> loadVillas() async {
    final snap = await FirebaseFirestore.instance.collection('villas').get();

    villas.assignAll(
      snap.docs.map((d) {
        final data = d.data();
        return {
          'id': d.id,
          'name': data['name'] ?? '',
          'location': data['location'] ?? '',
          'weekday_price': data['weekday_price'] ?? 0,
          'weekend_price': data['weekend_price'] ?? 0,
        };
      }).toList(),
    );
  }
}
