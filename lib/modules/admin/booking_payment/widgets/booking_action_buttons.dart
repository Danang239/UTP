import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/booking_payment/detail_booking/admin_booking_detail_view.dart';

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

        // KONFIRM / EDIT
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          onPressed: () async {
            final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Konfirmasi Booking'),
                    content: Text(
                      'Apakah Anda yakin ingin MENGKONFIRMASI booking ini?\n\n'
                      'Total: Rp ${booking.totalPrice}\n'
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
                ) ??
                false;

            if (!ok) return;

            await vm.confirmBooking(booking);
          },
          child: Text(booking.isConfirmed ? 'Edit' : 'Confirm'),
        ),
      ],
    );
  }
}
