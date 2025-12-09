// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utp_flutter/app/routes/app_pages.dart';

import 'firebase_options.dart';

// ==== MODULES GETX ====

// Auth
import 'modules/auth/login_binding.dart';
import 'modules/auth/login_view.dart';
import 'modules/auth/register_binding.dart';
import 'modules/auth/register_view.dart';

// OTP (MODULE BARU)
import 'modules/auth/otp/otp_binding.dart';
import 'modules/auth/otp/otp_view.dart';

// Home
import 'modules/user/home/home_binding.dart';
import 'modules/user/home/home_view.dart';

// Favorite
import 'modules/user/favorite/favorite_binding.dart';
import 'modules/user/favorite/favorite_view.dart';

// Pesan
import 'modules/user/pesan/pesan_binding.dart';
import 'modules/user/pesan/pesan_view.dart';

// Search (dipakai dari HomeView)
import 'modules/user/search/search_binding.dart';

// Profile (MVVM + GetX)
import 'modules/user/profile/profile_binding.dart';
import 'modules/user/profile/profile_view.dart';

// Chatbot (MODULE BARU MVVM + GetX)
import 'modules/user/chatbot/chatbot_binding.dart';
import 'modules/user/chatbot/chatbot_view.dart';

// Payment (MODULE BARU MVVM + GetX)
import 'modules/user/payment/payment_binding.dart';
import 'modules/user/payment/payment_view.dart';

// Chat room
import 'modules/user/chat_room/chat_room_binding.dart';
import 'modules/user/chat_room/chat_room_view.dart';

// ==== PAGE LAMA ====
// Sudah TIDAK dipakai lagi, termasuk otp_page.dart
// import 'pages/otp_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INIT SUPABASE
  await Supabase.initialize(
    url: 'https://avztxkkbefvxfftvodui.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2enR4a2tiZWZ2eGZmdHZvZHVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzOTMzMjUsImV4cCI6MjA3OTk2OTMyNX0.liN7spnWnbKUXsKPS6IgbN5z09AR0gD61bwpLoi5aTE',
  );

  // INIT FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ==== REGISTER BINDING GLOBAL (ViewModel) ====
  LoginBinding().dependencies(); // LoginViewModel
  RegisterBinding().dependencies(); // RegisterViewModel
  HomeBinding().dependencies(); // HomeViewModel
  FavoriteBinding().dependencies(); // FavoriteViewModel
  PesanBinding().dependencies(); // PesanViewModel
  SearchBinding().dependencies(); // SearchViewModel
  ProfileBinding().dependencies(); // ProfileViewModel
  // NOTE:
  // ChatbotBinding, PaymentBinding, ChatRoomBinding, OtpBinding
  // di-handle lewat GetPage (route '/chatbot', '/payment', '/chat-room', '/otp').

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Stay&Co',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // ==== THEME GLOBAL ====
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
        canvasColor: Colors.white,
        useMaterial3: false,
      ),

      // ==== HALAMAN AWAL (LOGIN, pakai modules/auth/LoginView) ====
      home: const LoginView(),

      // ==== ROUTES BAWAAN FLUTTER MASIH BERFUNGSI ====
      routes: {
        '/main': (context) => const MainPage(),
      },
    );
  }
}

// ============================================================
// ================== MAIN PAGE (BOTTOM NAV) ==================
// ============================================================
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // Semua tab pakai MODULES (MVVM + GetX)
  final List<Widget> pages = const [
    HomeView(), // Home modules/home
    FavoriteView(), // Favorite modules/favorite
    PesanView(), // Pesan modules/pesan
    ProfileView(), // Profile modules/profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Favorit",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Pesan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
