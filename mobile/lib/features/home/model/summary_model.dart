class SummaryModel {
  const SummaryModel({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
  });

  final double totalIncome;
  final double totalExpenses;
  final double balance;

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
