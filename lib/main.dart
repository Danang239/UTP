// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app_session.dart';

// AUTH
import 'modules/auth/login_binding.dart';
import 'modules/auth/register_binding.dart';

// USER BINDINGS
import 'modules/user/home/home_binding.dart';
import 'modules/user/favorite/favorite_binding.dart';
import 'modules/user/pesan/pesan_binding.dart';
import 'modules/user/profile/profile_binding.dart';

// THEME
import 'app/theme/theme_controller.dart';

// ============================================================
// ========================== MAIN =============================
// ============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =====================
  // SUPABASE
  // =====================
  await Supabase.initialize(
    url: 'https://avztxkkbefvxfftvodui.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2enR4a2tiZWZmdHZvZHVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzOTMzMjUsImV4cCI6MjA3OTk2OTMyNX0.liN7spnWnbKUXsKPS6IgbN5z09AR0gD61bwpLoi5aTE',
  );
  // =========================
  // 🔎 TEST SUPABASE STORAGE (SEMENTARA)
  // =========================
  try {
    final list = await Supabase.instance.client.storage
        .from('profile')
        .list();
    print('SUPABASE STORAGE OK: $list');
  } catch (e) {
    print('SUPABASE STORAGE ERROR: $e');
  }
  // =========================

  runApp(const MyApp());
  // =====================
  // FIREBASE
  // =====================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // =====================
  // GLOBAL BINDINGS
  // =====================
  LoginBinding().dependencies();
  RegisterBinding().dependencies();
  HomeBinding().dependencies();
  FavoriteBinding().dependencies();
  PesanBinding().dependencies();
  ProfileBinding().dependencies();

  // =====================
  // THEME CONTROLLER (GLOBAL)
  // =====================
  Get.put(ThemeController(), permanent: true);

  runApp(const MyApp());
}

// ============================================================
// ========================== APP ==============================
// ============================================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeC = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Stay&Co',
        debugShowCheckedModeBanner: false,

        // =====================
        // ROUTING
        // =====================
        initialRoute: Routes.splash,
        getPages: AppPages.routes,

        // =====================
        // THEME (🔥 FIX UTAMA)
        // =====================
        theme: themeC.lightTheme,
        darkTheme: themeC.darkTheme,
        themeMode:
            themeC.isDark ? ThemeMode.dark : ThemeMode.light, // ✅ FIX

      ),
    );
  }
}
