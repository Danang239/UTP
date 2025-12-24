import 'dart:ui'; // for blur (UI only)

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'villa_viewmodel.dart';

class OwnerVillaView extends GetView<OwnerVillaViewModel> {
  const OwnerVillaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              children: [
                // ===== HEADER =====
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: _HeaderCard(
                    onAdd: () => _openAddVillaForm(),
                  ),
                ),

                // ===== LIST VILLA =====
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value &&
                        controller.villas.isEmpty) {
                      return const _LoadingState();
                    }

                    if (controller.errorMessage.value != null) {
                      return _ErrorState(
                        message: controller.errorMessage.value!,
                      );
                    }

                    if (controller.villas.isEmpty) {
                      return const _EmptyState();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                      itemCount: controller.villas.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final v = controller.villas[index];

                        return _VillaModernCard(
                          villaName: v.name,
                          imageUrl:
                              v.images.isNotEmpty ? v.images.first : null,
                          maxPerson: v.maxPerson,
                          capacity: v.capacity,
                          weekdayPrice: v.weekdayPrice,
                          weekendPrice: v.weekendPrice,
                          onEdit: () => _openEditVillaForm(v),
                          onDelete: () => controller.deleteVilla(v.id),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================================================================
  //                BOTTOM SHEET: TAMBAH VILLA
  // ===================================================================

  void _openAddVillaForm() {
    Get.bottomSheet(
      _VillaFormSheet(controller: controller, initialVilla: null),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ===================================================================
  //                BOTTOM SHEET: EDIT VILLA
  // ===================================================================

  void _openEditVillaForm(OwnerVilla villa) {
    Get.bottomSheet(
      _VillaFormSheet(controller: controller, initialVilla: villa),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ===============================
// UI WIDGETS (Header & States)
// ===============================

class _HeaderCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _HeaderCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B2B3A), Color(0xFF0F6B7B)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: const Icon(Icons.home_work_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Villa Saya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Kelola listing villa, foto, harga, dan kategori.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Villa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0B2B3A),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(strokeWidth: 2.6),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.holiday_village_outlined,
                  size: 44, color: Colors.black45),
              SizedBox(height: 10),
              Text(
                'Belum ada villa',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              SizedBox(height: 6),
              Text(
                'Klik "Tambah Villa" untuk membuat listing pertama.',
                style: TextStyle(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================
// Modern Villa Card (UI only)
// ===============================

class _VillaModernCard extends StatelessWidget {
  final String villaName;
  final String? imageUrl;
  final int maxPerson;
  final int capacity;
  final int weekdayPrice;
  final int weekendPrice;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VillaModernCard({
    required this.villaName,
    required this.imageUrl,
    required this.maxPerson,
    required this.capacity,
    required this.weekdayPrice,
    required this.weekendPrice,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onEdit,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 86,
                    height: 86,
                    color: Colors.grey.shade100,
                    child: imageUrl != null
                        ? Image.network(imageUrl!, fit: BoxFit.cover)
                        : Center(
                            child: Icon(
                              Icons.home_work_outlined,
                              color: Colors.grey.shade500,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        villaName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoPill(
                            icon: Icons.people_outline,
                            text: '$maxPerson orang',
                          ),
                          _InfoPill(
                            icon: Icons.event_seat_outlined,
                            text: 'Kapasitas $capacity',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F6B7B).withOpacity(0.07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0F6B7B).withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.payments_outlined,
                                size: 16, color: Color(0xFF0F6B7B)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Weekday: Rp $weekdayPrice  •  Weekend: Rp $weekendPrice',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF0B2B3A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionIcon(
                      tooltip: 'Edit',
                      icon: Icons.edit,
                      onTap: onEdit,
                    ),
                    const SizedBox(height: 10),
                    _ActionIcon(
                      tooltip: 'Hapus',
                      icon: Icons.delete_outline,
                      onTap: onDelete,
                      danger: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.035),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  const _ActionIcon({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = danger
        ? Colors.red.withOpacity(0.08)
        : Colors.black.withOpacity(0.04);
    final bd = danger
        ? Colors.red.withOpacity(0.18)
        : Colors.black.withOpacity(0.08);
    final ic = danger ? Colors.redAccent : Colors.black87;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: bd),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 20, color: ic),
          ),
        ),
      ),
    );
  }
}

// =======================================================================
//                        WIDGET FORM TAMBAH / EDIT
// =======================================================================

class _VillaFormSheet extends StatefulWidget {
  final OwnerVillaViewModel controller;
  final OwnerVilla? initialVilla; // null = tambah, != null = edit

  const _VillaFormSheet({required this.controller, this.initialVilla});

  bool get isEdit => initialVilla != null;

  @override
  State<_VillaFormSheet> createState() => _VillaFormSheetState();
}

class _VillaFormSheetState extends State<_VillaFormSheet> {
  // ✅ kategori yang disediakan (klik saja)
  final List<String> categoryOptions = const [
    'pool',
    'big_yard',
    'billiard',
  ];

  late final TextEditingController nameC;
  late final TextEditingController descC;
  late final TextEditingController capacityC;
  late final TextEditingController maxPersonC;
  late final TextEditingController weekdayC;
  late final TextEditingController weekendC;
  late final TextEditingController locationC;
  late final TextEditingController mapsLinkC;
  late final TextEditingController latC;
  late final TextEditingController lngC;
  late final TextEditingController facilityC; // tetap ada (biar tidak merusak)

  late List<String> facilities;
  late List<String> existingImages;
  late List<String> existingVideos;
  final List<PlatformFile> newFiles = [];

  bool saving = false;

  @override
  void initState() {
    super.initState();
    final v = widget.initialVilla;
    nameC = TextEditingController(text: v?.name ?? '');
    descC = TextEditingController(text: v?.description ?? '');
    capacityC = TextEditingController(
      text: v != null ? v.capacity.toString() : '',
    );
    maxPersonC = TextEditingController(
      text: v != null ? v.maxPerson.toString() : '',
    );
    weekdayC = TextEditingController(
      text: v != null ? v.weekdayPrice.toString() : '',
    );
    weekendC = TextEditingController(
      text: v != null ? v.weekendPrice.toString() : '',
    );
    locationC = TextEditingController(text: v?.location ?? '');
    mapsLinkC = TextEditingController(text: v?.mapsLink ?? '');
    latC = TextEditingController(text: v != null ? v.lat.toString() : '');
    lngC = TextEditingController(text: v != null ? v.lng.toString() : '');
    facilityC = TextEditingController();

    facilities = v != null ? List<String>.from(v.facilities) : [];
    existingImages = v != null ? List<String>.from(v.images) : [];
    existingVideos = v != null ? List<String>.from(v.videos) : [];
  }

  @override
  void dispose() {
    nameC.dispose();
    descC.dispose();
    capacityC.dispose();
    maxPersonC.dispose();
    weekdayC.dispose();
    weekendC.dispose();
    locationC.dispose();
    mapsLinkC.dispose();
    latC.dispose();
    lngC.dispose();
    facilityC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEdit ? 'Edit Villa' : 'Tambah Villa Baru';

    return Material(
      color: Colors.black.withOpacity(0.30),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              margin: const EdgeInsets.only(top: 40),
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(26)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.28),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.92),
                    Colors.white.withOpacity(0.98),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // drag handle
                      Container(
                        width: 44,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // header card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0B2B3A), Color(0xFF0F6B7B)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.14),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.18),
                                ),
                              ),
                              child: const Icon(Icons.home_work_outlined,
                                  color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(
                                widget.isEdit ? 'EDIT' : 'BARU',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                              backgroundColor: Colors.white24,
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.18)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // form body
                      _buildFormBody(context),

                      const SizedBox(height: 12),

                      // tombol simpan
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            backgroundColor: const Color(0xFF0F6B7B),
                            elevation: 4,
                          ),
                          onPressed: saving ? null : _onSavePressed,
                          child: saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  widget.isEdit
                                      ? 'Simpan Perubahan'
                                      : 'Simpan Villa',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Informasi Utama'),
        _input(nameC, 'Nama Villa', icon: Icons.home_outlined),
        _input(descC, 'Deskripsi', icon: Icons.description_outlined),

        Row(
          children: [
            Expanded(
              child: _input(
                capacityC,
                'Kapasitas',
                number: true,
                icon: Icons.event_seat_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _input(
                maxPersonC,
                'Max Person',
                number: true,
                icon: Icons.people_outline,
              ),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              child: _input(
                weekdayC,
                'Harga Weekday',
                number: true,
                icon: Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _input(
                weekendC,
                'Harga Weekend',
                number: true,
                icon: Icons.payments_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),
        _sectionTitle('Lokasi'),
        _input(locationC, 'Lokasi (mis. Cisarua, Bogor)',
            icon: Icons.place_outlined),
        _input(mapsLinkC, 'Link Google Maps villa', icon: Icons.map_outlined),

        Row(
          children: [
            Expanded(
              child: _readonlyField(
                controller: latC,
                label: 'Latitude (otomatis)',
                icon: Icons.my_location_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _readonlyField(
                controller: lngC,
                label: 'Longitude (otomatis)',
                icon: Icons.my_location_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ===== EXISTING IMAGES =====
        if (existingImages.isNotEmpty) ...[
          _sectionTitle('Media Saat Ini'),
          const SizedBox(height: 6),
          const Text('Foto saat ini',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          SizedBox(
            height: 92,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: existingImages.length,
              itemBuilder: (_, i) {
                final url = existingImages[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          url,
                          width: 140,
                          height: 92,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              existingImages.removeAt(i);
                            });
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.22)),
                            ),
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (existingVideos.isNotEmpty) ...[
          const Text('Video saat ini',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...existingVideos.asMap().entries.map(
                (e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: const Icon(Icons.videocam_outlined),
                    title: Text(
                      e.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          existingVideos.removeAt(e.key);
                        });
                      },
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 6),
        ],

        // ===== NEW FILES PICKER =====
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F6B7B).withOpacity(0.10),
              foregroundColor: const Color(0xFF0F6B7B),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side:
                    BorderSide(color: const Color(0xFF0F6B7B).withOpacity(0.20)),
              ),
            ),
            onPressed: _pickFiles,
            icon: const Icon(Icons.upload_file),
            label: const Text('Pilih Foto / Video'),
          ),
        ),

        const SizedBox(height: 10),

        if (newFiles.isNotEmpty) ...[
          const Text(
            'File baru (belum diupload)',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          // foto baru
          if (newFiles.any((f) => (f.extension ?? '').toLowerCase() != 'mp4'))
            SizedBox(
              height: 92,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: newFiles
                    .where((f) => (f.extension ?? '').toLowerCase() != 'mp4')
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: file.bytes != null
                                  ? Image.memory(
                                      file.bytes!,
                                      width: 140,
                                      height: 92,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 140,
                                      height: 92,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image),
                                    ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    newFiles.removeAt(index);
                                  });
                                },
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.22)),
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ),
            ),

          // video baru
          if (newFiles.any((f) => (f.extension ?? '').toLowerCase() == 'mp4'))
            ...[
              const SizedBox(height: 10),
              ...newFiles
                  .where((f) => (f.extension ?? '').toLowerCase() == 'mp4')
                  .toList()
                  .asMap()
                  .entries
                  .map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        leading: const Icon(Icons.videocam_outlined),
                        title: Text(
                          file.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              newFiles.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  }),
            ],
          const SizedBox(height: 6),
        ],

        const SizedBox(height: 8),

        // ✅ KATEGORI: owner hanya klik pilihan yang disediakan
        _sectionTitle('Kategori'),
        const Text(
          'Klik untuk memilih kategori yang tersedia',
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categoryOptions.map((cat) {
            final selected = facilities.contains(cat);
            return FilterChip(
              label: Text(cat),
              selected: selected,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    if (!facilities.contains(cat)) facilities.add(cat);
                  } else {
                    facilities.remove(cat);
                  }
                });
              },
              selectedColor: const Color(0xFF0F6B7B).withOpacity(0.15),
              checkmarkColor: const Color(0xFF0F6B7B),
              side: BorderSide(color: Colors.black.withOpacity(0.10)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              backgroundColor: Colors.black.withOpacity(0.03),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        if (facilities.isNotEmpty) ...[
          const Text(
            'Kategori terpilih',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: facilities.map((f) {
              return Chip(
                label: Text(f),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    facilities.remove(f);
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                side: BorderSide(color: Colors.black.withOpacity(0.08)),
                backgroundColor: Colors.black.withOpacity(0.03),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF0F6B7B),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  //                            ACTIONS
  // ===================================================================

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'],
    );
    if (result == null) return;

    setState(() {
      newFiles.addAll(result.files);
    });
  }

  Future<void> _onSavePressed() async {
    if (saving) return;

    final name = nameC.text.trim();
    final desc = descC.text.trim();
    final capacity = int.tryParse(capacityC.text.trim()) ?? 0;
    final maxPerson = int.tryParse(maxPersonC.text.trim()) ?? 0;
    final weekday = int.tryParse(weekdayC.text.trim()) ?? 0;
    final weekend = int.tryParse(weekendC.text.trim()) ?? 0;
    final location = locationC.text.trim();
    final mapsLink = mapsLinkC.text.trim();

    double lat = double.tryParse(latC.text.trim()) ?? 0.0;
    double lng = double.tryParse(lngC.text.trim()) ?? 0.0;

    if (lat == 0.0 || lng == 0.0) {
      final parsed = _parseLatLngFromMapsLink(mapsLink);
      if (parsed != null) {
        lat = parsed[0];
        lng = parsed[1];
      }
    }

    if (name.isEmpty ||
        desc.isEmpty ||
        capacity <= 0 ||
        maxPerson <= 0 ||
        weekday <= 0 ||
        weekend <= 0 ||
        mapsLink.isEmpty ||
        lat == 0.0 ||
        lng == 0.0) {
      Get.snackbar(
        'Validasi',
        'Harap lengkapi semua field dan pastikan link maps valid.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => saving = true);

    try {
      /// ======================
      /// UPLOAD FILE BARU (JIKA ADA)
      /// ======================
      Map<String, List<String>> media = {'images': [], 'videos': []};

      if (newFiles.isNotEmpty && widget.isEdit) {
        media = await widget.controller.uploadVillaFiles(
          newFiles,
          widget.initialVilla!.id,
        );
      }

      final allImages = [...existingImages, ...media['images']!];
      final allVideos = [...existingVideos, ...media['videos']!];

      /// ======================
      /// EDIT / TAMBAH
      /// ======================
      if (widget.isEdit) {
        final v = widget.initialVilla!;
        await widget.controller.updateVilla(
          id: v.id,
          name: name,
          description: desc,
          capacity: capacity,
          maxPerson: maxPerson,
          weekdayPrice: weekday,
          weekendPrice: weekend,
          location: location,
          lat: lat,
          lng: lng,
          mapsLink: mapsLink,
          facilities: facilities,
          images: allImages,
          videos: allVideos,
        );
      } else {
        await widget.controller.addVilla(
          name: name,
          description: desc,
          capacity: capacity,
          maxPerson: maxPerson,
          weekdayPrice: weekday,
          weekendPrice: weekend,
          location: location,
          lat: lat,
          lng: lng,
          mapsLink: mapsLink,
          facilities: facilities,
          files: newFiles,
        );
      }

      if (mounted) {
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  // ===================================================================
  //                        HELPER WIDGET & UTIL
  // ===================================================================

  Widget _input(
    TextEditingController controller,
    String label, {
    bool number = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
                color: Color(0xFF0F6B7B), width: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _readonlyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
          ),
        ),
      ),
    );
  }

  /// parse lat,lng dari link google maps
  List<double>? _parseLatLngFromMapsLink(String url) {
    if (url.isEmpty) return null;

    // pola 1: .../@-6.6973834,106.9455604,...
    final atMatch =
        RegExp(r'@(-?\d+\.?\d*),\s*(-?\d+\.?\d*)').firstMatch(url);
    if (atMatch != null) {
      final lat = double.tryParse(atMatch.group(1)!);
      final lng = double.tryParse(atMatch.group(2)!);
      if (lat != null && lng != null) return [lat, lng];
    }

    // pola 2: ...?q=-6.6973834,106.9455604...
    final qMatch = RegExp(
      r'[?&]q=(-?\d+\.?\d*),\s*(-?\d+\.?\d*)',
    ).firstMatch(url);
    if (qMatch != null) {
      final lat = double.tryParse(qMatch.group(1)!);
      final lng = double.tryParse(qMatch.group(2)!);
      if (lat != null && lng != null) return [lat, lng];
    }

    return null;
  }
}
