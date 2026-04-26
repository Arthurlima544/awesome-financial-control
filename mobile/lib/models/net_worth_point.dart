import 'package:equatable/equatable.dart';

class NetWorthPoint extends Equatable {
  final String month;
  final double assets;
  final double liabilities;
  final double total;

  const NetWorthPoint({
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

  @override
  List<Object?> get props => [month, assets, liabilities, total];
}
