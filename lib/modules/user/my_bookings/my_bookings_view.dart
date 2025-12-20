import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_bookings_viewmodel.dart';

class MyBookingsView extends GetView<MyBookingsViewModel> {
  const MyBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Pesanan Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),

      body: Obx(() {
        if (controller.errorMessage.value != null) {
          return Center(
            child: Text(
              controller.errorMessage.value!,
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.bookings.isEmpty) {
          return Center(
            child: Text(
              "Anda belum memiliki pesanan",
              style: theme.textTheme.bodyMedium,
            ),
          );
        }

        final docs = controller.bookings;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            final villaName = data['villa_name'] ?? 'Tanpa Nama';
            final villaLocation = data['villa_location'] ?? '-';
            final status = (data['status'] ?? 'pending').toString();

            final checkIn = (data['check_in'] as Timestamp?)?.toDate();
            final checkOut = (data['check_out'] as Timestamp?)?.toDate();

            String dateText = '-';
            if (checkIn != null && checkOut != null) {
              dateText =
                  '${checkIn.day}/${checkIn.month}/${checkIn.year}  -  '
                  '${checkOut.day}/${checkOut.month}/${checkOut.year}';
            }

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== NAMA VILLA =====
                  Text(
                    villaName,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ===== LOKASI =====
                  Text(
                    villaLocation,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ===== TANGGAL =====
                  Text(
                    dateText,
                    style: theme.textTheme.bodySmall,
                  ),

                  const SizedBox(height: 10),

                  // ===== STATUS =====
                  _statusChip(context, status),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // ===============================
  //  STATUS CHIP (THEME AWARE)
  // ===============================
  Widget _statusChip(BuildContext context, String status) {
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor = theme.colorScheme.onPrimary;

    switch (status.toLowerCase()) {
      case 'selesai':
        bgColor = Colors.green;
        break;
      case 'proses':
        bgColor = Colors.orange;
        break;
      case 'dibatalkan':
        bgColor = Colors.red;
        break;
      default:
        bgColor = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
