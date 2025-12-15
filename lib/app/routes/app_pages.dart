// lib/app/routes/app_pages.dart

import 'package:get/get.dart';
import 'app_routes.dart';

// =====================
// SPLASH
// =====================
import 'package:utp_flutter/modules/splash/splash_view.dart';

// =====================
// AUTH
// =====================
import 'package:utp_flutter/modules/auth/login_binding.dart';
import 'package:utp_flutter/modules/auth/login_view.dart';
import 'package:utp_flutter/modules/auth/register_binding.dart';
import 'package:utp_flutter/modules/auth/register_view.dart';

// =====================
// USER
// =====================
import 'package:utp_flutter/modules/user/home/home_binding.dart';
import 'package:utp_flutter/modules/user/home/home_view.dart';
import 'package:utp_flutter/modules/user/chatbot/chatbot_binding.dart';
import 'package:utp_flutter/modules/user/chatbot/chatbot_view.dart';
import 'package:utp_flutter/modules/user/payment/payment_binding.dart';
import 'package:utp_flutter/modules/user/payment/payment_view.dart';
import 'package:utp_flutter/modules/user/chat_room/chat_room_binding.dart';
import 'package:utp_flutter/modules/user/chat_room/chat_room_view.dart';

// =====================
// ADMIN
// =====================
import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_view.dart';
import 'package:utp_flutter/modules/admin/admin_messages/admin_messages_binding.dart';
import 'package:utp_flutter/modules/admin/admin_messages/admin_messages_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/data_villa/admin_data_villa_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/data_villa/admin_data_villa_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_data_owner_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/admin_data_owner_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/detail_owner/admin_owner_detail_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/detail_owner/admin_owner_detail_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/edit_owner/admin_owner_edit_binding.dart';
import 'package:utp_flutter/modules/admin/dashboard/bikin_owner/edit_owner/admin_owner_edit_view.dart';

// =====================
// OWNER
// =====================
import 'package:utp_flutter/modules/owner/owner_dashboard_binding.dart';
import 'package:utp_flutter/modules/owner/owner_dashboard_view.dart';
import 'package:utp_flutter/modules/owner/profile/profile_binding.dart';
import 'package:utp_flutter/modules/owner/profile/profile_view.dart';

class AppPages {
  static const initial = Routes.splash; // 🔥 PENTING

  static final routes = <GetPage>[
    // =====================
    // SPLASH (SESSION GATE)
    // =====================
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
    ),

    // =====================
    // AUTH
    // =====================
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),

    // =====================
    // USER
    // =====================
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.chatbot,
      page: () => const ChatbotView(),
      binding: ChatbotBinding(),
    ),
    GetPage(
      name: Routes.payment,
      page: () => const PaymentView(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: Routes.chatRoom,
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
      name: Routes.adminDataOwner,
      page: () => AdminDataOwnerView(),
      binding: AdminDataOwnerBinding(),
    ),
    GetPage(
      name: Routes.adminOwnerDetail,
      page: () => AdminOwnerDetailView(),
      binding: AdminOwnerDetailBinding(),
    ),
    GetPage(
      name: Routes.adminOwnerEdit,
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
      name: Routes.ownerProfile,
      page: () => const OwnerProfileView(),
      binding: OwnerProfileBinding(),
    ),
  ];
}
