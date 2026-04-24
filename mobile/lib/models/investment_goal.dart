class InvestmentGoalRequest {
  final double targetAmount;
  final DateTime targetDate;
  final double annualReturnRate;
  final double initialAmount;

  InvestmentGoalRequest({
    required this.targetAmount,
    required this.targetDate,
    required this.annualReturnRate,
    required this.initialAmount,
  });

  Map<String, dynamic> toJson() => {
    'targetAmount': targetAmount,
    'targetDate': targetDate.toIso8601String().split('T')[0],
    'annualReturnRate': annualReturnRate,
    'initialAmount': initialAmount,
  };
}

class InvestmentGoalResponse {
  final double requiredMonthlyContribution;
  final double totalContributed;
  final double totalInterestEarned;
  final List<InvestmentGoalTimelineEntry> timeline;

  InvestmentGoalResponse({
    required this.requiredMonthlyContribution,
    required this.totalContributed,
    required this.totalInterestEarned,
    required this.timeline,
  });

  factory InvestmentGoalResponse.fromJson(Map<String, dynamic> json) {
    return InvestmentGoalResponse(
      requiredMonthlyContribution: (json['requiredMonthlyContribution'] as num)
          .toDouble(),
      totalContributed: (json['totalContributed'] as num).toDouble(),
      totalInterestEarned: (json['totalInterestEarned'] as num).toDouble(),
      timeline: (json['timeline'] as List)
          .map((e) => InvestmentGoalTimelineEntry.fromJson(e))
          .toList(),
    );
  }
}

class InvestmentGoalTimelineEntry {
  final double years;
  final double invested;
  final double accumulated;

  InvestmentGoalTimelineEntry({
    required this.years,
    required this.invested,
    required this.accumulated,
  });

  factory InvestmentGoalTimelineEntry.fromJson(Map<String, dynamic> json) {
    return InvestmentGoalTimelineEntry(
      years: (json['years'] as num).toDouble(),
      invested: (json['invested'] as num).toDouble(),
      accumulated: (json['accumulated'] as num).toDouble(),
    );
  }
}
