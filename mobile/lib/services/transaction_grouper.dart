import 'package:afc/models/transaction_group.dart';
import 'package:afc/models/transaction_model.dart';

class TransactionGrouper {
  List<TransactionGroup> group(
    List<TransactionModel> transactions,
    Map<String, String> labels,
  ) {
    final Map<String, List<TransactionModel>> groups = {
      labels['pix'] ?? 'Transferências PIX': [],
      labels['bank'] ?? 'Transferências bancárias': [],
      labels['transport'] ?? 'Transporte por app': [],
      labels['delivery'] ?? 'Delivery': [],
      labels['market'] ?? 'Supermercado': [],
      labels['subscription'] ?? 'Assinaturas': [],
      labels['other'] ?? 'Outros': [],
    };

    for (final t in transactions) {
      final desc = t.description.toUpperCase();

      if (desc.contains('PIX')) {
        groups[labels['pix'] ?? 'Transferências PIX']!.add(t);
      } else if (desc.contains('TED') || desc.contains('DOC')) {
        groups[labels['bank'] ?? 'Transferências bancárias']!.add(t);
      } else if (desc.contains('UBER') ||
          desc.contains('99') ||
          desc.contains('CABIFY')) {
        groups[labels['transport'] ?? 'Transporte por app']!.add(t);
      } else if (desc.contains('IFOOD') ||
          desc.contains('RAPPI') ||
          desc.contains('DELIVERY')) {
        groups[labels['delivery'] ?? 'Delivery']!.add(t);
      } else if (desc.contains('MERCADO') ||
          desc.contains('SUPERMERCADO') ||
          desc.contains('PÃO DE AÇÚCAR') ||
          desc.contains('CARREFOUR')) {
        groups[labels['market'] ?? 'Supermercado']!.add(t);
      } else if (desc.contains('NETFLIX') ||
          desc.contains('SPOTIFY') ||
          desc.contains('AMAZON') ||
          desc.contains('APPLE')) {
        groups[labels['subscription'] ?? 'Assinaturas']!.add(t);
      } else {
        groups[labels['other'] ?? 'Outros']!.add(t);
      }
    }

    return groups.entries
        .where((e) => e.value.isNotEmpty)
        .map(
          (e) => TransactionGroup(
            label: e.key,
            transactions: e.value,
            total: e.value.fold(0.0, (sum, t) => sum + t.amount),
          ),
        )
        .toList();
  }
}
