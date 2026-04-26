import 'package:equatable/equatable.dart';

class AssetPerformance extends Equatable {
  final String? ticker;
  final String name;
  final double profitLoss;
  final double percentage;

  const AssetPerformance({
    this.ticker,
    required this.name,
    required this.profitLoss,
    required this.percentage,
  });

  factory AssetPerformance.fromJson(Map<String, dynamic> json) {
    return AssetPerformance(
      ticker: json['ticker'] as String?,
      name: json['name'] as String,
      profitLoss: (json['profitLoss'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'name': name,
      'profitLoss': profitLoss,
      'percentage': percentage,
    };
  }

  @override
  List<Object?> get props => [ticker, name, profitLoss, percentage];
}

class InvestmentDashboardData extends Equatable {
  final double totalProfitLoss;
  final double totalProfitLossPercentage;
  final double currentTotalValue;
  final double totalInvested;
  final Map<String, double> allocationByType;
  final List<AssetPerformance> assetPerformance;

  const InvestmentDashboardData({
    required this.totalProfitLoss,
    required this.totalProfitLossPercentage,
    required this.currentTotalValue,
    required this.totalInvested,
    required this.allocationByType,
    required this.assetPerformance,
  });

  factory InvestmentDashboardData.fromJson(Map<String, dynamic> json) {
    final allocationMap = <String, double>{};
    if (json['allocationByType'] != null) {
      (json['allocationByType'] as Map<String, dynamic>).forEach((key, value) {
        allocationMap[key] = (value as num).toDouble();
      });
    }

    return InvestmentDashboardData(
      totalProfitLoss: (json['totalProfitLoss'] as num).toDouble(),
      totalProfitLossPercentage: (json['totalProfitLossPercentage'] as num)
          .toDouble(),
      currentTotalValue: (json['currentTotalValue'] as num).toDouble(),
      totalInvested: (json['totalInvested'] as num).toDouble(),
      allocationByType: allocationMap,
      assetPerformance: (json['assetPerformance'] as List<dynamic>)
          .map((e) => AssetPerformance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalProfitLoss': totalProfitLoss,
      'totalProfitLossPercentage': totalProfitLossPercentage,
      'currentTotalValue': currentTotalValue,
      'totalInvested': totalInvested,
      'allocationByType': allocationByType,
      'assetPerformance': assetPerformance.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    totalProfitLoss,
    totalProfitLossPercentage,
    currentTotalValue,
    totalInvested,
    allocationByType,
    assetPerformance,
  ];
}
