import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_viewmodel.dart';

class RegisterView extends GetView<RegisterViewModel> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ SELARAS DENGAN SPLASH & LOGIN
      backgroundColor: const Color(0xFFEAF6FF),

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // =====================
                // TITLE
                // =====================
                const Text(
                  "Daftar Akun",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Buat akun baru untuk mulai menggunakan Stay&Co",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 32),

                // =====================
                // NAMA
                // =====================
                TextField(
                  controller: controller.nameC,
                  enabled: !controller.isLoading.value,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =====================
                // PHONE
                // =====================
                TextField(
                  controller: controller.phoneC,
                  enabled: !controller.isLoading.value,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor Telepon',
                    hintText: 'Contoh: 08123456789',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =====================
                // EMAIL
                // =====================
                TextField(
                  controller: controller.emailC,
                  enabled: !controller.isLoading.value,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =====================
                // PASSWORD
                // =====================
                TextField(
                  controller: controller.passwordC,
                  enabled: !controller.isLoading.value,
                  obscureText: true,
                  autofillHints: const [AutofillHints.newPassword],
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // =====================
                // ERROR MESSAGE
                // =====================
                Obx(() {
                  final msg = controller.errorMessage.value;
                  if (msg == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      msg,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // =====================
                // BUTTON REGISTER
                // =====================
                Obx(() {
                  final loading = controller.isLoading.value;
                  return SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loading ? null : controller.register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // ungu Stay&Co
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Daftar',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // =====================
                // BACK TO LOGIN
                // =====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
