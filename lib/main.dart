// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utp_flutter/app/routes/app_pages.dart';

import 'firebase_options.dart';

// AUTH
import 'modules/auth/login_binding.dart';
import 'modules/auth/login_view.dart';
import 'modules/auth/register_binding.dart';
import 'modules/auth/register_view.dart';

// HOME
import 'modules/user/home/home_binding.dart';
import 'modules/user/home/home_view.dart';

// FAVORITE
import 'modules/user/favorite/favorite_binding.dart';
import 'modules/user/favorite/favorite_view.dart';

// PESAN
import 'modules/user/pesan/pesan_binding.dart';
import 'modules/user/pesan/pesan_view.dart';

// PROFILE
import 'modules/user/profile/profile_binding.dart';
import 'modules/user/profile/profile_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

await Supabase.initialize(
  url: 'https://avztxkkbefvxfftvodui.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF2enR4a2tiZWZ2eGZmdHZvZHVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzOTMzMjUsImV4cCI6MjA3OTk2OTMyNX0.liN7spnWnbKUXsKPS6IgbN5z09AR0gD61bwpLoi5aTE',
);


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // GLOBAL BINDINGS
  LoginBinding().dependencies();
  RegisterBinding().dependencies();
  HomeBinding().dependencies();
  FavoriteBinding().dependencies();
  PesanBinding().dependencies();
  ProfileBinding().dependencies();

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
      home: const LoginView(),
    );
  }
}

// ============================================================
// ======================= MAIN PAGE ===========================
// ============================================================
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      const HomeView(),
      const FavoriteView(),
      const PesanView(),
      ProfileView(
        onTapFavorite: () {
          setState(() {
            _selectedIndex = 1; // 🔥 PINDAH KE TAB FAVORITE
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Home",
          ),
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
