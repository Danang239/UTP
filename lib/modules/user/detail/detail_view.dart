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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
      backgroundColor: theme.scaffoldBackgroundColor,

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: Text(
          name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // CHAT ROOM
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
                  color: isFav ? Colors.red : colors.onSurfaceVariant,
                ),
                onPressed: () => controller.toggleFavorite(context),
              );
            },
          ),
        ],
      ),

      // ================= BOTTOM BUTTON =================
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: colors.primary,
                ),
                onPressed: controller.loadingBooking.value
                    ? null
                    : () => controller.createBooking(context),
                child: Text(
                  controller.loadingBooking.value
                      ? 'Memproses...'
                      : 'Pesan',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= FOTO =================
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
                        color: colors.surfaceVariant,
                      )
                    : Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: PageView.builder(
                              controller:
                                  controller.imagePageController,
                              itemCount: controller.images.length,
                              onPageChanged:
                                  controller.onImagePageChanged,
                              itemBuilder: (context, index) {
                                final url =
                                    controller.images[index];
                                return Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  filterQuality:
                                      FilterQuality.high,
                                  loadingBuilder:
                                      (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color:
                                          colors.surfaceVariant,
                                      child: const Center(
                                        child:
                                            CircularProgressIndicator(),
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
                              final total =
                                  controller.images.length;
                              if (total <= 1) {
                                return const SizedBox.shrink();
                              }

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: List.generate(total, (i) {
                                  final active = i == current;
                                  return AnimatedContainer(
                                    duration: const Duration(
                                        milliseconds: 200),
                                    margin:
                                        const EdgeInsets.symmetric(
                                            horizontal: 3),
                                    width: active ? 18 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: active
                                          ? Colors.white
                                          : Colors.white
                                              .withOpacity(0.6),
                                      borderRadius:
                                          BorderRadius.circular(10),
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

            // ================= CONTENT =================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
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
                      Text(
                        name,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location,
                        style: theme.textTheme.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // HARGA
                      Text(
                        "Weekday: Rp $weekdayPrice",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Weekend: Rp $weekendPrice",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 24),

                      // DESKRIPSI
                      Text(
                        "Deskripsi",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description.isEmpty
                            ? "Belum ada deskripsi."
                            : description,
                        style: theme.textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 16),

                      // MAPS
                      if (mapsLink.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.location_on_outlined),
                            label:
                                const Text("Lihat di Google Maps"),
                            onPressed: () =>
                                controller.openMaps(context, mapsLink),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // ================= KALENDER (TIDAK DIUBAH) =================
                      const Text(
                        "Tanggal Menginap",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      if (controller.loadingCalendar.value)
                        const Center(
                            child: CircularProgressIndicator())
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
                          selectedDayPredicate: controller.isSelected,
                          onDaySelected: (selectedDay, focusedDay) {
                            controller.focusedDay = focusedDay;
                            controller.onSelectDay(selectedDay, context);
                          },
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder:
                                (c, d, f) =>
                                    _buildDayCell(c, d, controller),
                            todayBuilder:
                                (c, d, f) =>
                                    _buildDayCell(c, d, controller),
                          ),
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

  // ================= DAY CELL (TIDAK DIUBAH) =================
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
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(color: textColor, fontSize: 13),
        ),
      ),
    );
  }
}
