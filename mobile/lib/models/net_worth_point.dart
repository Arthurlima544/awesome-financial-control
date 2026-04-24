class NetWorthPoint {
  final String month;
  final double assets;
  final double liabilities;
  final double total;

  NetWorthPoint({
    required this.month,
    required this.assets,
    required this.liabilities,
    required this.total,
  });

  factory NetWorthPoint.fromJson(Map<String, dynamic> json) {
    return NetWorthPoint(
      month: json['month'] as String,
      assets: (json['assets'] as num).toDouble(),
      liabilities: (json['liabilities'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}
