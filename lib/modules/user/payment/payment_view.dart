// lib/modules/payment/payment_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'payment_controller.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            switch (controller.step.value) {
              case 0:
                return _buildReviewStep();
              case 1:
                return _buildMethodStep();
              case 2:
                return controller.method.value == 'transfer'
                    ? _buildTransferDetailStep()
                    : _buildQrisStep();
              case 3:
                return _buildUploadProofStep();
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

  // ====== STEP 0: Tinjau & lanjutkan ======
  Widget _buildReviewStep() {
    final dateText =
        '${controller.formatDate(controller.checkIn)}  -  ${controller.formatDate(controller.checkOut)}';

    // AMBIL URL FOTO PERTAMA DARI ARGUMENTS (optional)
    final args = Get.arguments as Map<String, dynamic>?;
    final String? imageUrl = args?['imageUrl'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // === FOTO VILLA (SAMA KAYAK HOME) ===
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
                            color: Colors.grey[400],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        )
                      : Container(
                          color: Colors.grey[400],
                          child: const Icon(
                            Icons.home_work_outlined,
                            color: Colors.white,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(dateText, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 12)),
                        Text(
                          controller.formatRupiah(controller.totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Pesan', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // ====== STEP 1: Pilih metode ======
  Widget _buildMethodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tambahkan metode pembayaran',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
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
              const Divider(height: 0),
              RadioListTile<String>(
                value: 'qris',
                groupValue: controller.method.value,
                onChanged: (val) {
                  if (val == null) return;
                  controller.method.value = val;
                },
                title: const Text('Qris'),
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
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Selanjutnya',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ====== STEP 2A: Transfer (pilih bank) ======
  Widget _buildTransferDetailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // header total
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran', style: TextStyle(fontSize: 14)),
              Text(
                controller.formatRupiah(controller.totalPrice),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Pilih bank tujuan',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        // pilih bank
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
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
                color: Colors.grey[100],
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No. Rekening / VA',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            controller.selectedAccount,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: copy ke clipboard kalau mau
                        },
                        child: const Text('SALIN'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),

                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text(
                      'Petunjuk Transfer mBanking',
                      style: TextStyle(fontSize: 13),
                    ),
                    children: const [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '1. Buka aplikasi mBanking sesuai bank.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '2. Pilih menu transfer ke rekening / virtual account.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '3. Masukkan nomor rekening di atas dan jumlah sesuai tagihan.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text(
                      'Petunjuk Transfer ATM',
                      style: TextStyle(fontSize: 13),
                    ),
                    children: const [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '1. Masukkan kartu ATM dan PIN.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '2. Pilih menu transfer antar rekening/bank.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '3. Masukkan nomor rekening di atas dan jumlah sesuai tagihan.',
                          style: TextStyle(fontSize: 12),
                        ),
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
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Lanjutkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ====== STEP 2B: QRIS ======
  Widget _buildQrisStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Qris',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/qris_example.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) {
                  return const Center(
                    child: Text('QRIS CODE', style: TextStyle(fontSize: 16)),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Silakan scan QRIS di atas\nmenggunakan e-wallet / mBanking Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.goToNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Lanjutkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ====== STEP 3: Upload bukti ======
  Widget _buildUploadProofStep() {
    final file = controller.proofFile.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.method.value == 'transfer'
              ? 'Upload Bukti Transfer'
              : 'Upload Bukti Pembayaran QRIS',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Text(
                controller.formatRupiah(controller.totalPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Metode: ${controller.method.value == 'transfer' ? 'Transfer Bank (${controller.selectedBank.value})' : 'QRIS'}',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Upload bukti pembayaran',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: controller.pickProof,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
              color: Colors.white,
            ),
            child: Row(
              children: [
                const Icon(Icons.upload_file, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    file == null ? 'Pilih gambar bukti pembayaran' : file.name,
                    style: TextStyle(
                      fontSize: 13,
                      color: file == null ? Colors.grey[600] : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Format: jpg, png. Bisa berupa screenshot atau foto struk pembayaran.',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                controller.saving.value ? null : controller.confirmPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: controller.saving.value
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Saya sudah bayar',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  // ====== STEP 4: Sukses ======
  Widget _buildSuccessStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle, color: Colors.green, size: 72),
        const SizedBox(height: 20),
        const Text(
          'Booking Berhasil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Terima kasih atas booking-nya.\nPembayaran kamu akan dicek oleh admin.',
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Status akan berubah menjadi PAID\nsetelah admin memverifikasi bukti.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
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
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Kembali ke Beranda',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
