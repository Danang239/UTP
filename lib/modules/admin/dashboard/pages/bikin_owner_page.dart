import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bikin_owner/admin_data_owner_view.dart';  // Gantilah dengan path yang sesuai
import '../bikin_owner/admin_data_owner_viewmodel.dart';  // Gantilah dengan path yang sesuai

class BikinOwnerPage extends StatelessWidget {
  BikinOwnerPage({super.key}) {
    // Mendaftarkan ViewModel untuk Data Owner
    Get.put(AdminDataOwnerViewModel(), permanent: false);
  }

  @override
  Widget build(BuildContext context) {

    return AdminDataOwnerView();  // Menampilkan AdminDataOwnerView
  }
}
