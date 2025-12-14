// lib/app/routes/app_pages.dart

import 'package:get/get.dart';

// =====================
// ADMIN
// =====================
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_data_owner_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_data_owner_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/detail_owner/admin_owner_detail_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/detail_owner/admin_owner_detail_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/edit_owner/admin_owner_edit_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/edit_owner/admin_owner_edit_binding.dart';

import 'package:utp_flutter/modules/admin/dashboard/data_villa/admin_data_villa_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/data_villa/admin_data_villa_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_view.dart';
import 'package:utp_flutter/modules/admin/admin_messages/admin_messages_binding.dart';
import 'package:utp_flutter/modules/admin/admin_messages/admin_messages_view.dart';

// =====================
// OWNER
// =====================
import 'package:utp_flutter/modules/owner/owner_dashboard_binding.dart';
import 'package:utp_flutter/modules/owner/owner_dashboard_view.dart';
import 'package:utp_flutter/modules/owner/profile/profile_binding.dart';
import 'package:utp_flutter/modules/owner/profile/profile_view.dart';

// =====================
// USER
// =====================

// HOME
import 'package:utp_flutter/modules/user/home/home_binding.dart';
import 'package:utp_flutter/modules/user/home/home_view.dart';

// CHATBOT ✅ (BARU – FOKUS PERBAIKAN)
import 'package:utp_flutter/modules/user/chatbot/chatbot_binding.dart';
import 'package:utp_flutter/modules/user/chatbot/chatbot_view.dart';

// PAYMENT
import 'package:utp_flutter/modules/user/payment/payment_binding.dart';
import 'package:utp_flutter/modules/user/payment/payment_view.dart';

// CHAT ROOM
import 'package:utp_flutter/modules/user/chat_room/chat_room_binding.dart';
import 'package:utp_flutter/modules/user/chat_room/chat_room_view.dart';

// =====================
// AUTH
// =====================
import 'package:utp_flutter/modules/auth/login_binding.dart';
import 'package:utp_flutter/modules/auth/login_view.dart';

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

    // HOME USER
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // 🔥 CHATBOT (DITAMBAHKAN – TIDAK MENGGANGGU ROUTE LAIN)
    GetPage(
      name: '/chatbot', // HARUS SAMA dengan Get.toNamed('/chatbot')
      page: () => const ChatbotView(),
      binding: ChatbotBinding(),
    ),

    // PAYMENT
    GetPage(
      name: '/payment',
      page: () => const PaymentView(),
      binding: PaymentBinding(),
    ),

    // CHAT ROOM
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
      page: () => AdminDashboardView(),
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
    GetPage(
      name: '/admin_data_owner',
      page: () => AdminDataOwnerView(),
      binding: AdminDataOwnerBinding(),
    ),
    GetPage(
      name: '/ownerDetail',
      page: () => AdminOwnerDetailView(),
      binding: AdminOwnerDetailBinding(),
    ),
    GetPage(
      name: '/editOwner',
      page: () => AdminOwnerEditView(),
      binding: AdminOwnerEditBinding(),
    ),

    // =====================
    // OWNER
    // =====================
    GetPage(
      name: Routes.ownerDashboard,
      page: () => const OwnerDashboardView(),
      binding: OwnerDashboardBinding(),
    ),
    GetPage(
      name: '/owner-profile',
      page: () => const OwnerProfileView(),
      binding: OwnerProfileBinding(),
    ),
  ];
}
