import 'package:flutter/material.dart';

class BookingStatusBadge extends StatelessWidget {
  final String status;

  const BookingStatusBadge({super.key, required this.status});

  Color _backgroundColor() {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFC83A); // kuning
      case 'proses':
      case 'process':
        return const Color(0xFF03A9F4); // biru muda
      case 'dikirim':
        return const Color(0xFF9C27B0); // ungu
      case 'confirmed':
        return const Color(0xFF4CAF50); // hijau
      case 'cancelled':
        return const Color(0xFFFF4D4D); // merah
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
