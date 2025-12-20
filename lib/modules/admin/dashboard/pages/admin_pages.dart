// lib/modules/admin/pages/admin_pages.dart

import 'package:get/get.dart';
import 'package:utp_flutter/modules/admin/admin_chat/admin_chat_binding.dart';
import 'package:utp_flutter/modules/admin/admin_chat/admin_chat_view.dart';

// =====================
// DASHBOARD
// =====================
import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_view.dart';
import 'package:utp_flutter/modules/admin/dashboard/admin_dashboard_binding.dart';

// =====================
// CHAT (ADMIN ↔ USER)
// =====================
import 'package:utp_flutter/modules/user/chat_admin/user_chat_view.dart';
import 'package:utp_flutter/modules/user/chat_admin/user_chat_binding.dart';

// =====================
// ROUTE NAME
// =====================
class AdminRoutes {
  static const dashboard = '/admin-dashboard';
  static const chatRoom = '/admin-chat';
}

final List<GetPage> adminPages = [
  // =====================
  // ADMIN DASHBOARD
  // =====================
  GetPage(
    name: AdminRoutes.dashboard,
    page: () => const AdminDashboardView(),
    binding: AdminDashboardBinding(),
  ),

  // =====================
  // CHAT ROOM (DETAIL)
  // =====================
  GetPage(
    name: AdminRoutes.chatRoom,
    page: () => const AdminChatView(),
    binding: AdminChatBinding(),
  ),
];
