class PassiveIncomeMonth {
  final String month;
  final double amount;

  const PassiveIncomeMonth({required this.month, required this.amount});

  factory PassiveIncomeMonth.fromJson(Map<String, dynamic> json) {
    return PassiveIncomeMonth(
      month: json['month'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'month': month, 'amount': amount};
  }
}

class PassiveIncomeData {
  final double freedomIndex;
  final double totalPassiveIncomeCurrentMonth;
  final List<PassiveIncomeMonth> monthlyProgression;
  final Map<String, double> incomeByInvestment;

  const PassiveIncomeData({
    required this.freedomIndex,
    required this.totalPassiveIncomeCurrentMonth,
    required this.monthlyProgression,
    required this.incomeByInvestment,
  });

  factory PassiveIncomeData.fromJson(Map<String, dynamic> json) {
    final incomeMap = <String, double>{};
    if (json['incomeByInvestment'] != null) {
      (json['incomeByInvestment'] as Map<String, dynamic>).forEach((
        key,
        value,
      ) {
        incomeMap[key] = (value as num).toDouble();
      });
    }

    return PassiveIncomeData(
      freedomIndex: (json['freedomIndex'] as num).toDouble(),
      totalPassiveIncomeCurrentMonth:
          (json['totalPassiveIncomeCurrentMonth'] as num).toDouble(),
      monthlyProgression: (json['monthlyProgression'] as List<dynamic>)
          .map((e) => PassiveIncomeMonth.fromJson(e as Map<String, dynamic>))
          .toList(),
      incomeByInvestment: incomeMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'freedomIndex': freedomIndex,
      'totalPassiveIncomeCurrentMonth': totalPassiveIncomeCurrentMonth,
      'monthlyProgression': monthlyProgression.map((e) => e.toJson()).toList(),
      'incomeByInvestment': incomeByInvestment,
    };
  }
}
