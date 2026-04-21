class MonthlyStatModel {
  const MonthlyStatModel({
    required this.month,
    required this.income,
    required this.expenses,
  });

  final String month;
  final double income;
  final double expenses;

  String get monthAbbreviation {
    if (month.length < 7) return month;
    final m = int.tryParse(month.substring(5, 7)) ?? 0;
    const abbrevs = [
      '',
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return m >= 1 && m <= 12 ? abbrevs[m] : month;
  }

  factory MonthlyStatModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatModel(
      month: json['month'] as String,
      income: (json['income'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
    );
  }
}
