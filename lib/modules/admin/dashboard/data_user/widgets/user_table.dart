import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../admin_data_user_viewmodel.dart';
import 'user_status_cell.dart';
import 'user_action_buttons.dart';

class UserTable extends StatelessWidget {
  final List<AdminUserItem> users;

  const UserTable({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text("Belum ada user."));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 2),
            color: Colors.black12,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF4F0FF)),
          columns: const [
            DataColumn(label: Text('Nama')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('No Telepon')),
            DataColumn(label: Text('Alamat')),
            DataColumn(label: Text('Terdaftar Sejak')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Aksi')),
          ],
          rows: users.map((u) => DataRow(
            cells: [
              DataCell(Text(u.name)),
              DataCell(Text(u.email)),
              DataCell(Text(u.phone)),
              DataCell(Text(u.address)),
              DataCell(Text(_formatDate(u.createdAt))),
              DataCell(UserStatusCell(user: u)),
              DataCell(UserActionButtons(user: u)),
            ],
          )).toList(),
        ),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return "-";
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}
