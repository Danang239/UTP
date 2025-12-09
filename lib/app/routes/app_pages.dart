// lib/app/routes/app_pages.dart

import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/data_villa/admin_data_villa_binding.dart';
import 'package:utp_flutter/modules/admin/data_villa/admin_data_villa_view.dart';
import 'package:utp_flutter/modules/home/home_binding.dart';
import 'package:utp_flutter/modules/home/home_view.dart';
// import auth binding dll nanti
import 'package:utp_flutter/modules/auth/login_binding.dart';
import 'package:utp_flutter/modules/auth/login_view.dart';

import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_binding.dart';

import 'package:utp_flutter/modules/owner/owner_dashboard_view.dart';
import 'package:utp_flutter/modules/owner/owner_dashboard_binding.dart';

import 'package:utp_flutter/modules/admin/admin_messages/admin_messages_view.dart';
import 'package:utp_flutter/modules/admin/admin_messages/admin_messages_binding.dart';



import 'app_routes.dart';

class AppPages {
  static const initial = Routes.login;

  static final routes = <GetPage>[
    // HALAMAN LOGIN
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    // HALAMAN HOME (USER)
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // HALAMAN DASHBOARD ADMIN
    GetPage(
      name: Routes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: Routes.ownerDashboard,
      page: () => const OwnerDashboardView(),
      binding: OwnerDashboardBinding(),
    ),

    GetPage(
      name: Routes.adminMessages,
      page: () => const AdminMessagesView(),
      binding: AdminMessagesBinding(),
    ),

GetPage(
  name: Routes.adminDataVilla,
  page: () => const AdminDataVillaView(),
  binding: AdminDataVillaBinding(),
),

    // GetPage(
    //   name: Routes.login,
    //   page: () => const LoginView(),
    //   binding: LoginBinding(),
    // ),
  ];
}
