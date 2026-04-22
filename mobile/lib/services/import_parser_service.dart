import 'package:afc/view_models/import/import_state.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/models/import_candidate_model.dart';

class ImportParserService {
  List<ImportCandidateModel> parse(
    String content,
    ImportBank bank,
    ImportType type,
  ) {
    if (bank == ImportBank.nubank) {
      if (type == ImportType.extrato) {
        return _parseNubankExtrato(content);
      } else if (type == ImportType.fatura) {
        return _parseNubankFatura(content);
      }
    }

    // Default to OFX for anything else if it's OFX type
    if (type == ImportType.ofx) {
      return _parseOfx(content);
    }

    return [];
  }

  List<List<dynamic>> _parseCsv(String content) {
    final result = <List<dynamic>>[];
    final lines = content.split('\n');
    for (var line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      final row = <dynamic>[];
      var current = StringBuffer();
      var inQuotes = false;
      for (var i = 0; i < line.length; i++) {
        var char = line[i];
        if (char == '"') {
          if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
            current.write('"');
            i++;
          } else {
            inQuotes = !inQuotes;
          }
        } else if (char == ',' && !inQuotes) {
          row.add(_parseValue(current.toString()));
          current.clear();
        } else {
          current.write(char);
        }
      }
      row.add(_parseValue(current.toString()));
      result.add(row);
    }
    return result;
  }

  dynamic _parseValue(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return null;
    final numValue = double.tryParse(trimmed.replaceAll(',', '.'));
    if (numValue != null) return numValue;
    return trimmed;
  }

  List<ImportCandidateModel> _parseOfx(String content) {
    final candidates = <ImportCandidateModel>[];

    // OFX uses SGML which is not strict XML. Regex is safest.
    final stmtTrnRegex = RegExp(r'<STMTTRN>([\s\S]*?)</STMTTRN>');
    final typeRegex = RegExp(r'<TRNTYPE>(.*?)\r?\n');
    final dateRegex = RegExp(r'<DTPOSTED>([0-9]{8})');
    final amountRegex = RegExp(r'<TRNAMT>(.*?)\r?\n');
    final nameRegex = RegExp(r'<NAME>(.*?)\r?\n');
    final memoRegex = RegExp(r'<MEMO>(.*?)\r?\n');

    final matches = stmtTrnRegex.allMatches(content);
    for (final match in matches) {
      final block = match.group(1) ?? '';

      final typeStr = typeRegex.firstMatch(block)?.group(1)?.trim();
      final dateStr = dateRegex.firstMatch(block)?.group(1)?.trim();
      final amountStr = amountRegex.firstMatch(block)?.group(1)?.trim();
      var nameStr = nameRegex.firstMatch(block)?.group(1)?.trim();
      final memoStr = memoRegex.firstMatch(block)?.group(1)?.trim();

      if (dateStr == null || amountStr == null) continue;

      // Description logic
      var desc = nameStr ?? memoStr ?? 'Unknown';
      if (desc.isEmpty) desc = 'Unknown';

      // Amount & Type
      final amount = double.tryParse(amountStr.replaceAll(',', '.')) ?? 0.0;
      final type = typeStr == 'CRED' || amount >= 0
          ? TransactionType.income
          : TransactionType.expense;

      // Date parsing (YYYYMMDD)
      final year = int.parse(dateStr.substring(0, 4));
      final month = int.parse(dateStr.substring(4, 6));
      final day = int.parse(dateStr.substring(6, 8));
      final date = DateTime.utc(year, month, day);

      candidates.add(
        ImportCandidateModel(
          description: desc,
          amount: amount.abs(),
          type: type,
          occurredAt: date,
        ),
      );
    }

    return candidates;
  }

  List<ImportCandidateModel> _parseNubankExtrato(String content) {
    // Nubank Extrato: Data,Valor,Identificador,Descrição
    // Date format: DD/MM/YYYY
    // Amount format: standard (positive = income, negative = expense)
    final candidates = <ImportCandidateModel>[];
    final rows = _parseCsv(content.replaceAll('\r', ''));

    if (rows.isEmpty) return candidates;

    // Find headers
    int dateIdx = -1, amountIdx = -1, descIdx = -1;
    final headers = rows.first
        .map((e) => e.toString().trim().toLowerCase())
        .toList();

    for (int i = 0; i < headers.length; i++) {
      if (headers[i] == 'data') dateIdx = i;
      if (headers[i] == 'valor') amountIdx = i;
      if (headers[i] == 'descrição' || headers[i] == 'descricao') descIdx = i;
    }

    if (dateIdx == -1 || amountIdx == -1 || descIdx == -1) return candidates;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= dateIdx ||
          row.length <= amountIdx ||
          row.length <= descIdx) {
        continue;
      }

      final dateStr = row[dateIdx].toString().trim();
      final amountStr = row[amountIdx].toString().trim();
      final descStr = row[descIdx].toString().trim();

      if (dateStr.isEmpty || amountStr.isEmpty) {
        continue;
      }

      final parts = dateStr.split('/');
      if (parts.length != 3) continue;
      final date = DateTime.utc(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      final amount = double.tryParse(amountStr.replaceAll(',', '.')) ?? 0.0;
      final type = amount >= 0
          ? TransactionType.income
          : TransactionType.expense;

      candidates.add(
        ImportCandidateModel(
          description: descStr,
          amount: amount.abs(),
          type: type,
          occurredAt: date,
        ),
      );
    }
    return candidates;
  }

  List<ImportCandidateModel> _parseNubankFatura(String content) {
    // Nubank Fatura: date,category,title,amount
    // Date format: YYYY-MM-DD
    // Amount format: inverted (positive = expense, negative = income/payment)
    final candidates = <ImportCandidateModel>[];
    final rows = _parseCsv(content.replaceAll('\r', ''));

    if (rows.isEmpty) return candidates;

    // Find headers
    int dateIdx = -1, amountIdx = -1, titleIdx = -1;
    final headers = rows.first
        .map((e) => e.toString().trim().toLowerCase())
        .toList();

    for (int i = 0; i < headers.length; i++) {
      if (headers[i] == 'date') dateIdx = i;
      if (headers[i] == 'amount') amountIdx = i;
      if (headers[i] == 'title') titleIdx = i;
    }

    if (dateIdx == -1 || amountIdx == -1 || titleIdx == -1) return candidates;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= dateIdx ||
          row.length <= amountIdx ||
          row.length <= titleIdx) {
        continue;
      }

      final dateStr = row[dateIdx].toString().trim();
      final amountStr = row[amountIdx].toString().trim();
      final titleStr = row[titleIdx].toString().trim();

      if (dateStr.isEmpty || amountStr.isEmpty) {
        continue;
      }

      final date = DateTime.tryParse(dateStr) ?? DateTime.now();

      final rawAmount = double.tryParse(amountStr.replaceAll(',', '.')) ?? 0.0;
      // In Fatura, positive is expense (credit card bill item)
      final type = rawAmount >= 0
          ? TransactionType.expense
          : TransactionType.income;

      candidates.add(
        ImportCandidateModel(
          description: titleStr,
          amount: rawAmount.abs(),
          type: type,
          occurredAt: date.toUtc(),
        ),
      );
    }
    return candidates;
  }
}
