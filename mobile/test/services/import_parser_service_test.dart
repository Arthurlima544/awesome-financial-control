import 'package:flutter_test/flutter_test.dart';
import 'package:afc/services/import_parser_service.dart';
import 'package:afc/view_models/import/import_state.dart';
import 'package:afc/models/transaction_model.dart';

void main() {
  group('ImportParserService', () {
    late ImportParserService parserService;

    setUp(() {
      parserService = ImportParserService();
    });

    test('parses Nubank Extrato correctly', () {
      const extratoCsv = '''Data,Valor,Identificador,Descrição
01/02/2026,-81.69,697f772d-7471-47cd-bac2-f5bf4a7d0ac5,Pagamento de fatura
06/02/2026,4023.27,69856822-6d8e-4516-a211-66db0f94199d,Transferência recebida pelo Pix - PLACE''';

      final candidates = parserService.parse(
        extratoCsv,
        ImportBank.nubank,
        ImportType.extrato,
      );

      expect(candidates.length, 2);

      expect(candidates[0].occurredAt.year, 2026);
      expect(candidates[0].occurredAt.month, 2);
      expect(candidates[0].occurredAt.day, 1);
      expect(candidates[0].amount, 81.69);
      expect(candidates[0].type, TransactionType.expense);
      expect(candidates[0].description, 'Pagamento de fatura');

      expect(candidates[1].occurredAt.day, 6);
      expect(candidates[1].amount, 4023.27);
      expect(candidates[1].type, TransactionType.income);
      expect(
        candidates[1].description,
        'Transferência recebida pelo Pix - PLACE',
      );
    });

    test('parses Nubank Fatura correctly', () {
      const faturaCsv = '''date,title,amount
2026-02-14,Google Play Pass,9.90
2026-02-01,Pagamento recebido,-81.69''';

      final candidates = parserService.parse(
        faturaCsv,
        ImportBank.nubank,
        ImportType.fatura,
      );

      expect(candidates.length, 2);

      expect(candidates[0].occurredAt.year, 2026);
      expect(candidates[0].occurredAt.month, 2);
      expect(candidates[0].occurredAt.day, 14);
      expect(candidates[0].amount, 9.90);
      expect(candidates[0].type, TransactionType.expense);
      expect(candidates[0].description, 'Google Play Pass');

      expect(candidates[1].occurredAt.day, 1);
      expect(candidates[1].amount, 81.69);
      expect(candidates[1].type, TransactionType.income);
      expect(candidates[1].description, 'Pagamento recebido');
    });

    test('parses OFX correctly', () {
      const ofxData = '''
<STMTTRN>
<TRNTYPE>DEBIT
<DTPOSTED>20260215120000
<TRNAMT>-15.50
<MEMO>Compra no mercado
</STMTTRN>
<STMTTRN>
<TRNTYPE>CREDIT
<DTPOSTED>20260216120000
<TRNAMT>1000.00
<NAME>Salário
</STMTTRN>
''';

      final candidates = parserService.parse(
        ofxData,
        ImportBank.generic,
        ImportType.ofx,
      );

      expect(candidates.length, 2);

      expect(candidates[0].occurredAt.year, 2026);
      expect(candidates[0].occurredAt.month, 2);
      expect(candidates[0].occurredAt.day, 15);
      expect(candidates[0].amount, 15.50);
      expect(candidates[0].type, TransactionType.expense);
      expect(candidates[0].description, 'Compra no mercado');

      expect(candidates[1].amount, 1000.00);
      expect(candidates[1].type, TransactionType.income);
      expect(candidates[1].description, 'Salário');
    });
  });
}
