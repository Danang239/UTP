class OwnerVillaMonthlyIncomeItem {
  final String villaId;
  final String villaName;
  final int bookingCount;
  final double income;

  const OwnerVillaMonthlyIncomeItem({
    required this.villaId,
    required this.villaName,
    required this.bookingCount,
    required this.income,
  });

  OwnerVillaMonthlyIncomeItem copyWith({
    String? villaId,
    String? villaName,
    int? bookingCount,
    double? income,
  }) {
    return OwnerVillaMonthlyIncomeItem(
      villaId:
          villaId ??
          this.villaId,
      villaName:
          villaName ??
          this.villaName,
      bookingCount:
          bookingCount ??
          this.bookingCount,
      income:
          income ??
          this.income,
    );
  }
}
