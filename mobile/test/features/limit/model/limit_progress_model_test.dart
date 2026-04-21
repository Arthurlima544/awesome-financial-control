import 'package:flutter_test/flutter_test.dart';
import 'package:afc/features/limit/model/limit_progress_model.dart';

void main() {
  group('LimitProgressModel', () {
    test('isOverLimit returns true when spent > limitAmount', () {
      const limit = LimitProgressModel(
        id: '1',
        categoryName: 'Test',
        limitAmount: 1000,
        spent: 1001,
        percentage: 100.1,
      );

      expect(limit.isOverLimit, isTrue);
    });

    test('isOverLimit returns false when spent <= limitAmount', () {
      const limit1 = LimitProgressModel(
        id: '1',
        categoryName: 'Test',
        limitAmount: 1000,
        spent: 1000,
        percentage: 100,
      );

      const limit2 = LimitProgressModel(
        id: '2',
        categoryName: 'Test',
        limitAmount: 1000,
        spent: 900,
        percentage: 90,
      );

      expect(limit1.isOverLimit, isFalse);
      expect(limit2.isOverLimit, isFalse);
    });

    test('progress calculates correctly', () {
      const limit = LimitProgressModel(
        id: '1',
        categoryName: 'Test',
        limitAmount: 1000,
        spent: 500,
        percentage: 50,
      );

      expect(limit.progress, equals(0.5));
    });

    test('progress is clamped to 1.0 when over limit', () {
      const limit = LimitProgressModel(
        id: '1',
        categoryName: 'Test',
        limitAmount: 1000,
        spent: 1500,
        percentage: 150,
      );

      expect(limit.progress, equals(1.0));
    });
  });
}
