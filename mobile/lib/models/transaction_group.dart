import 'transaction_model.dart';

class TransactionGroup {
  const TransactionGroup({
    required this.label,
    required this.transactions,
    required this.total,
  });

  final String label;
  final List<TransactionModel> transactions;
  final double total;
}
