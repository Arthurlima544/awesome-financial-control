import 'package:afc/models/transaction_model.dart';

enum RecurrenceFrequency { daily, weekly, monthly }

class RecurringTransactionModel {
  final String id;
  final String description;
  final double amount;
  final TransactionType type;
  final String? category;
  final RecurrenceFrequency frequency;
  final DateTime nextDueAt;
  final bool active;

  RecurringTransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    this.category,
    required this.frequency,
    required this.nextDueAt,
    required this.active,
  });

  factory RecurringTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecurringTransactionModel(
      id: json['id'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name.toUpperCase() == json['type'],
      ),
      category: json['category'],
      frequency: RecurrenceFrequency.values.firstWhere(
        (e) => e.name.toUpperCase() == json['frequency'],
      ),
      nextDueAt: DateTime.parse(json['nextDueAt']).toLocal(),
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'description': description,
      'amount': amount,
      'type': type.name.toUpperCase(),
      'category': category,
      'frequency': frequency.name.toUpperCase(),
      'nextDueAt': nextDueAt.toUtc().toIso8601String(),
      'active': active,
    };
  }

  RecurringTransactionModel copyWith({
    String? id,
    String? description,
    double? amount,
    TransactionType? type,
    String? category,
    RecurrenceFrequency? frequency,
    DateTime? nextDueAt,
    bool? active,
  }) {
    return RecurringTransactionModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      active: active ?? this.active,
    );
  }
}
