import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'owner_bookings_viewmodel.dart';

class OwnerBookingsView extends GetView<OwnerBookingsViewModel> {
  const OwnerBookingsView({super.key});

  /// Ambil nama user dari collection `users`
  /// fallback ke userId kalau gagal
  Future<String> _getUserName(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        return data?['name'] ?? userId;
      }
      return userId;
    } catch (e) {
      return userId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Riwayat Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // ERROR
        if (controller.errorMessage.value != null) {
          return Center(
            child: Text(controller.errorMessage.value!),
          );
        }

        // LOADING
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = controller.bookings;

        // EMPTY STATE
        if (docs.isEmpty) {
          return const Center(
            child: Text('Belum ada booking untuk villa Anda.'),
          );
        }

        // LIST DATA
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            final villaName = data['villa_name'] ?? '-';
            final villaLocation = data['villa_location'] ?? '-';
            final userId = data['user_id']?.toString() ?? '-';

            final status = data['status'] ?? 'pending';
            final paymentStatus = data['payment_status'] ?? '-';

            DateTime? checkIn;
            DateTime? checkOut;

            if (data['check_in'] is Timestamp) {
              checkIn = (data['check_in'] as Timestamp).toDate();
            }
            if (data['check_out'] is Timestamp) {
              checkOut = (data['check_out'] as Timestamp).toDate();
            }

            String dateText = '-';
            if (checkIn != null && checkOut != null) {
              dateText =
                  '${checkIn.day}/${checkIn.month}/${checkIn.year} - '
                  '${checkOut.day}/${checkOut.month}/${checkOut.year}';
            }

            final totalPrice = data['total_price'] ?? 0;
            final ownerIncome = data['owner_income'] ?? 0;

            Color statusColor;
            switch (status) {
              case 'confirmed':
                statusColor = Colors.green;
                break;
              case 'cancelled':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.orange;
            }

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // VILLA
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
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TAMU (NAMA USER)
                  FutureBuilder<String>(
                    future: _getUserName(userId),
                    builder: (context, snapshot) {
                      final name = snapshot.data ?? userId;
                      return Text(
                        'Tamu: $name',
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                  ),

                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    style: const TextStyle(fontSize: 13),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'Total: Rp $totalPrice',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (ownerIncome > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Pendapatan owner: Rp $ownerIncome',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // STATUS
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Pembayaran: $paymentStatus',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
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
