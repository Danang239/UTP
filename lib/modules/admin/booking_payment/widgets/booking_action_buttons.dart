import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../admin_booking_payment_viewmodel.dart';
import '../detail_booking/admin_booking_detail_view.dart';
import '../detail_booking/admin_booking_detail_viewmodel.dart';

class BookingActionButtons extends StatelessWidget {
  final AdminBookingItem booking;

  const BookingActionButtons({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<AdminBookingPaymentViewModel>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // DETAIL
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          onPressed: () {
            Get.to(
              () => const AdminBookingDetailView(),
              binding: AdminBookingDetailBinding(booking: booking),
            );
          },
          child: const Text('Detail'),
        ),
        const SizedBox(width: 8),

        // KONFIRMASI / BATALKAN KONFIRMASI
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          onPressed: () async {
            // Jika status masih pending, tampilkan konfirmasi untuk mengonfirmasi booking
            if (booking.status == 'pending') {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Booking'),
                  content: Text(
                    'Apakah Anda yakin ingin MENGKONFIRMASI booking ini?\n\n'
                    'Total: Rp ${_formatCurrency(booking.totalPrice)}\n'
                    'Biaya admin 10% dan pendapatan owner akan dihitung otomatis.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Ya, Konfirmasi'),
                    ),
                  ],
                ),
              ) ?? false;

              if (!ok) return;

              // Konfirmasi booking
              await vm.confirmBooking(booking);
            }
            // Jika status sudah confirmed, tampilkan konfirmasi untuk membatalkan konfirmasi
            else if (booking.status == 'confirmed') {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Batalkan Konfirmasi?'),
                  content: Text(
                    'Apakah Anda yakin ingin membatalkan konfirmasi booking ini?\n\n'
                    'Total: Rp ${_formatCurrency(booking.totalPrice)}',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Ya, Batalkan'),
                    ),
                  ],
                ),
              ) ?? false;

              if (!ok) return;

              // Batalkan konfirmasi booking
              await vm.setPending(booking);
            }
          },
          child: Text(booking.status == 'confirmed' ? 'Batalkan Konfirmasi' : 'Konfirmasi'),
        ),
      ],
    );
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
}
