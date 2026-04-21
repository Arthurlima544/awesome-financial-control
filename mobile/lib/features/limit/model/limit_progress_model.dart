import '../../../shared/utils/currency_formatter.dart';

class LimitProgressModel {
  const LimitProgressModel({
    required this.id,
    required this.categoryName,
    required this.limitAmount,
    required this.spent,
    required this.percentage,
  });

  final String id;
  final String categoryName;
  final double limitAmount;
  final double spent;
  final double percentage;

  bool get isOverLimit => spent > limitAmount;

  String get spentFormatted => CurrencyFormatter.format(spent);
  String get limitAmountFormatted => CurrencyFormatter.format(limitAmount);
  String get percentageFormatted => '${percentage.toStringAsFixed(0)}%';

  double get progress => (percentage / 100).clamp(0.0, 1.0);

  factory LimitProgressModel.fromJson(Map<String, dynamic> json) {
    return LimitProgressModel(
      id: json['id'] as String,
      categoryName: json['categoryName'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      spent: (json['spent'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}
