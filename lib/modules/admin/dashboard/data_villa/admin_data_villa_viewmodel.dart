import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminVillaItem {
  final String id;
  final String name;
  final String address;     // dari field "location"
  final String category;    // Kapasitas X orang
  final double price;       // weekday_price
  final String ownerName;   // name / nama user owner

  AdminVillaItem({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.price,
    required this.ownerName,
  });
}

class AdminDataVillaViewModel extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxList<AdminVillaItem> villas = <AdminVillaItem>[].obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadVillas();
  }

  // -------------------------
  // LOAD VILLA LIST
  // -------------------------
  Future<void> loadVillas() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final snapshot = await _db.collection('villas').get();
      print('ADMIN DATA VILLA → jumlah dokumen: ${snapshot.docs.length}');

      final ownersCache = <String, String>{}; // caching biar hemat query
      final List<AdminVillaItem> items = [];

      for (final doc in snapshot.docs) {
        items.add(await _mapVillaDoc(doc, ownersCache));
      }

      villas.assignAll(items);
    } catch (e, st) {
      print('ERROR loadVillas: $e\n$st');
      errorMessage.value = e.toString();
      villas.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------
  // MAP DOKUMEN VILLA
  // -------------------------
  Future<AdminVillaItem> _mapVillaDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, String> ownersCache,
  ) async {
    final data = doc.data();

    // Nama villa
    final String name = (data['name'] ?? '') as String;

    // Lokasi
    final String address = (data['location'] ?? '') as String;

    // Kapasitas
    int maxPerson = 0;
    if (data['max_person'] is int) {
      maxPerson = data['max_person'] as int;
    } else if (data['max_person'] is num) {
      maxPerson = (data['max_person'] as num).toInt();
    }
    final String category =
        maxPerson > 0 ? 'Kapasitas $maxPerson orang' : 'Kapasitas tidak diketahui';

    // Harga weekday
    double price = 0;
    if (data['weekday_price'] is int) {
      price = (data['weekday_price'] as int).toDouble();
    } else if (data['weekday_price'] is double) {
      price = data['weekday_price'] as double;
    } else if (data['weekday_price'] is num) {
      price = (data['weekday_price'] as num).toDouble();
    }

    // -------------------------------
    // AMBIL OWNER (users/{owner_id})
    // -------------------------------
    final String ownerId = (data['owner_id'] ?? '') as String;
    String ownerName = '-';

    if (ownerId.isNotEmpty) {
      // Cek cache dulu
      if (ownersCache.containsKey(ownerId)) {
        ownerName = ownersCache[ownerId]!;
      } else {
        final ownerDoc = await _db.collection('users').doc(ownerId).get();

        if (ownerDoc.exists) {
          final ownerData = ownerDoc.data() ?? {};

          // pakai 'name' kalau ada
          // kalau tidak, pakai 'nama'
          ownerName = (ownerData['name'] ??
              ownerData['nama'] ??
              'Owner') as String;

          ownersCache[ownerId] = ownerName;
        }
      }
    }

    return AdminVillaItem(
      id: doc.id,
      name: name,
      address: address,
      category: category,
      price: price,
      ownerName: ownerName,
    );
  }

  // -------------------------
  // DELETE VILLA
  // -------------------------
  Future<void> deleteVilla(String id) async {
    await _db.collection('villas').doc(id).delete();
    await loadVillas(); // refresh list
  }
}
