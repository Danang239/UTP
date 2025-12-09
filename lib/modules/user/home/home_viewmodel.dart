import 'package:get/get.dart';
import 'package:utp_flutter/data/models/villa_model.dart';
import 'package:utp_flutter/data/repositories/villa_repository.dart';

class HomeViewModel extends GetxController {
  final VillaRepository _villaRepository;

  HomeViewModel(this._villaRepository);

  /// Title halaman (reactive)
  final title = 'Stay&Co'.obs;

  /// List villa yang ditampilkan
  final villas = <Villa>[].obs;

  /// Status loading
  final isLoading = false.obs;

  /// Jika terjadi error
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadVillas();
  }

  /// Mengambil data dari Firestore lewat Repository
  Future<void> loadVillas() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final result = await _villaRepository.fetchVillas();
      villas.assignAll(result);

      // Update title berdasarkan jumlah villa (contoh)
      title.value = "Stay&Co (${villas.length} villa)";
    } catch (e) {
      errorMessage.value = 'Gagal memuat data villa: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Dipanggil saat user menekan tombol Refresh
  Future<void> refreshData() async {
    await loadVillas();
  }
}
