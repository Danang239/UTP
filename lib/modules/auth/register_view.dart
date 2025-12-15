import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'register_viewmodel.dart';

class RegisterView extends GetView<RegisterViewModel> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // =============================
              // NAMA
              // =============================
              TextField(
                controller: controller.nameC,
                enabled: !controller.isLoading.value,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // =============================
              // PHONE
              // =============================
              TextField(
                controller: controller.phoneC,
                enabled: !controller.isLoading.value,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  hintText: 'Contoh: 08123456789',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // =============================
              // EMAIL
              // =============================
              TextField(
                controller: controller.emailC,
                enabled: !controller.isLoading.value,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // =============================
              // PASSWORD
              // =============================
              TextField(
                controller: controller.passwordC,
                enabled: !controller.isLoading.value,
                obscureText: true,
                autofillHints: const [AutofillHints.newPassword],
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // =============================
              // ERROR MESSAGE
              // =============================
              Obx(() {
                final msg = controller.errorMessage.value;
                if (msg == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    msg,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                );
              }),

              // =============================
              // BUTTON REGISTER
              // =============================
              Obx(() {
                final loading = controller.isLoading.value;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : controller.register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
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
            ],
          ),
        ),
      ),
    );
  }
}
