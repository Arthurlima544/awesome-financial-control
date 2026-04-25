import 'package:equatable/equatable.dart';
import 'package:afc/models/transaction_model.dart';

class ImportCandidateModel extends Equatable {
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime occurredAt;
  final String? category;
  final bool isSelected;
  final bool isDuplicate;
  final double categoryConfidence;

  const ImportCandidateModel({
    required this.description,
    required this.amount,
    required this.type,
    required this.occurredAt,
    this.category,
    this.isSelected = true,
    this.isDuplicate = false,
    this.categoryConfidence = 0.0,
  });

  ImportCandidateModel copyWith({
    String? description,
    double? amount,
    TransactionType? type,
    DateTime? occurredAt,
    String? category,
    bool? isSelected,
    bool? isDuplicate,
    double? categoryConfidence,
  }) {
    return ImportCandidateModel(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      category: category ?? this.category,
      isSelected: isSelected ?? this.isSelected,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      categoryConfidence: categoryConfidence ?? this.categoryConfidence,
    );
  }

  @override
  List<Object?> get props => [
    description,
    amount,
    type,
    occurredAt,
    category,
    isSelected,
    isDuplicate,
    categoryConfidence,
  ];
}
