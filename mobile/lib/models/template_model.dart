import 'package:equatable/equatable.dart';
import 'package:afc/models/transaction_model.dart';

class TemplateModel extends Equatable {
  final String id;
  final String description;
  final String? category;
  final TransactionType type;

  const TemplateModel({
    required this.id,
    required this.description,
    this.category,
    required this.type,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as String,
      description: json['description'] as String,
      category: json['category'] as String?,
      type: TransactionType.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['type'] as String).toUpperCase(),
        orElse: () => TransactionType.expense,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'category': category,
      'type': type.name.toUpperCase(),
    };
  }

  @override
  List<Object?> get props => [id, description, category, type];
}
