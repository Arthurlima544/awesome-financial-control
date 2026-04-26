class CompoundTimelinePoint {
  final double year;
  final double accumulated;
  final double invested;

  const CompoundTimelinePoint({
    required this.year,
    required this.accumulated,
    required this.invested,
  });

  factory CompoundTimelinePoint.fromJson(Map<String, dynamic> json) {
    return CompoundTimelinePoint(
      year: (json['year'] as num).toDouble(),
      accumulated: (json['accumulated'] as num).toDouble(),
      invested: (json['invested'] as num).toDouble(),
    );
  }
}

class CompoundInterestResult {
  final double finalAmount;
  final double totalInvested;
  final double totalInterest;
  final List<CompoundTimelinePoint> timeline;

  const CompoundInterestResult({
    required this.finalAmount,
    required this.totalInvested,
    required this.totalInterest,
    required this.timeline,
  });

  factory CompoundInterestResult.fromJson(Map<String, dynamic> json) {
    return CompoundInterestResult(
      finalAmount: (json['finalAmount'] as num).toDouble(),
      totalInvested: (json['totalInvested'] as num).toDouble(),
      totalInterest: (json['totalInterest'] as num).toDouble(),
      timeline: (json['timeline'] as List<dynamic>)
          .map((e) => CompoundTimelinePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
