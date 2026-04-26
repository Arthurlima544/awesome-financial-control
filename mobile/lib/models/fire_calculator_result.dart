class FireTimelinePoint {
  final double year;
  final double portfolioValue;

  const FireTimelinePoint({required this.year, required this.portfolioValue});

  factory FireTimelinePoint.fromJson(Map<String, dynamic> json) {
    return FireTimelinePoint(
      year: (json['year'] as num).toDouble(),
      portfolioValue: (json['portfolioValue'] as num).toDouble(),
    );
  }
}

class FireCalculatorResult {
  final double fireNumber;
  final int monthsToFire;
  final DateTime retirementDate;
  final List<FireTimelinePoint> yearlyTimeline;
  final double fiScore;

  const FireCalculatorResult({
    required this.fireNumber,
    required this.monthsToFire,
    required this.retirementDate,
    required this.yearlyTimeline,
    required this.fiScore,
  });

  factory FireCalculatorResult.fromJson(Map<String, dynamic> json) {
    return FireCalculatorResult(
      fireNumber: (json['fireNumber'] as num).toDouble(),
      monthsToFire: (json['monthsToFire'] as num).toInt(),
      retirementDate: DateTime.parse(json['retirementDate'] as String),
      yearlyTimeline: (json['yearlyTimeline'] as List<dynamic>)
          .map((e) => FireTimelinePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      fiScore: ((json['fiScore'] ?? 0.0) as num).toDouble(),
    );
  }
}
