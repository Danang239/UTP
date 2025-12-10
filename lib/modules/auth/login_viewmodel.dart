import 'package:cloud_firestore/cloud_firestore.dart';          // ⬅️ TAMBAHAN
import 'package:get/get.dart';
import 'package:utp_flutter/app_session.dart';
import 'package:utp_flutter/data/repositories/auth_repository.dart';
import 'package:utp_flutter/main.dart'; // untuk MainPage
import 'package:utp_flutter/app/routes/app_routes.dart';

class LoginViewModel extends GetxController {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository);

  final isLoading = false.obs;
  final errorMessage = RxnString();

  Future<void> login(String identifier, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      // 🔐 login ke backend (Supabase / dsb.)
      final phoneFromDb = await _authRepository.login(
        identifier.trim(),
        password.trim(),
      );

      // simpan sesi dari Firestore (userDocId, phone, name, role, dll.)
      final ok = await AppSession.saveUser(phoneFromDb);
      if (!ok) {
        errorMessage.value = 'Gagal menyimpan sesi pengguna';
        return;
      }

      // ✅ CEK STATUS BAN/BLOKIR DI FIRESTORE
      final blockedOrBanned = await _checkBanStatus();
      if (blockedOrBanned) {
        // kalau diblokir/dibanned, jangan lanjut ke dashboard
        return;
      }

      // CEK ROLE DARI SESSION (LOGIC LAMA – TIDAK DIUBAH)
      final role = AppSession.role ?? 'user';

      if (role == 'admin') {
        Get.offAllNamed(Routes.adminDashboard);
      } else if (role == 'owner') {
        Get.offAllNamed(Routes.ownerDashboard);
      } else {
        Get.offAll(() => const MainPage());
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ======================================================
  // CEK apakah user diblokir / dibanned setelah login
  // ======================================================
  Future<bool> _checkBanStatus() async {
    try {
      final userDocId = AppSession.userDocId;
      if (userDocId == null) {
        // kalau entah kenapa belum ada id dokumen, anggap aman
        return false;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userDocId)
          .get();

      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;

      // default: aktif
      final bool isActive = (data['is_active'] ?? true) as bool;

      DateTime? bannedUntil;
      if (data['banned_until'] is Timestamp) {
        bannedUntil = (data['banned_until'] as Timestamp).toDate();
      }

      final bool isCurrentlyBanned =
          bannedUntil != null && bannedUntil.isAfter(DateTime.now());

      // ❌ BLOKIR PERMANEN
      if (!isActive) {
        errorMessage.value = 'Akun Anda telah diblokir oleh admin.';
        await AppSession.clear();
        return true;
      }

      // ❌ BAN SEMENTARA
      if (isCurrentlyBanned) {
        final until = bannedUntil!;
        final untilText =
            '${until.day.toString().padLeft(2, '0')}/${until.month.toString().padLeft(2, '0')}/${until.year}';

        errorMessage.value =
            'Akun Anda dibanned sampai $untilText. Silakan coba lagi nanti.';
        await AppSession.clear();
        return true;
      }

      // ✅ aman
      return false;
    } catch (e) {
      // kalau gagal cek ban (misal jaringan error), jangan blok user
      print('ERROR _checkBanStatus: $e');
      return false;
    }
  }
}
