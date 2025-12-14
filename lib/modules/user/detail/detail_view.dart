// lib/modules/detail/detail_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'detail_viewmodel.dart';

// Tambahkan Chat Room
import 'package:utp_flutter/modules/user/chat_room/chat_room_view.dart';
import 'package:utp_flutter/modules/user/chat_room/chat_room_binding.dart';

class DetailView extends StatelessWidget {
  final String villaId;
  final Map<String, dynamic> villaData;

  const DetailView({
    super.key,
    required this.villaId,
    required this.villaData,
  });

  @override
  Widget build(BuildContext context) {
    // register controller untuk villa ini
    final controller = Get.put(
      DetailViewModel(villaId, villaData),
      tag: villaId,
    );

    final String name = villaData['name'] ?? 'Tanpa Nama';
    final String location = villaData['location'] ?? '-';
    final int weekdayPrice = controller.parsePrice(villaData['weekday_price']);
    final int weekendPrice = controller.parsePrice(villaData['weekend_price']);
    final String description = villaData['description'] ?? '';
    final String mapsLink = villaData['maps_link'] ?? '';
    final String ownerId = villaData['owner_id'] ?? 'UNKNOWN_OWNER';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // ========================
          // TOMBOL CHAT ROOM
          // ========================
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Get.to(
                () => const ChatRoomView(),
                binding: ChatRoomBinding(),
                arguments: {
                  'villaId': villaId,
                  'ownerId': ownerId,
                  'userId': controller.uid,
                },
              );
            },
          ),

          // FAVORIT
          StreamBuilder<bool>(
            stream: controller.favoriteStream(),
            builder: (context, snapshot) {
              final isFav = snapshot.data ?? false;

              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.grey,
                ),
                onPressed: () => controller.toggleFavorite(context),
              );
            },
          ),
        ],
      ),

      // =============================
      // BOTTOM BUTTON (BOOKING)
      // =============================
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.black,
                ),
                onPressed: controller.loadingBooking.value
                    ? null
                    : () => controller.createBooking(context),
                child: Text(
                  controller.loadingBooking.value ? 'Memproses...' : 'Pesan',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ),

      // =============================
      // BODY MAIN DETAIL PAGE
      // =============================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================
            // FOTO ATAS (SLIDER)
            // =============================
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: SizedBox(
                width: double.infinity,
                child: controller.images.isEmpty
                    ? Container(
                        height: MediaQuery.of(context).size.width * 9 / 16,
                        color: Colors.grey.shade300,
                      )
                    : Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: PageView.builder(
                              controller: controller.imagePageController,
                              itemCount: controller.images.length,
                              physics: const PageScrollPhysics(),
                              onPageChanged: controller.onImagePageChanged,
                              itemBuilder: (context, index) {
                                final url = controller.images[index];
                                return Image.network(
                                  url,
                                  width: double.infinity,
                                  fit: BoxFit.cover, // isi penuh tanpa distorsi
                                  filterQuality: FilterQuality.high,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                          // DOT INDICATOR
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Obx(() {
                              final current =
                                  controller.currentImageIndex.value;
                              final total = controller.images.length;
                              if (total <= 1) return const SizedBox.shrink();

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(total, (index) {
                                  final isActive = index == current;
                                  return AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    width: isActive ? 18 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  );
                                }),
                              );
                            }),
                          ),
                        ],
                      ),
              ),
            ),

            // =============================
            // CONTAINER PUTIH KONTEN
            // =============================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===============================
                      // NAMA + LOKASI + RATING
                      // ===============================
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.star,
                              size: 14, color: Colors.orangeAccent),
                          SizedBox(width: 4),
                          Text(
                            '4.9 (200 ulasan)',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ===============================
                      // HARGA
                      // ===============================
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "Weekday : ",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Rp $weekdayPrice",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                "Weekend : ",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Rp $weekendPrice",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ===============================
                      // DESKRIPSI
                      // ===============================
                      const Text(
                        "Deskripsi",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description.isEmpty
                            ? "Belum ada deskripsi."
                            : description,
                        style: const TextStyle(fontSize: 14),
                      ),

                      const SizedBox(height: 16),

                      // ===============================
                      // BUTTON LIHAT DI MAPS
                      // ===============================
                      if (mapsLink.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.location_on_outlined),
                            label: const Text(
                              "Lihat di Google Maps",
                              style: TextStyle(fontSize: 14),
                            ),
                            onPressed: () =>
                                controller.openMaps(context, mapsLink),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // ===============================
                      // KALENDER BOOKING
                      // ===============================
                      const Text(
                        "Tanggal Menginap",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "• Abu-abu = tanggal sudah lewat\n"
                        "• Merah = tanggal sudah dibooking (termasuk pending)",
                        style: TextStyle(fontSize: 11),
                      ),

                      const SizedBox(height: 12),

                      if (controller.loadingCalendar.value)
                        const Center(child: CircularProgressIndicator())
                      else
                        TableCalendar(
                          firstDay: controller.firstDay,
                          lastDay: controller.lastDay,
                          focusedDay: controller.focusedDay,
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          calendarFormat: CalendarFormat.month,
                          availableGestures: AvailableGestures.horizontalSwipe,
                          selectedDayPredicate: (day) =>
                              controller.isSelected(day),
                          onDaySelected: (selectedDay, focusedDay) {
                            controller.focusedDay = focusedDay;
                            controller.onSelectDay(selectedDay, context);
                          },
                          onPageChanged: controller.onPageChanged,
                          enabledDayPredicate: (day) {
                            final d = DateTime(day.year, day.month, day.day);
                            if (d.isBefore(controller.todayNorm)) {
                              return false;
                            }
                            return true;
                          },
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) =>
                                _buildDayCell(context, day, controller),
                            todayBuilder: (context, day, focusedDay) =>
                                _buildDayCell(context, day, controller),
                          ),
                        ),

                      const SizedBox(height: 8),
                      Text(
                        'Check-in:  ${controller.formatDate(controller.checkIn.value)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'Check-out: ${controller.formatDate(controller.checkOut.value)}',
                        style: const TextStyle(fontSize: 13),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime day,
    DetailViewModel controller,
  ) {
    final d = DateTime(day.year, day.month, day.day);
    final isPast = d.isBefore(controller.todayNorm);
    final isBooked = controller.isBooked(d);
    final isSelected = controller.isSelected(d);
    final inRange = controller.isInSelectedRange(d);

    Color bg = Colors.transparent;
    Color textColor = Colors.black;

    if (isBooked) {
      bg = Colors.red;
      textColor = Colors.white;
    } else if (isSelected || inRange) {
      bg = Colors.black;
      textColor = Colors.white;
    } else if (isPast) {
      textColor = Colors.grey;
    }

    return Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
