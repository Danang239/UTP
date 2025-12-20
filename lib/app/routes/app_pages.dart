// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:utp_flutter/modules/user/search/search_binding.dart';
import 'package:utp_flutter/modules/user/search/search_view.dart';
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
import 'package:utp_flutter/modules/user/main/main_page.dart';
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
  static const initial = Routes.splash;

  static final routes = <GetPage>[
    // =====================
    // SPLASH (WAJIB PALING ATAS)
    // =====================
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 600),
    ),

    // =====================
    // AUTH
    // =====================
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // =====================
    // USER (🔥 HOME → MAIN PAGE)
    // =====================
    GetPage(
      name: Routes.home,
      page: () => const MainPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: Routes.chatbot,
      page: () => const ChatbotView(),
      binding: ChatbotBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.payment,
      page: () => const PaymentView(),
      binding: PaymentBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: Routes.chatRoom,
      page: () => const ChatRoomView(),
      binding: ChatRoomBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
      transition: Transition.upToDown,
    ),

    // =====================
    // ADMIN
    // =====================
    GetPage(
      name: Routes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.adminMessages,
      page: () => const AdminMessagesView(),
      binding: AdminMessagesBinding(),
      transition: Transition.rightToLeft,
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
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.ownerProfile,
      page: () => const OwnerProfileView(),
      binding: OwnerProfileBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
