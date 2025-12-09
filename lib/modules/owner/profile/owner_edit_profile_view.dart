import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_viewmodel.dart';

class OwnerEditProfileView extends GetView<OwnerProfileViewModel> {
  const OwnerEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;

      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Edit Profil Owner',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // AVATAR + BUTTON GANTI FOTO
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                controller.profileImg.value.isNotEmpty
                                    ? NetworkImage(controller.profileImg.value)
                                    : null,
                            child: controller.profileImg.value.isEmpty
                                ? const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: controller.pickAndUploadProfileImage,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0f70ff),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // CARD DATA PROFILE (FORM LAMA DIPAKAI LAGI)
                    _ProfileFormCard(controller: controller),

                    const SizedBox(height: 24),
                  ],
                ),
              ),

              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.15),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

/// Card berisi form editable (nama & no HP)
class _ProfileFormCard extends StatefulWidget {
  final OwnerProfileViewModel controller;

  const _ProfileFormCard({required this.controller});

  @override
  State<_ProfileFormCard> createState() => _ProfileFormCardState();
}

class _ProfileFormCardState extends State<_ProfileFormCard> {
  late final TextEditingController nameC;
  late final TextEditingController phoneC;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.controller.name.value);
    phoneC = TextEditingController(text: widget.controller.phone.value);

    // sinkron dengan perubahan di controller
    ever<String>(widget.controller.name, (v) {
      nameC.text = v;
    });
    ever<String>(widget.controller.phone, (v) {
      phoneC.text = v;
    });
  }

  @override
  void dispose() {
    nameC.dispose();
    phoneC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _textField(
              controller: nameC,
              label: 'Nama',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            Obx(
              () => _readOnlyField(
                label: 'Email',
                value: widget.controller.email.value,
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 12),
            _textField(
              controller: phoneC,
              label: 'Nomor Telepon',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Simpan Perubahan'),
                onPressed: () {
                  widget.controller.updateProfile(
                    newName: nameC.text.trim(),
                    newPhone: phoneC.text.trim(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _readOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      enabled: false,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
