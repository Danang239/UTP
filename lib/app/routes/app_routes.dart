abstract class Routes {
  Routes._();

  // =====================
  // SPLASH
  // =====================
  static const splash = '/splash';

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
}
