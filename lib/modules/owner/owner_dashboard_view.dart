import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'owner_dashboard_viewmodel.dart';

class OwnerDashboardView extends GetView<OwnerDashboardViewModel> {
  const OwnerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
      ),
      body: Center(
        child: Text(
          'Halo ${controller.name}', 
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
