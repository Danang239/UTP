import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:utp_flutter/app_session.dart';
import 'owner_dashboard_models.dart';

class OwnerDashboardTabViewModel
    extends
        GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  // ==========================
  // SUMMARY
  // ==========================
  final totalPendapatanBulanIni = 0.0.obs;
  final totalBookingBulanIni = 0.obs;
  final totalVillaTerdaftar = 0.obs;

  // ==========================
  // TABLE
  // ==========================
  final villaMonthlyIncome =
      <
            OwnerVillaMonthlyIncomeItem
          >[]
          .obs;

  // ==========================
  // FILTER BULAN/TAHUN (OWNER JUGA BISA PILIH PERIODE)
  // ==========================
  final selectedMonth = DateTime.now().month.obs; // 1-12
  final selectedYear = DateTime.now().year.obs;

  @override
  void onInit() {
    super.onInit();
    loadSummary();
  }

  void setMonthYear({
    required int month,
    required int year,
  }) {
    selectedMonth.value = month;
    selectedYear.value = year;
    loadSummary();
  }

  DateTime _startOfMonth(
    int year,
    int month,
  ) {
    return DateTime(
      year,
      month,
      1,
    );
  }

  DateTime _startOfNextMonth(
    int year,
    int month,
  ) {
    if (month ==
        12) {
      return DateTime(
        year +
            1,
        1,
        1,
      );
    }
    return DateTime(
      year,
      month +
          1,
      1,
    );
  }

  double _numToDouble(
    dynamic v,
  ) {
    if (v ==
        null)
      return 0;
    if (v
        is num)
      return v.toDouble();
    return double.tryParse(
          v.toString(),
        ) ??
        0;
  }

  Future<
    void
  >
  loadSummary() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final ownerId = AppSession.ownerId;

      if (ownerId ==
              null ||
          ownerId.isEmpty) {
        errorMessage.value = 'ownerId session kosong. Pastikan login owner mengisi users.owner_id.';
        totalPendapatanBulanIni.value = 0;
        totalBookingBulanIni.value = 0;
        totalVillaTerdaftar.value = 0;
        villaMonthlyIncome.clear();
        return;
      }

      final int m = selectedMonth.value;
      final int y = selectedYear.value;

      final DateTime from = _startOfMonth(
        y,
        m,
      );
      final DateTime to = _startOfNextMonth(
        y,
        m,
      );

      // ==========================
      // 1) AMBIL VILLA MILIK OWNER
      // ==========================
      final villaSnap = await _db
          .collection(
            'villas',
          )
          .where(
            'owner_id',
            isEqualTo: ownerId,
          )
          .get();

      totalVillaTerdaftar.value = villaSnap.docs.length;

      final Map<
        String,
        String
      >
      villaNameById = {};
      final List<
        String
      >
      villaIds = [];

      for (final d in villaSnap.docs) {
        final data = d.data();
        final name =
            (data['name'] ??
                    '')
                .toString();

        villaNameById[d.id] = name;
        villaIds.add(
          d.id,
        );
      }

      if (villaIds.isEmpty) {
        totalPendapatanBulanIni.value = 0;
        totalBookingBulanIni.value = 0;
        villaMonthlyIncome.clear();
        return;
      }

      // ==========================
      // 2) AMBIL BOOKING CONFIRMED BERDASARKAN villa_id (AMAN)
      // ==========================
      final List<
        QueryDocumentSnapshot<
          Map<
            String,
            dynamic
          >
        >
      >
      allDocs = [];

      for (
        int i = 0;
        i <
            villaIds.length;
        i += 10
      ) {
        final chunk = villaIds.sublist(
          i,
          (i +
                      10 >
                  villaIds.length)
              ? villaIds.length
              : i +
                    10,
        );

        final snap = await _db
            .collection(
              'bookings',
            )
            .where(
              'villa_id',
              whereIn: chunk,
            )
            .where(
              'status',
              isEqualTo: 'confirmed',
            )
            .get();

        allDocs.addAll(
          snap.docs,
        );
      }

      // filter periode dengan created_at
      final List<
        QueryDocumentSnapshot<
          Map<
            String,
            dynamic
          >
        >
      >
      bookingDocs = [];

      for (final d in allDocs) {
        final data = d.data();

        final Timestamp? ts =
            data['created_at']
                as Timestamp?;
        final DateTime? dt = ts?.toDate();

        if (dt ==
            null) {
          continue;
        }

        final bool inRange =
            !dt.isBefore(
              from,
            ) &&
            dt.isBefore(
              to,
            );

        if (inRange) {
          bookingDocs.add(
            d,
          );
        }
      }

      totalBookingBulanIni.value = bookingDocs.length;

      // ==========================
      // 3) HITUNG TOTAL PENDAPATAN & PER VILLA
      // ==========================
      double totalIncome = 0;

      final Map<
        String,
        _VillaAgg
      >
      agg = {};

      for (final d in bookingDocs) {
        final data = d.data();

        final String villaId =
            (data['villa_id'] ??
                    '')
                .toString();

        final String fallbackName =
            villaNameById[villaId] ??
            '-';

        final String villaName =
            (data['villa_name'] ??
                    fallbackName)
                .toString();

        final double totalPrice = _numToDouble(
          data['total_price'],
        );
        final double ownerIncome = _numToDouble(
          data['owner_income'],
        );
        final double adminFee = _numToDouble(
          data['admin_fee'],
        );

        // prioritas owner_income (hasil confirm admin)
        // fallback total_price - admin_fee
        // fallback total_price * 0.9
        final double income =
            ownerIncome >
                0
            ? ownerIncome
            : (adminFee >
                      0
                  ? (totalPrice -
                        adminFee)
                  : (totalPrice *
                        0.9));

        totalIncome += income;

        final String key = villaId.isNotEmpty
            ? villaId
            : villaName;

        if (!agg.containsKey(
          key,
        )) {
          agg[key] = _VillaAgg(
            villaId: villaId.isNotEmpty
                ? villaId
                : key,
            villaName: villaName.isNotEmpty
                ? villaName
                : fallbackName,
            count: 0,
            income: 0,
          );
        }

        agg[key]!.count += 1;
        agg[key]!.income += income;
      }

      totalPendapatanBulanIni.value = totalIncome;

      final List<
        OwnerVillaMonthlyIncomeItem
      >
      rows = [];

      for (final v in agg.values) {
        rows.add(
          OwnerVillaMonthlyIncomeItem(
            villaId: v.villaId,
            villaName: v.villaName,
            bookingCount: v.count,
            income: v.income,
          ),
        );
      }

      rows.sort(
        (
          a,
          b,
        ) => b.income.compareTo(
          a.income,
        ),
      );

      villaMonthlyIncome.assignAll(
        rows,
      );
    } catch (
      e,
      st
    ) {
      // ignore: avoid_print
      print(
        'ERROR loadSummary: $e\n$st',
      );
      errorMessage.value = e.toString();
      totalPendapatanBulanIni.value = 0;
      totalBookingBulanIni.value = 0;
      totalVillaTerdaftar.value = 0;
      villaMonthlyIncome.clear();
    } finally {
      isLoading.value = false;
    }
  }
}

class _VillaAgg {
  final String villaId;
  final String villaName;

  int count;
  double income;

  _VillaAgg({
    required this.villaId,
    required this.villaName,
    required this.count,
    required this.income,
  });
}
