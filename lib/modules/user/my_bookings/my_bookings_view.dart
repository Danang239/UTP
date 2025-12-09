import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_bookings_viewmodel.dart';

class MyBookingsView extends GetView<MyBookingsViewModel> {
  const MyBookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pesanan Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Obx(() {
        if (controller.errorMessage.value != null) {
          return Center(
            child: Text(controller.errorMessage.value!),
          );
        }

        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.bookings.isEmpty) {
          return const Center(
            child: Text("Anda belum memiliki pesanan"),
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
            final status = data['status'] ?? 'pending';

            final checkIn = (data['check_in'] as Timestamp?)?.toDate();
            final checkOut = (data['check_out'] as Timestamp?)?.toDate();

            String dateText = '-';
            if (checkIn != null && checkOut != null) {
              dateText =
                  '${checkIn.day}/${checkIn.month}/${checkIn.year}  -  '
                  '${checkOut.day}/${checkOut.month}/${checkOut.year}';
            }

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    villaName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    villaLocation,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dateText,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Status: $status",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
