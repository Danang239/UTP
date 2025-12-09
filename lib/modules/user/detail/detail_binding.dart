import 'package:get/get.dart';
import 'detail_viewmodel.dart';

class DetailBinding extends Bindings {
  final String villaId;
  final Map<String, dynamic> villaData;

  DetailBinding(this.villaId, this.villaData);

  @override
  void dependencies() {
    Get.lazyPut<DetailViewModel>(
      () => DetailViewModel(villaId, villaData),
      tag: villaId,
    );
  }
}
