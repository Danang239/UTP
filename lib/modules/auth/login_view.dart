import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'login_viewmodel.dart';
import 'register_view.dart';
import 'register_binding.dart';

class LoginView extends GetView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailOrPhoneController =
        TextEditingController();
    final TextEditingController passwordController =
        TextEditingController();

    return Scaffold(
      // ✅ SELARAS DENGAN SPLASH
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
                // LOGO
                // =====================
                Center(
                  child: Image.asset(
                    'assets/images/logo_stayco.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 18),

                // =====================
                // TITLE
                // =====================
                const Text(
                  "Masuk ke Akun Anda",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Selamat datang kembali di Stay&Co",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 32),

                // =====================
                // EMAIL / PHONE
                // =====================
                TextField(
                  controller: emailOrPhoneController,
                  decoration: InputDecoration(
                    labelText: "Email atau Nomor Telepon",
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
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
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
                // BUTTON LOGIN (BIRU)
                // =====================
                Obx(() {
                  final loading = controller.isLoading.value;
                  return SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: loading
                          ? null
                          : () {
                              controller.login(
                                emailOrPhoneController.text.trim(),
                                passwordController.text.trim(),
                              );
                            },
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
                              "Login",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // =====================
                // LINK REGISTER
                // =====================
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    TextButton(
                      onPressed: () {
                        Get.to(
                          () => const RegisterView(),
                          binding: RegisterBinding(),
                        );
                      },
                      child: const Text(
                        "Daftar",
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
