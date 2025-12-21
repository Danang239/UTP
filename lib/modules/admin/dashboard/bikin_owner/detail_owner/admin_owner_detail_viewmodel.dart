import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AdminOwnerDetailViewModel
    extends
        GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // owner id dari arguments
  final RxString ownerId = ''.obs;

  // data owner
  final RxString name = '-'.obs;
  final RxString email = '-'.obs;
  final RxString phone = '-'.obs;
  final RxString role = 'owner'.obs;
  final RxBool isActive = true.obs;

  // villa data
  final RxInt totalVilla = 0.obs;
  final RxList<
    String
  >
  villaNames =
      <
            String
          >[]
          .obs;

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    if (arg ==
            null ||
        arg.toString().trim().isEmpty) {
      errorMessage.value = 'ownerId kosong';
      return;
    }

    ownerId.value = arg.toString().trim();
    loadDetail();
  }

  Future<
    void
  >
  loadDetail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final uid = ownerId.value;

      // 1) ambil owner
      final userDoc = await _db
          .collection(
            'users',
          )
          .doc(
            uid,
          )
          .get();
      if (!userDoc.exists) {
        errorMessage.value = 'Owner tidak ditemukan di users/$uid';
        return;
      }

      final data =
          userDoc.data() ??
          {};
      name.value =
          (data['name'] ??
                  '-')
              .toString();
      email.value =
          (data['email'] ??
                  '-')
              .toString();
      phone.value =
          (data['phone'] ??
                  '-')
              .toString();
      role.value =
          (data['role'] ??
                  'owner')
              .toString();
      isActive.value =
          (data['is_active'] ??
              true) ==
          true;

      // 2) ambil villa milik owner
      // utama: owner_id
      final snapA = await _db
          .collection(
            'villas',
          )
          .where(
            'owner_id',
            isEqualTo: uid,
          )
          .get();

      // fallback: ownerId (kalau ada data versi lama)
      final List<
        QueryDocumentSnapshot<
          Map<
            String,
            dynamic
          >
        >
      >
      allDocs =
          <
            QueryDocumentSnapshot<
              Map<
                String,
                dynamic
              >
            >
          >[];

      allDocs.addAll(
        snapA.docs,
      );

      if (allDocs.isEmpty) {
        final snapB = await _db
            .collection(
              'villas',
            )
            .where(
              'ownerId',
              isEqualTo: uid,
            )
            .get();
        allDocs.addAll(
          snapB.docs,
        );
      }

      // DEBUG (biar kamu tau bener2 kebaca apa engga)
      // ignore: avoid_print
      print(
        'ADMIN OWNER DETAIL uid=$uid | villaDocs=${allDocs.length}',
      );
      if (allDocs.isNotEmpty) {
        // ignore: avoid_print
        print(
          'first villa keys=${allDocs.first.data().keys.toList()}',
        );
        // ignore: avoid_print
        print(
          'first villa owner_id=${allDocs.first.data()['owner_id']}',
        );
        // ignore: avoid_print
        print(
          'first villa ownerId=${allDocs.first.data()['ownerId']}',
        );
      }

      final names =
          <
            String
          >[];
      for (final d in allDocs) {
        final v = d.data();
        final n =
            (v['name'] ??
                    v['villa_name'] ??
                    d.id)
                .toString();
        names.add(
          n,
        );
      }

      names.sort(
        (
          a,
          b,
        ) => a.toLowerCase().compareTo(
          b.toLowerCase(),
        ),
      );
      villaNames.assignAll(
        names,
      );
      totalVilla.value = names.length;
    } catch (
      e,
      st
    ) {
      // ignore: avoid_print
      print(
        'ERROR loadDetail: $e\n$st',
      );
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
