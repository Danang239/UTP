import 'package:flutter/material.dart';

class BookingProofDialog {
  /// Panggil:
  /// BookingProofDialog.show(
  ///   context,
  ///   url: b.paymentProofUrl,
  ///   fileName: b.paymentProofFileName,
  /// );
  static Future<void> show(
    BuildContext context, {
    required String? url,
    required String? fileName,
  }) async {
    final safeUrl = url ?? '';
    final safeName = fileName ?? '-';

    // Kalau belum ada bukti upload
    if (safeUrl.isEmpty) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bukti Transfer'),
          content: const Text('Bukti transfer belum diupload oleh user.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }

    return showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: SizedBox(
            width: 600,
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Bukti Transfer ($safeName)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Gambar
                Expanded(
                  child: Center(
                    child: Image.network(
                      safeUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text(
                        'Gagal memuat gambar.',
                        style: TextStyle(color: Colors.red),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
                ),

                // Tombol tutup
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Tutup'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
