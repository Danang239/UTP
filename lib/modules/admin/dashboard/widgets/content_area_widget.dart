import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/booking_payment/admin_booking_payment_view.dart';

import '../admin_dashboard_viewmodel.dart';

// PAGES
import '../../dashboard/pages/dashboard_page.dart';
import '../../dashboard/pages/data_villa_page.dart';
import '../../dashboard/pages/data_user_page.dart';
import '../../dashboard/pages/booking_page.dart';
import '../../dashboard/pages/pesan_page.dart';
import '../../dashboard/pages/bikin_owner_page.dart';

class ContentAreaWidget extends GetView<AdminDashboardViewModel> {
  const ContentAreaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.selectedMenuIndex.value;

      // ini adalah child yang nanti ditampilkan sesuai menu
      Widget child;

      switch (index) {
        case 0:
          child = const DashboardPage();
          break;

        case 1:
          // PENTING: DataVillaPage TIDAK boleh const
          child = DataVillaPage();
          break;

        case 2:
          child = const DataUserPage();
          break;

        case 3:
          child = const AdminBookingPaymentView();
          break;

        case 4:
          child = const PesanPage();
          break;

        case 5:
          child = BikinOwnerPage();
          break;

        default:
          child = const DashboardPage();
      }

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );
    });
  }
}
