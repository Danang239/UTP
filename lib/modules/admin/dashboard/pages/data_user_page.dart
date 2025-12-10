import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data_user/admin_data_user_view.dart';
import '../data_user/admin_data_user_viewmodel.dart';

class DataUserPage extends StatelessWidget {
  const DataUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    // pastikan ViewModel ter-inject saat halaman ini dibuat
    Get.put(AdminDataUserViewModel(), permanent: false);

    return const AdminDataUserView();
  }
}
