// lib/modules/admin/pages/admin_pages.dart

import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/booking_payment/admin_booking_payment_binding.dart';
import 'package:utp_flutter/modules/admin/booking_payment/admin_booking_payment_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/data_owner/admin_data_owner_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/data_owner/admin_data_owner_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/data_villa/admin_data_villa_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/data_villa/admin_data_villa_view.dart';

// Dashboard admin
import '../admin_dashboard_viewmodel.dart';
import '../admin_dashboard_binding.dart';

// Data Villa (folder terpisah)
import '../data_villa/admin_data_villa_viewmodel.dart';

// Tambahan: kalau nanti mau tambahkan data user / booking / pesan
// tinggal import aja dari folder pages lain


class AdminRoutes {
  static const dashboard = '/admin/dashboard';
  static const dataVilla = '/admin/data-villa';
  // tinggal tambahin lagi:
  // static const dataUser = '/admin/data-user';
  // static const booking = '/admin/booking';
  // static const pesan = '/admin/pesan';
}

final List<GetPage> adminPages = [

  // Dashboard Admin
  GetPage(
    name: AdminRoutes.dashboard,
    page: () => const AdminDashboardView(),
    binding: DashboardBinding(),
  ),

  // Data Villa
  GetPage(
    name: AdminRoutes.dataVilla,
    page: () => const AdminDataVillaView(),
    binding: AdminDataVillaBinding(),
  ),
  GetPage(
    name: '/admin_data_owner',
    page: () => AdminDataOwnerView(),
    binding: AdminDataOwnerBinding(),  // Menghubungkan Binding
    ),
  GetPage(
  name: '/admin-booking',
  page: () => const AdminBookingPaymentView(),
  binding: AdminBookingPaymentBinding(),
),

  // tinggal nambah page lain di sini...
];

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Add your dependencies here
  }
}
