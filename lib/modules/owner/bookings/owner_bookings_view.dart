import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'owner_bookings_viewmodel.dart';

class OwnerBookingsView extends GetView<OwnerBookingsViewModel> {
  const OwnerBookingsView({super.key});

  /// Ambil nama user dari collection `users`
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
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Riwayat Booking',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
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

        final docs = controller.bookings;

        if (docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Belum ada booking untuk villa Anda',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
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
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= VILLA =================
                  Text(
                    villaName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          villaLocation,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // ================= TAMU =================
                  FutureBuilder<String>(
                    future: _getUserName(userId),
                    builder: (context, snapshot) {
                      final name = snapshot.data ?? userId;
                      return Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 16, color: Colors.black54),
                          const SizedBox(width: 6),
                          Text(
                            'Tamu: $name',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 6),

                  // ================= DATE =================
                  Row(
                    children: [
                      const Icon(Icons.date_range_outlined,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        dateText,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ================= PRICE =================
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Text(
                        'Total: Rp $totalPrice',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  if (ownerIncome > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            size: 16, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(
                          'Pendapatan Owner: Rp $ownerIncome',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ================= STATUS =================
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
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
