import 'package:flutter_test/flutter_test.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/services/transaction_grouper.dart';

void main() {
  late TransactionGrouper grouper;
  final labels = {
    'pix': 'PIX',
    'bank': 'Bank',
    'transport': 'Transport',
    'delivery': 'Delivery',
    'market': 'Market',
    'subscription': 'Subscription',
    'other': 'Other',
  };

  setUp(() {
    grouper = TransactionGrouper();
  });

  group('TransactionGrouper', () {
    test('should group PIX transactions', () {
      final transactions = [
        TransactionModel(
          id: '1',
          description: 'PIX Recebido',
          amount: 100,
          type: TransactionType.income,
          occurredAt: DateTime.now(),
        ),
        TransactionModel(
          id: '2',
          description: 'Pagamento via PIX',
          amount: 50,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
      ];

      final groups = grouper.group(transactions, labels);
      expect(groups.length, 1);
      expect(groups[0].label, 'PIX');
      expect(groups[0].transactions.length, 2);
      expect(groups[0].total, 150);
    });

    test('should group Transport transactions', () {
      final transactions = [
        TransactionModel(
          id: '1',
          description: 'UBER TRIP',
          amount: 25,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
        TransactionModel(
          id: '2',
          description: '99APP',
          amount: 15,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
      ];

      final groups = grouper.group(transactions, labels);
      expect(groups.any((g) => g.label == 'Transport'), isTrue);
      final group = groups.firstWhere((g) => g.label == 'Transport');
      expect(group.transactions.length, 2);
      expect(group.total, 40);
    });

    test('should group Delivery transactions', () {
      final transactions = [
        TransactionModel(
          id: '1',
          description: 'IFOOD *RESTAURANTE',
          amount: 60,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
        TransactionModel(
          id: '2',
          description: 'RAPPI DELIVERY',
          amount: 10,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
      ];

      final groups = grouper.group(transactions, labels);
      expect(groups.any((g) => g.label == 'Delivery'), isTrue);
      final group = groups.firstWhere((g) => g.label == 'Delivery');
      expect(group.transactions.length, 2);
    });

    test('should group Market transactions', () {
      final transactions = [
        TransactionModel(
          id: '1',
          description: 'MERCADO CENTRAL',
          amount: 150,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
        TransactionModel(
          id: '2',
          description: 'SUPERMERCADO BH',
          amount: 200,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
        TransactionModel(
          id: '3',
          description: 'CARREFOUR BR',
          amount: 50,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
      ];

      final groups = grouper.group(transactions, labels);
      expect(groups.any((g) => g.label == 'Market'), isTrue);
      final group = groups.firstWhere((g) => g.label == 'Market');
      expect(group.transactions.length, 3);
      expect(group.total, 400);
    });

    test('should group Subscription transactions', () {
      final transactions = [
        TransactionModel(
          id: '1',
          description: 'NETFLIX.COM',
          amount: 39.9,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
        TransactionModel(
          id: '2',
          description: 'SPOTIFY PREMIUM',
          amount: 19.9,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
      ];

      final groups = grouper.group(transactions, labels);
      expect(groups.any((g) => g.label == 'Subscription'), isTrue);
    });

    test('should group mixed transactions correctly', () {
      final transactions = [
        TransactionModel(
          id: '1',
          description: 'PIX',
          amount: 10,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
        TransactionModel(
          id: '2',
          description: 'UBER',
          amount: 20,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
        TransactionModel(
          id: '3',
          description: 'ALUGUEL',
          amount: 1000,
          type: TransactionType.expense,
          occurredAt: DateTime.now(),
        ),
      ];

      final groups = grouper.group(transactions, labels);
      expect(groups.length, 3);
      expect(groups.any((g) => g.label == 'PIX'), isTrue);
      expect(groups.any((g) => g.label == 'Transport'), isTrue);
      expect(groups.any((g) => g.label == 'Other'), isTrue);
    });
  });
}
