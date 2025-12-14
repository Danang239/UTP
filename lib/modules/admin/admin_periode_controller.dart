import 'package:get/get.dart';

class AdminPeriodController extends GetxController {
  final selectedMonth = DateTime.now().month.obs; // 1-12
  final selectedYear = DateTime.now().year.obs;

  void setMonthYear({required int month, required int year}) {
    selectedMonth.value = month;
    selectedYear.value = year;
  }

  String get label {
    final m = selectedMonth.value.toString().padLeft(2, '0');
    final y = selectedYear.value.toString();
    return '$m/$y';
  }
}
