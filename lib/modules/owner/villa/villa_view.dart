import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'villa_viewmodel.dart';

class OwnerVillaView extends GetView<OwnerVillaViewModel> {
  const OwnerVillaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ===== HEADER =====
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Villa Saya',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openAddVillaForm(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Villa'),
              ),
            ],
          ),
        ),

        // ===== LIST VILLA =====
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.villas.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage.value != null) {
              return Center(child: Text(controller.errorMessage.value!));
            }

            if (controller.villas.isEmpty) {
              return const Center(child: Text('Belum ada villa.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.villas.length,
              itemBuilder: (_, index) {
                final v = controller.villas[index];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: v.images.isNotEmpty
                            ? Image.network(
                                v.images.first,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.home_work_outlined),
                              ),
                      ),
                    ),
                    title: Text(
                      v.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${v.maxPerson} orang • Kapasitas ${v.capacity}\n'
                        'Weekday: Rp ${v.weekdayPrice} • Weekend: Rp ${v.weekendPrice}',
                      ),
                    ),
                    // ==== FIX OVERFLOW: gunakan Row, bukan Column ====
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit),
                          onPressed: () => _openEditVillaForm(v),
                        ),
                        IconButton(
                          tooltip: 'Hapus',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => controller.deleteVilla(v.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // ===================================================================
  //                BOTTOM SHEET: TAMBAH VILLA
  // ===================================================================

  void _openAddVillaForm() {
    Get.bottomSheet(
      _VillaFormSheet(
        controller: controller,
        initialVilla: null,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ===================================================================
  //                BOTTOM SHEET: EDIT VILLA
  // ===================================================================

  void _openEditVillaForm(OwnerVilla villa) {
    Get.bottomSheet(
      _VillaFormSheet(
        controller: controller,
        initialVilla: villa,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// =======================================================================
//                        WIDGET FORM TAMBAH / EDIT
// =======================================================================

class _VillaFormSheet extends StatefulWidget {
  final OwnerVillaViewModel controller;
  final OwnerVilla? initialVilla; // null = tambah, != null = edit

  const _VillaFormSheet({
    required this.controller,
    this.initialVilla,
  });

  bool get isEdit => initialVilla != null;

  @override
  State<_VillaFormSheet> createState() => _VillaFormSheetState();
}

class _VillaFormSheetState extends State<_VillaFormSheet> {
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
  late final TextEditingController facilityC;

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
    capacityC =
        TextEditingController(text: v != null ? v.capacity.toString() : '');
    maxPersonC =
        TextEditingController(text: v != null ? v.maxPerson.toString() : '');
    weekdayC =
        TextEditingController(text: v != null ? v.weekdayPrice.toString() : '');
    weekendC =
        TextEditingController(text: v != null ? v.weekendPrice.toString() : '');
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
      color: Colors.black.withOpacity(0.25), // dim background
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              // glassmorphism effect
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.96),
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
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      // header card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0f3440),
                              Color(0xFF13525f),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.home_work_outlined,
                                color: Colors.white),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (widget.isEdit)
                              const Chip(
                                label: Text(
                                  'EDIT',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                                backgroundColor: Colors.white24,
                              )
                            else
                              const Chip(
                                label: Text(
                                  'BARU',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                                backgroundColor: Colors.white24,
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
                            backgroundColor: const Color(0xFF0f70ff),
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
                                    fontWeight: FontWeight.bold,
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
        _input(nameC, 'Nama Villa'),
        _input(descC, 'Deskripsi'),
        _input(capacityC, 'Kapasitas', number: true),
        _input(maxPersonC, 'Max Person', number: true),
        _input(weekdayC, 'Harga Weekday', number: true),
        _input(weekendC, 'Harga Weekend', number: true),
        _input(locationC, 'Lokasi (mis. Cisarua, Bogor)'),
        _input(mapsLinkC, 'Link Google Maps villa'),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: latC,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Latitude (otomatis)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: lngC,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Longitude (otomatis)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ===== EXISTING IMAGES =====
        if (existingImages.isNotEmpty) ...[
          const Text(
            'Foto saat ini',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: existingImages.length,
              itemBuilder: (_, i) {
                final url = existingImages[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          url,
                          width: 130,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              existingImages.removeAt(i);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],

        if (existingVideos.isNotEmpty) ...[
          const Text(
            'Video saat ini',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          ...existingVideos.asMap().entries.map(
                (e) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.videocam),
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
          const SizedBox(height: 10),
        ],

        // ===== NEW FILES PICKER =====
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[50],
              foregroundColor: const Color(0xFF0f70ff),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.blue[100]!),
              ),
            ),
            onPressed: _pickFiles,
            icon: const Icon(Icons.upload_file),
            label: const Text('Pilih Foto / Video'),
          ),
        ),

        const SizedBox(height: 8),

        if (newFiles.isNotEmpty) ...[
          const Text(
            'File baru (belum diupload)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),

          // foto baru
          if (newFiles
              .any((f) => (f.extension ?? '').toLowerCase() != 'mp4'))
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: newFiles
                    .where(
                        (f) => (f.extension ?? '').toLowerCase() != 'mp4')
                    .toList()
                    .asMap()
                    .entries
                    .map(
                  (entry) {
                    final index = entry.key;
                    final file = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: file.bytes != null
                                ? Image.memory(
                                    file.bytes!,
                                    width: 130,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 130,
                                    height: 90,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image),
                                  ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  newFiles.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),

          // video baru
          if (newFiles
              .any((f) => (f.extension ?? '').toLowerCase() == 'mp4')) ...[
            const SizedBox(height: 6),
            ...newFiles
                .where((f) => (f.extension ?? '').toLowerCase() == 'mp4')
                .toList()
                .asMap()
                .entries
                .map(
              (entry) {
                final index = entry.key;
                final file = entry.value;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.videocam),
                  title: Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      setState(() {
                        newFiles.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 10),
        ],

        const SizedBox(height: 8),

        const Text(
          'Fasilitas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: facilityC,
                decoration: const InputDecoration(
                  hintText: 'contoh: Kolam renang',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final text = facilityC.text.trim();
                if (text.isEmpty) return;
                setState(() {
                  facilities.add(text);
                });
                facilityC.clear();
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 6,
          runSpacing: -4,
          children: facilities
              .asMap()
              .entries
              .map(
                (e) => Chip(
                  label: Text(e.value),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      facilities.removeAt(e.key);
                    });
                  },
                ),
              )
              .toList(),
        ),
      ],
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
      // upload file baru
      Map<String, List<String>> media = {'images': [], 'videos': []};
      if (newFiles.isNotEmpty) {
        media = await widget.controller.uploadVillaFiles(newFiles);
      }

      final allImages = [
        ...existingImages,
        ...media['images']!,
      ];
      final allVideos = [
        ...existingVideos,
        ...media['videos']!,
      ];

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
          images: allImages,
          videos: allVideos,
        );
      }

      Get.back(); // tutup form
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  // ===================================================================
  //                        HELPER WIDGET & UTIL
  // ===================================================================

  Widget _input(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
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
    final qMatch =
        RegExp(r'[?&]q=(-?\d+\.?\d*),\s*(-?\d+\.?\d*)').firstMatch(url);
    if (qMatch != null) {
      final lat = double.tryParse(qMatch.group(1)!);
      final lng = double.tryParse(qMatch.group(2)!);
      if (lat != null && lng != null) return [lat, lng];
    }

    return null;
  }
}
