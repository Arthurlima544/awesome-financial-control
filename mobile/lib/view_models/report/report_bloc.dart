import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/models/monthly_report_model.dart';
import 'package:afc/repositories/report_repository.dart';
import 'package:afc/services/pdf_report_service.dart';
import 'package:intl/intl.dart';

// Events
abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class LoadReport extends ReportEvent {
  final DateTime month;
  const LoadReport(this.month);
  @override
  List<Object?> get props => [month];
}

class ChangeMonth extends ReportEvent {
  final DateTime month;
  const ChangeMonth(this.month);
  @override
  List<Object?> get props => [month];
}

class ExportToPdf extends ReportEvent {}

// State
enum ReportStatus { initial, loading, success, failure }

class ReportState extends Equatable {
  final ReportStatus status;
  final DateTime selectedMonth;
  final MonthlyReportModel? report;
  final String? errorMessage;

  const ReportState({
    this.status = ReportStatus.initial,
    required this.selectedMonth,
    this.report,
    this.errorMessage,
  });

  ReportState copyWith({
    ReportStatus? status,
    DateTime? selectedMonth,
    MonthlyReportModel? report,
    String? errorMessage,
  }) {
    return ReportState(
      status: status ?? this.status,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      report: report ?? this.report,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, selectedMonth, report, errorMessage];
}

// Bloc
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository _repository;
  final PdfReportService _pdfService;

  ReportBloc({
    required ReportRepository repository,
    PdfReportService? pdfService,
  }) : _repository = repository,
       _pdfService = pdfService ?? PdfReportService(),
       super(ReportState(selectedMonth: DateTime.now())) {
    on<LoadReport>(_onLoadReport);
    on<ChangeMonth>(_onChangeMonth);
    on<ExportToPdf>(_onExportToPdf);
  }

  Future<void> _onLoadReport(
    LoadReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(state.copyWith(status: ReportStatus.loading));
    try {
      final monthStr = DateFormat('yyyy-MM').format(event.month);
      final report = await _repository.getMonthlyReport(monthStr);
      emit(state.copyWith(status: ReportStatus.success, report: report));
    } catch (e) {
      emit(
        state.copyWith(
          status: ReportStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onChangeMonth(ChangeMonth event, Emitter<ReportState> emit) {
    emit(state.copyWith(selectedMonth: event.month));
    add(LoadReport(event.month));
  }

  Future<void> _onExportToPdf(
    ExportToPdf event,
    Emitter<ReportState> emit,
  ) async {
    if (state.report == null) return;
    try {
      await _pdfService.generateAndShare(state.report!, state.selectedMonth);
    } catch (e) {
      emit(
        state.copyWith(
          status: ReportStatus.failure,
          errorMessage: 'Erro ao exportar PDF: $e',
        ),
      );
    }
  }
}
