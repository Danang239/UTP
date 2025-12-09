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

      final phoneFromDb = await _authRepository.login(
        identifier.trim(),
        password.trim(),
      );

      final ok = await AppSession.saveUser(phoneFromDb);
      if (!ok) {
        errorMessage.value = 'Gagal menyimpan sesi pengguna';
        return;
      }

      // CEK ROLE DARI SESSION
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
}
