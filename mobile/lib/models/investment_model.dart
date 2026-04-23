import 'package:equatable/equatable.dart';

enum InvestmentType {
  stock,
  fixedIncome,
  crypto,
  other;

  String toJson() => name.toUpperCase();

  static InvestmentType fromJson(String json) {
    switch (json.toUpperCase()) {
      case 'STOCK':
        return InvestmentType.stock;
      case 'FIXED_INCOME':
        return InvestmentType.fixedIncome;
      case 'CRYPTO':
        return InvestmentType.crypto;
      default:
        return InvestmentType.other;
    }
  }
}

class InvestmentModel extends Equatable {
  final String id;
  final String name;
  final String? ticker;
  final InvestmentType type;
  final double quantity;
  final double avgCost;
  final double currentPrice;
  final double totalCost;
  final double currentValue;
  final double gainLoss;
  final double gainLossPercentage;

  const InvestmentModel({
    required this.id,
    required this.name,
    this.ticker,
    required this.type,
    required this.quantity,
    required this.avgCost,
    required this.currentPrice,
    required this.totalCost,
    required this.currentValue,
    required this.gainLoss,
    required this.gainLossPercentage,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ticker: json['ticker'] as String?,
      type: InvestmentType.fromJson(json['type'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      avgCost: (json['avgCost'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      totalCost: (json['totalCost'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      gainLoss: (json['gainLoss'] as num).toDouble(),
      gainLossPercentage: (json['gainLossPercentage'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    ticker,
    type,
    quantity,
    avgCost,
    currentPrice,
    totalCost,
    currentValue,
    gainLoss,
    gainLossPercentage,
  ];
}
