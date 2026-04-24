enum TransactionType { income, expense }

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    this.category,
    required this.occurredAt,
    this.isPassive = false,
    this.investmentId,
  });

  final String id;
  final String description;
  final double amount;
  final TransactionType type;
  final String? category;
  final DateTime occurredAt;
  final bool isPassive;
  final String? investmentId;

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] == 'INCOME'
          ? TransactionType.income
          : TransactionType.expense,
      category: json['category'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      isPassive: json['isPassive'] as bool? ?? false,
      investmentId: json['investmentId'] as String?,
    );
  }
}
