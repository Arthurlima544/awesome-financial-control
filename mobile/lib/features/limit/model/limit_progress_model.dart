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
