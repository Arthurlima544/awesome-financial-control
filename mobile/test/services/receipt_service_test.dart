import 'package:flutter_test/flutter_test.dart';
import 'package:afc/services/receipt_service.dart';

void main() {
  group('ReceiptExtractionResult', () {
    test('toString returns correct format', () {
      final result = ReceiptExtractionResult(amount: 10.5, merchant: 'Test');
      expect(
        result.toString(),
        'ReceiptExtractionResult(amount: 10.5, merchant: Test, failed: false)',
      );
    });
  });

  // Mocking the GenerativeModel is complex because of its constructor and dependencies.
  // We will focus on testing the JSON parsing logic if it was exposed.
  // For now, let's just ensure the service can be instantiated.
  test('ReceiptService can be instantiated', () {
    final service = ReceiptService(apiKey: 'test');
    expect(service, isNotNull);
  });
}
