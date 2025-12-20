// lib/modules/payment/payment_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'payment_controller.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.goBackStep,
        ),
        title: const Text('Pembayaran'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ],
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            switch (controller.step.value) {
              case 0:
                return _buildReviewStep(context);
              case 1:
                return _buildMethodStep(context);
              case 2:
                return controller.method.value == 'transfer'
                    ? _buildTransferDetailStep(context)
                    : _buildQrisStep(context);
              case 3:
                return _buildUploadProofStep(context);
              case 4:
                return _buildSuccessStep(context);
              default:
                return const SizedBox.shrink();
            }
          }),
        ),
      ),
    );
  }

  // ====== STEP 0: Review ======
  Widget _buildReviewStep(BuildContext context) {
    final theme = Theme.of(context);
    final dateText =
        '${controller.formatDate(controller.checkIn)}  -  ${controller.formatDate(controller.checkOut)}';

    final args = Get.arguments as Map<String, dynamic>?;
    final String? imageUrl = args?['imageUrl'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: (imageUrl != null && imageUrl.isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: theme.colorScheme.surface,
                            child: Icon(
                              Icons.image_not_supported,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.surface,
                          child: Icon(
                            Icons.home_work_outlined,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.villaName,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(dateText, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: theme.textTheme.bodySmall),
                        Text(
                          controller.formatRupiah(controller.totalPrice),
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.goToNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Pesan'),
          ),
        ),
      ],
    );
  }

  // ====== STEP 1: Method ======
  Widget _buildMethodStep(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tambahkan metode pembayaran',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                value: 'transfer',
                groupValue: controller.method.value,
                onChanged: (val) {
                  if (val == null) return;
                  controller.method.value = val;
                },
                title: const Text('Transfer Bank'),
                secondary: const Icon(Icons.account_balance),
              ),
              Divider(color: theme.dividerColor, height: 0),
              RadioListTile<String>(
                value: 'qris',
                groupValue: controller.method.value,
                onChanged: (val) {
                  if (val == null) return;
                  controller.method.value = val;
                },
                title: const Text('QRIS'),
                secondary: const Icon(Icons.qr_code),
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.goToNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Selanjutnya'),
          ),
        ),
      ],
    );
  }

  // ====== STEP 2A: Transfer ======
  Widget _buildTransferDetailStep(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pembayaran', style: theme.textTheme.bodyMedium),
              Text(
                controller.formatRupiah(controller.totalPrice),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Pilih bank tujuan',
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: controller.bankAccounts.keys.map((bank) {
              return RadioListTile<String>(
                value: bank,
                groupValue: controller.selectedBank.value,
                onChanged: (val) {
                  if (val == null) return;
                  controller.selectedBank.value = val;
                },
                title: Text('Bank $bank'),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance, size: 32),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bank ${controller.selectedBank.value}',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No. Rekening / VA',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            controller.selectedAccount,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('SALIN'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: theme.dividerColor),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Petunjuk Transfer mBanking'),
                    children: const [
                      ListTile(
                        dense: true,
                        title: Text('1. Buka aplikasi mBanking sesuai bank.'),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                            '2. Pilih menu transfer ke rekening / VA.'),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                            '3. Masukkan nomor & jumlah sesuai tagihan.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Petunjuk Transfer ATM'),
                    children: const [
                      ListTile(
                        dense: true,
                        title: Text('1. Masukkan kartu ATM dan PIN.'),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                            '2. Pilih menu transfer antar bank.'),
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                            '3. Masukkan nomor & jumlah sesuai tagihan.'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.goToNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Lanjutkan'),
          ),
        ),
      ],
    );
  }

  // ====== STEP 2B: QRIS ======
  Widget _buildQrisStep(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Text('QRIS',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              'QRIS CODE',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Silakan scan QRIS di atas\nmenggunakan e-wallet / mBanking Anda.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.goToNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Lanjutkan'),
          ),
        ),
      ],
    );
  }

  // ====== STEP 3: Upload Proof ======
  Widget _buildUploadProofStep(BuildContext context) {
    final theme = Theme.of(context);
    final file = controller.proofFile.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.method.value == 'transfer'
              ? 'Upload Bukti Transfer'
              : 'Upload Bukti Pembayaran QRIS',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Pembayaran',
                  style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                controller.formatRupiah(controller.totalPrice),
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Metode: ${controller.method.value == 'transfer' ? 'Transfer Bank (${controller.selectedBank.value})' : 'QRIS'}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Upload bukti pembayaran',
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: controller.pickProof,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.upload_file, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file == null
                        ? 'Pilih gambar bukti pembayaran'
                        : file.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: file == null
                          ? theme.colorScheme.onSurface.withOpacity(0.6)
                          : theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Format: jpg, png.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.hintColor),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                controller.saving.value ? null : controller.confirmPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: controller.saving.value
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Saya sudah bayar'),
          ),
        ),
      ],
    );
  }

  // ====== STEP 4: Success ======
  Widget _buildSuccessStep(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(Icons.check_circle,
            color: theme.colorScheme.primary, size: 72),
        const SizedBox(height: 20),
        Text(
          'Booking Berhasil',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Terima kasih atas booking-nya.\nPembayaran akan dicek admin.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Status akan berubah menjadi PAID\nsetelah verifikasi.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.hintColor),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Kembali ke Beranda'),
          ),
        ),
      ],
    );
  }
}
