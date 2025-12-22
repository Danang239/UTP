// lib/app/routes/app_routes.dart
abstract class Routes {
  Routes._();

  // =====================
  // SPLASH (ROOT)
  // =====================
  static const splash = '/';

  // =====================
  // AUTH
  // =====================
  static const login = '/login';
  static const register = '/register';

  // =====================
  // USER
  // =====================
  static const home = '/home';
  static const chatbot = '/chatbot';
  static const payment = '/payment';
  static const chatRoom = '/chat-room';
  static const search = '/search';

  // =====================
  // CHAT USER ↔ ADMIN
  // =====================
  static const adminChat = '/admin-chat';
  static const userChatAdmin = '/user-chat-admin';

  // =====================
  // ADMIN
  // =====================
  static const adminDashboard = '/admin-dashboard';
  static const adminMessages = '/admin-messages';
  static const adminDataVilla = '/admin-data-villa';
  static const adminDataOwner = '/admin-data-owner';
  static const adminOwnerDetail = '/admin-owner-detail';
  static const adminOwnerEdit = '/admin-owner-edit';

  // =====================
  // OWNER
  // =====================
  static const ownerDashboard = '/owner-dashboard';
  static const ownerProfile = '/owner-profile';

  // 🔥 OWNER - VILLA (WAJIB ADA)
  static const ownerVilla = '/owner-villa';
}
