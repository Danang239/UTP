import 'package:flutter/material.dart';
import '../admin_data_user_viewmodel.dart';

class UserStatusCell extends StatelessWidget {
  final AdminUserItem user;

  const UserStatusCell({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final statusText = user.isActive
        ? (user.isCurrentlyBanned ? 'Banned sementara' : 'Aktif')
        : 'Blokir permanen';

    final bannedInfo = user.isCurrentlyBanned
        ? 'sampai ${user.bannedUntil!.day}/${user.bannedUntil!.month}/${user.bannedUntil!.year}'
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(statusText),
        if (bannedInfo.isNotEmpty)
          Text(
            bannedInfo,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
      ],
    );
  }
}
