import 'package:equatable/equatable.dart';

class MonthlyReportModel extends Equatable {
  final double totalIncome;
  final double totalExpenses;
  final double savingsRate;
  final List<CategoryBreakdownModel> categories;
  final List<CategoryComparisonModel> comparison;

  const MonthlyReportModel({
    required this.totalIncome,
    required this.totalExpenses,
    required this.savingsRate,
    required this.categories,
    required this.comparison,
  });

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) {
    return MonthlyReportModel(
      totalIncome: (json['totalIncome'] as num).toDouble(),
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      savingsRate: (json['savingsRate'] as num).toDouble(),
      categories: (json['categories'] as List)
          .map((e) => CategoryBreakdownModel.fromJson(e))
          .toList(),
      comparison: (json['comparison'] as List)
          .map((e) => CategoryComparisonModel.fromJson(e))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpenses,
    savingsRate,
    categories,
    comparison,
  ];
}

class CategoryBreakdownModel extends Equatable {
  final String? category;
  final double amount;
  final double percentage;

  const CategoryBreakdownModel({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownModel(
      category: json['category'] as String?,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [category, amount, percentage];
}

class CategoryComparisonModel extends Equatable {
  final String? category;
  final double currentAmount;
  final double previousAmount;

  const CategoryComparisonModel({
    required this.category,
    required this.currentAmount,
    required this.previousAmount,
  });

  factory CategoryComparisonModel.fromJson(Map<String, dynamic> json) {
    return CategoryComparisonModel(
      category: json['category'] as String?,
      currentAmount: (json['currentAmount'] as num).toDouble(),
      previousAmount: (json['previousAmount'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [category, currentAmount, previousAmount];
}
