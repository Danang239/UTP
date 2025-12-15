// lib/modules/splash/splash_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:utp_flutter/app/routes/app_routes.dart';
import 'package:utp_flutter/app_session.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 800));

    final hasSession = await AppSession.loadSession();

    if (!hasSession) {
      Get.offAllNamed(Routes.login);
      return;
    }

    switch (AppSession.role) {
      case 'admin':
        Get.offAllNamed(Routes.adminDashboard);
        break;
      case 'owner':
        Get.offAllNamed(Routes.ownerDashboard);
        break;
      default:
        Get.offAllNamed(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
