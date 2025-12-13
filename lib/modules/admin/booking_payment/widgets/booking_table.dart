import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../admin_booking_payment_viewmodel.dart';
import 'booking_action_buttons.dart';
import 'booking_status_badge.dart';
import 'booking_proof_dialog.dart';

class BookingTable extends GetView<AdminBookingPaymentViewModel> {
  const BookingTable({super.key});

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
        buffer.write('.'); // Separator ribuan
      }
    }
    return 'Rp ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Text(
            'Terjadi kesalahan:\n${controller.errorMessage.value}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      final items = controller.bookings;
      if (items.isEmpty) {
        return const Center(
          child: Text('Belum ada data booking.'),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              offset: Offset(0, 2),
              color: Colors.black12,
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              const Color(0xFFF4F0FF),
            ),
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Nama Villa')),  // Kolom pertama Nama Villa
              DataColumn(label: Text('Nama')),        // Kolom kedua Nama
              DataColumn(label: Text('Metode')),
              DataColumn(label: Text('Bank/E-Wallet')),
              DataColumn(label: Text('Bukti Transfer')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Biaya admin 10%')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Tanggal Pesan')),  // Kolom Tanggal Pesan
              DataColumn(label: Text('Pemilik')),    // Kolom Pemilik
              DataColumn(label: Text('Aksi')),
            ],
            rows: items.map((b) {
              return DataRow(
                cells: [
                  DataCell(Text(b.villaName)),  // Nama Villa di posisi pertama
                  DataCell(Text(b.customerName)),  // Nama di posisi kedua
                  DataCell(Text(b.paymentMethod)),
                  DataCell(Text(b.bank.isEmpty ? '-' : b.bank)),
                  DataCell(
                    TextButton(
                      onPressed: () {
                        BookingProofDialog.show(
                          context,
                          url: b.paymentProofUrl,
                          fileName: b.paymentProofFileName,
                        );
                      },
                      child: const Text('Lihat'),
                    ),
                  ),
                  DataCell(Text(_formatCurrency(b.totalPrice))),
                  DataCell(Text(_formatCurrency(b.adminFee))),
                  DataCell(BookingStatusBadge(status: b.status)),
                  DataCell(Text(_formatDate(b.checkIn))),  // Menampilkan Tanggal Pesan
                  DataCell(Text(b.ownerId)),    // Menampilkan Pemilik
                  DataCell(BookingActionButtons(booking: b)),
                ],
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}
