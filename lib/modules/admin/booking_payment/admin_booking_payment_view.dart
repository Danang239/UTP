import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'admin_booking_payment_viewmodel.dart';
import 'widgets/booking_table.dart';

class AdminBookingPaymentView extends GetView<AdminBookingPaymentViewModel> {
  const AdminBookingPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Booking dan Pembayaran',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Daftar booking villa dan status pembayarannya',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: BookingTable(),
          ),
        ],
      ),
    );
  }
}
