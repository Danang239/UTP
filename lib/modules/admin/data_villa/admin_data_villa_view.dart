import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'admin_data_villa_viewmodel.dart';

class AdminDataVillaView extends GetView<AdminDataVillaViewModel> {
  const AdminDataVillaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9FF),
      body: SafeArea(
        child: Column(
          children: [
            // TITLE
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: const [
                  Text(
                    "Data Villa",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // LIST DATA VILLA
            Expanded(
              child: Obx(() {
                final list = controller.villas;
                if (list.isEmpty) {
                  return const Center(
                    child: Text("Belum ada data villa."),
                  );
                }

                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final v = list[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: ListTile(
                        title: Text(v['name']),
                        subtitle: Text(v['location']),
                        trailing:
                            Text("Rp ${v['weekday_price']} / Rp ${v['weekend_price']}"),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
