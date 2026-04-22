import 'package:afc/models/monthly_report_model.dart';
import 'package:afc/services/report_service.dart';

abstract class ReportRepository {
  Future<MonthlyReportModel> getMonthlyReport(String month);
}

class ReportRepositoryImpl implements ReportRepository {
  final ReportService _service;

  ReportRepositoryImpl({ReportService? service})
    : _service = service ?? ReportService();

  @override
  Future<MonthlyReportModel> getMonthlyReport(String month) async {
    return _service.fetchMonthlyReport(month);
  }
}
