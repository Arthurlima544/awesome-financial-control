import 'package:afc/models/monthly_report_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:afc/utils/app_formatters.dart';

class PdfReportService {
  Future<void> generateAndShare(
    MonthlyReportModel report,
    DateTime month,
  ) async {
    final pdf = pw.Document();
    final monthStr = AppFormatters.monthYearFull.format(month);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Relatorio Financeiro - AFC',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(monthStr, style: const pw.TextStyle(fontSize: 18)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Entradas',
                AppFormatters.currencyPtBR.format(report.totalIncome),
              ),
              _buildSummaryItem(
                'Saidas',
                AppFormatters.currencyPtBR.format(report.totalExpenses),
              ),
              _buildSummaryItem(
                'Economia',
                '${report.savingsRate.toStringAsFixed(1)}%',
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'Gastos por Categoria',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            data: <List<String>>[
              <String>['Categoria', 'Valor', '%'],
              ...report.categories.map(
                (c) => [
                  c.category ?? 'Outros',
                  AppFormatters.currencyPtBR.format(c.amount),
                  '${c.percentage.toStringAsFixed(1)}%',
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Text(
            'Comparativo MoM',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            data: <List<String>>[
              <String>['Categoria', 'Mes Anterior', 'Mes Atual', 'Variacao'],
              ...report.comparison.map((c) {
                final diff = c.currentAmount - c.previousAmount;
                final diffStr = diff > 0
                    ? '+${AppFormatters.currencyPtBR.format(diff)}'
                    : AppFormatters.currencyPtBR.format(diff);
                return [
                  c.category ?? 'Outros',
                  AppFormatters.currencyPtBR.format(c.previousAmount),
                  AppFormatters.currencyPtBR.format(c.currentAmount),
                  diffStr,
                ];
              }),
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'afc_report_${month.year}_${month.month}.pdf',
    );
  }

  pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(height: 5),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}
