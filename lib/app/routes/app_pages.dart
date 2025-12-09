// lib/app/routes/app_pages.dart

import 'package:get/get.dart';

// ADMIN
import 'package:utp_flutter/modules/admin/data_villa/admin_data_villa_binding.dart';
import 'package:utp_flutter/modules/admin/data_villa/admin_data_villa_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_view.dart';
import 'package:utp_flutter/modules/admin/admin_messages/admin_messages_binding.dart';
import 'package:utp_flutter/modules/admin/admin_messages/admin_messages_view.dart';

// OWNER
import 'package:utp_flutter/modules/owner/owner_dashboard_binding.dart';
import 'package:utp_flutter/modules/owner/owner_dashboard_view.dart';
import 'package:utp_flutter/modules/owner/profile/profile_binding.dart';
import 'package:utp_flutter/modules/owner/profile/profile_view.dart';

// USER – HOME
import 'package:utp_flutter/modules/user/home/home_binding.dart';
import 'package:utp_flutter/modules/user/home/home_view.dart';

// AUTH
import 'package:utp_flutter/modules/auth/login_binding.dart';
import 'package:utp_flutter/modules/auth/login_view.dart';

// USER – PAYMENT (BOOKING)
import 'package:utp_flutter/modules/user/payment/payment_binding.dart';
import 'package:utp_flutter/modules/user/payment/payment_view.dart';

// USER – CHAT ROOM
import 'package:utp_flutter/modules/user/chat_room/chat_room_binding.dart';
import 'package:utp_flutter/modules/user/chat_room/chat_room_view.dart';

import 'app_routes.dart';

class AppPages {
  static const initial = Routes.login;

  static final routes = <GetPage>[
    // =====================
    // AUTH
    // =====================
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    // =====================
    // USER
    // =====================
    // HALAMAN HOME (USER)
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // HALAMAN PAYMENT (dipanggil dari DetailViewModel: Get.toNamed('/payment'))
    // pakai nama string '/payment' karena di DetailViewModel hard-coded seperti itu
    GetPage(
      name: '/payment',
      page: () => const PaymentView(),
      binding: PaymentBinding(),
    ),

    // HALAMAN CHAT ROOM (dipanggil: Get.toNamed('/chat-room'))
    GetPage(
      name: '/chat-room',
      page: () => const ChatRoomView(),
      binding: ChatRoomBinding(),
    ),

    // =====================
    // ADMIN
    // =====================
    GetPage(
      name: Routes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
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

    // =====================
    // OWNER
    // =====================
    GetPage(
      name: Routes.ownerDashboard,
      page: () => const OwnerDashboardView(),
      binding: OwnerDashboardBinding(),
    ),

    // HALAMAN PROFILE OWNER
    // (bisa dipanggil dengan Get.toNamed('/owner-profile'))
    GetPage(
      name: '/owner-profile',
      page: () => const OwnerProfileView(),
      binding: OwnerProfileBinding(),
    ),
  ];
}
