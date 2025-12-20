// lib/modules/auth/otp/otp_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/main.dart';
import 'package:utp_flutter/modules/user/main/main_page.dart';

class OtpViewModel extends GetxController {
  final String phoneNumber;

  OtpViewModel(this.phoneNumber);

  final TextEditingController otpController = TextEditingController();

  void verifyOtp() {
    final code = otpController.text.trim();

    if (code.isEmpty) {
      Get.snackbar(
        'Kode OTP kosong',
        'Silakan masukkan kode OTP terlebih dahulu.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: di sini nanti bisa kamu ganti dengan verifikasi OTP beneran (Firebase, dsb).
    // Sekarang: langsung masuk ke MainPage, sama seperti halaman lama.
    Get.offAll(() => const MainPage());
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
