import 'package:equatable/equatable.dart';

class BillModel extends Equatable {
  final String id;
  final String name;
  final double amount;
  final int dueDay;
  final String? categoryId;

  const BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDay,
    this.categoryId,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'],
      name: json['name'],
      amount: (json['amount'] as num).toDouble(),
      dueDay: json['dueDay'] as int,
      categoryId: json['categoryId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'dueDay': dueDay,
      'categoryId': categoryId,
    };
  }

  BillModel copyWith({
    String? id,
    String? name,
    double? amount,
    int? dueDay,
    String? categoryId,
  }) {
    return BillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props => [id, name, amount, dueDay, categoryId];
}
