// lib/modules/payment/payment_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentController extends GetxController {
  // ==== DATA BOOKING (dikirim via Get.arguments) ====
  late final String bookingId;
  late final String villaName;
  late final int totalPrice;
  late final DateTime checkIn;
  late final DateTime checkOut;

  /// 0 = review
  /// 1 = pilih metode
  /// 2 = detail metode (transfer / qris)
  /// 3 = upload bukti
  /// 4 = sukses
  final step = 0.obs;

  final method = 'transfer'.obs; // 'transfer' | 'qris'
  final selectedBank = 'BCA'.obs;
  final saving = false.obs;

  final proofFile = Rx<XFile?>(null); // bukti pembayaran

  final Map<String, String> bankAccounts = const {
    'BCA': '123 138 138 0130108',
    'BRI': '7777 8888 9999',
    'Mandiri': '123 000 999 888',
    'BNI': '987 654 321 000',
  };

  String get selectedAccount => bankAccounts[selectedBank.value] ?? '-';

  String formatRupiah(int value) => 'Rp ${value.toString()}';

  String formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();

    // Ambil parameter dari Get.arguments
    final args = Get.arguments as Map<String, dynamic>?;

    if (args == null) {
      throw ArgumentError(
        'PaymentView membutuhkan arguments: bookingId, villaName, totalPrice, checkIn, checkOut',
      );
    }

    // Sedikit lebih aman: pakai toString & parsing
    bookingId = args['bookingId']?.toString() ?? '';
    villaName = args['villaName']?.toString() ?? '';
    totalPrice = args['totalPrice'] is int
        ? args['totalPrice'] as int
        : int.tryParse(args['totalPrice']?.toString() ?? '0') ?? 0;
    checkIn = args['checkIn'] as DateTime;
    checkOut = args['checkOut'] as DateTime;

    if (bookingId.isEmpty || totalPrice <= 0) {
      throw ArgumentError('Data booking untuk PaymentView tidak valid.');
    }
  }

  void goToNextStep() {
    if (step.value < 4) step.value++;
  }

  void goBackStep() {
    if (step.value == 0) {
      Get.back();
    } else {
      step.value--;
    }
  }

  Future<void> pickProof() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      proofFile.value = result;
    }
  }

  // =====================================================
  // UPLOAD BUKTI KE SUPABASE STORAGE
  // =====================================================
  Future<Map<String, String>> _uploadProofToSupabase() async {
    final file = proofFile.value!;
    final bytes = await file.readAsBytes();

    // Tentukan ekstensi
    final originalName = file.name;
    final ext = originalName.contains('.')
        ? originalName.split('.').last
        : 'jpg';

    // Path unik di bucket
    final String path =
        'payment_proofs/$bookingId-${DateTime.now().millisecondsSinceEpoch}.$ext';

    // GANTI 'payment-proofs' dengan nama bucket kamu di Supabase Storage
    final storage = _supabase.storage.from('payment');

    // Upload binary
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: 'image/$ext',
        upsert: false,
      ),
    );

    // Ambil URL public
    final publicUrl = storage.getPublicUrl(path);

    return {
      'path': path,
      'url': publicUrl,
      'fileName': originalName,
    };
  }

  /// Simpan info pembayaran ke Firestore:
  /// - Upload foto ke Supabase Storage
  /// - Simpan URL + info ke dokumen bookings/{bookingId}
  Future<void> confirmPayment() async {
    if (proofFile.value == null) {
      Get.snackbar(
        'Bukti belum diupload',
        'Silakan upload bukti pembayaran terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    saving.value = true;

    try {
      // 1. Upload ke Supabase Storage & ambil URL
      final proofInfo = await _uploadProofToSupabase();
      final proofUrl = proofInfo['url']!;
      final proofPath = proofInfo['path']!;
      final fileName = proofInfo['fileName']!;

      // 2. Update dokumen booking di Firestore
      final bookingRef =
          FirebaseFirestore.instance.collection('bookings').doc(bookingId);

      await bookingRef.update({
        // status booking tetap 'pending', tapi payment_status menandakan sudah ada bukti
        'status': 'pending',
        'payment_status': 'waiting_verification',
        'payment_method': method.value,
        'bank': method.value == 'transfer' ? selectedBank.value : null,
        'has_payment_proof': true,
        'payment_proof_file_name': fileName,
        'payment_proof_url': proofUrl,
        'payment_proof_path': proofPath,
        'payment_proof_uploaded_at': FieldValue.serverTimestamp(),
      });

      saving.value = false;
      step.value = 4; // sukses
    } catch (e) {
      saving.value = false;
      Get.snackbar(
        'Error',
        'Gagal mengkonfirmasi pembayaran: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
