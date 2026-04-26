import 'package:equatable/equatable.dart';
import 'package:afc/utils/currency_formatter.dart';

class LimitModel extends Equatable {
  const LimitModel({
    required this.id,
    required this.categoryName,
    required this.amount,
    required this.createdAt,
  });

  final String id;
  final String categoryName;
  final double amount;
  final DateTime createdAt;

  String get formattedAmount => CurrencyFormatter.format(amount);

  factory LimitModel.fromJson(Map<String, dynamic> json) => LimitModel(
    id: json['id'] as String,
    categoryName: json['categoryName'] as String,
    amount: (json['amount'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  @override
  List<Object?> get props => [id, categoryName, amount, createdAt];
}
