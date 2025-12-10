import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../admin_data_user_viewmodel.dart';
import '../detail_user/admin_user_detail_view.dart';
import '../detail_user/admin_user_detail_binding.dart';

class UserActionButtons extends StatelessWidget {
  final AdminUserItem user;

  const UserActionButtons({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDataUserViewModel>();

    return Row(
      children: [
        // DETAIL USER
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Get.to(
              () => const AdminUserDetailView(),
              binding: AdminUserDetailBinding(),
              arguments: user,
            );
          },
          child: const Text("Detail"),
        ),

        const SizedBox(width: 8),

        // BAN SEMENTARA
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFFFC83A),
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final days = await _askBanDays(context);
            if (days != null && days > 0) {
              final ok = await _confirm(context, "Ban ${user.name} selama $days hari?");
              if (ok) await controller.banUserForDays(user, days);
            }
          },
          child: const Text("Ban"),
        ),

        const SizedBox(width: 8),

        // BLOKIR / AKTIFKAN
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: user.isActive ? const Color(0xFFFF4D4D) : const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final action = user.isActive ? "Blokir permanen" : "Aktifkan kembali";
            final ok = await _confirm(context, "$action akun ${user.name}?");
            if (ok) await controller.toggleActive(user);
          },
          child: Text(user.isActive ? "Blokir" : "Aktifkan"),
        ),
      ],
    );
  }

  // Dialog input hari ban
  Future<int?> _askBanDays(BuildContext context) async {
    final textCtrl = TextEditingController();

    final res = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Ban User"),
        content: TextField(
          controller: textCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Berapa hari?"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(c, textCtrl.text.trim()), child: const Text("OK")),
        ],
      ),
    );

    if (res == null) return null;
    return int.tryParse(res);
  }

  // Dialog konfirmasi yes/no
  Future<bool> _confirm(BuildContext context, String message) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Ya")),
        ],
      ),
    );

    return res ?? false;
  }
}
