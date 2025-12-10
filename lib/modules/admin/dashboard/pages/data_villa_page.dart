import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data_villa/admin_data_villa_view.dart';
import '../data_villa/admin_data_villa_viewmodel.dart';

class DataVillaPage extends StatelessWidget {
  DataVillaPage({super.key}) {
    // register viewmodel
    Get.put(AdminDataVillaViewModel(), permanent: false);
  }

  @override
  Widget build(BuildContext context) {
    return const AdminDataVillaView();
  }
}
