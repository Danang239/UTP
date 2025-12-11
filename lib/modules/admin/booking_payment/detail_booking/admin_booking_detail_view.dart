import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../admin_booking_payment_viewmodel.dart';
import '../widgets/booking_proof_dialog.dart';
import 'admin_booking_detail_viewmodel.dart';

class AdminBookingDetailView extends GetView<AdminBookingDetailViewModel> {
  const AdminBookingDetailView({super.key});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String _formatCurrency(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buffer.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final AdminBookingItem b = controller.booking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Booking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USER
            const Text(
              'Data User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _detailRow('Nama', b.customerName),
            _detailRow('Email', b.customerEmail),
            _detailRow('No Telepon', b.customerPhone),
            const SizedBox(height: 16),

            // VILLA
            const Text(
              'Data Villa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _detailRow('Nama Villa', b.villaName),
            _detailRow('Lokasi', b.villaLocation),
            _detailRow('Check-in', _formatDate(b.checkIn)),
            _detailRow('Check-out', _formatDate(b.checkOut)),
            const SizedBox(height: 16),

            // PAYMENT
            const Text(
              'Pembayaran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _detailRow('Metode', b.paymentMethod),
            // ⬇️ pakai field bank biasa
            _detailRow('Bank/E-Wallet', b.bank.isEmpty ? '-' : b.bank),
            _detailRow('Total', _formatCurrency(b.totalPrice)),
            _detailRow('Biaya admin 10%', _formatCurrency(b.adminFee)),
            _detailRow('Pendapatan owner', _formatCurrency(b.ownerIncome)),
            _detailRow('Status Pembayaran', b.paymentStatus),
            _detailRow('Status Booking', b.status),
            _detailRow('Dibuat pada', _formatDate(b.createdAt)),
            const SizedBox(height: 16),

            // PROOF
            const Text(
              'Bukti Transfer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                BookingProofDialog.show(
                  context,
                  url: b.paymentProofUrl,
                  fileName: b.paymentProofFileName,
                );
              },
              child: const Text('Lihat Bukti'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
