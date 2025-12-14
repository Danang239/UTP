// lib/modules/payment/payment_controller.dart
import 'dart:typed_data';

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

  // (tetap seperti punyamu)
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

    bookingId = args['bookingId']?.toString() ?? '';
    villaName = args['villaName']?.toString() ?? '';
    totalPrice = args['totalPrice'] is int
        ? args['totalPrice'] as int
        : int.tryParse(args['totalPrice']?.toString() ?? '0') ?? 0;

    // ini kamu sudah pakai DateTime dari arguments
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
  // UPLOAD BUKTI KE SUPABASE STORAGE (FIXED)
  // =====================================================
  String _normalizeExt(String fileName) {
    final lower = fileName.toLowerCase();
    if (!lower.contains('.')) return 'jpg';
    final ext = lower.split('.').last;
    if (ext == 'jpeg') return 'jpg';
    if (ext == 'png') return 'png';
    if (ext == 'jpg') return 'jpg';
    return 'jpg';
  }

  String _contentTypeFromExt(String ext) {
    // Supabase lebih aman kalau jpg -> image/jpeg
    if (ext == 'png') return 'image/png';
    return 'image/jpeg';
  }

  Future<Map<String, String>> _uploadProofToSupabase() async {
    final file = proofFile.value!;
    final Uint8List bytes = await file.readAsBytes();

    final originalName = file.name;
    final ext = _normalizeExt(originalName);

    final String path =
        'payment_proofs/$bookingId-${DateTime.now().millisecondsSinceEpoch}.$ext';

    final storage = _supabase.storage.from('payment'); // nama bucket kamu: payment

    // 🔥 FIX 403 "Invalid Compact JWS":
    // Kadang ada sesi Supabase korup/invalid di local storage (terutama web),
    // jadi request bawa Authorization JWT rusak.
    // Ini TIDAK mengganggu Firebase login kamu.
    try {
      if (_supabase.auth.currentSession != null) {
        await _supabase.auth.signOut();
      }
    } catch (_) {
      // abaikan kalau signOut gagal, kita tetap coba upload
    }

    // ✅ Untuk Flutter web & mobile: uploadBinary paling aman untuk XFile bytes
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: false,
        contentType: _contentTypeFromExt(ext),
      ),
    );

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
        // status booking tetap 'pending', admin nanti confirm jadi 'confirmed'
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

      step.value = 4; // sukses
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengkonfirmasi pembayaran: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      saving.value = false;
    }
  }
}
