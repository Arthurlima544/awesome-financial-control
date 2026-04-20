class MonthlyStatModel {
  const MonthlyStatModel({
    required this.month,
    required this.income,
    required this.expenses,
  });

  final String month;
  final double income;
  final double expenses;

  factory MonthlyStatModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatModel(
      month: json['month'] as String,
      income: (json['income'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
    );
  }
}
