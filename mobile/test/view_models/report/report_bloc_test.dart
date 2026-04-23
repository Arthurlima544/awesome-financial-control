import 'package:afc/models/monthly_report_model.dart';
import 'package:afc/repositories/report_repository.dart';
import 'package:afc/services/pdf_report_service.dart';
import 'package:afc/view_models/report/report_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockReportRepository extends Mock implements ReportRepository {}

class MockPdfReportService extends Mock implements PdfReportService {}

void main() {
  late ReportBloc reportBloc;
  late MockReportRepository mockRepository;
  late MockPdfReportService mockPdfService;

  final tReport = MonthlyReportModel(
    totalIncome: 5000,
    totalExpenses: 2000,
    savingsRate: 60,
    categories: const [
      CategoryBreakdownModel(category: 'Food', amount: 500, percentage: 25),
    ],
    comparison: const [
      CategoryComparisonModel(
        category: 'Food',
        currentAmount: 500,
        previousAmount: 400,
      ),
    ],
  );

  final tMonth = DateTime(2024, 3);

  setUpAll(() {
    registerFallbackValue(DateTime.now());
    registerFallbackValue(tReport);
  });

  setUp(() {
    mockRepository = MockReportRepository();
    mockPdfService = MockPdfReportService();
    reportBloc = ReportBloc(
      repository: mockRepository,
      pdfService: mockPdfService,
    );
  });

  group('ReportBloc', () {
    test('initial state is correct', () {
      expect(reportBloc.state.status, ReportStatus.initial);
      expect(reportBloc.state.report, isNull);
    });

    blocTest<ReportBloc, ReportState>(
      'emits [loading, success] when LoadReport is successful',
      build: () {
        when(
          () => mockRepository.getMonthlyReport(any()),
        ).thenAnswer((_) async => tReport);
        return reportBloc;
      },
      act: (bloc) => bloc.add(LoadReport(tMonth)),
      expect: () => [
        isA<ReportState>().having(
          (s) => s.status,
          'status',
          ReportStatus.loading,
        ),
        isA<ReportState>()
            .having((s) => s.status, 'status', ReportStatus.success)
            .having((s) => s.report, 'report', tReport),
      ],
    );

    blocTest<ReportBloc, ReportState>(
      'emits [loading, failure] when LoadReport fails',
      build: () {
        when(
          () => mockRepository.getMonthlyReport(any()),
        ).thenThrow(Exception('Error'));
        return reportBloc;
      },
      act: (bloc) => bloc.add(LoadReport(tMonth)),
      expect: () => [
        isA<ReportState>().having(
          (s) => s.status,
          'status',
          ReportStatus.loading,
        ),
        isA<ReportState>()
            .having((s) => s.status, 'status', ReportStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', contains('Error')),
      ],
    );

    blocTest<ReportBloc, ReportState>(
      'emits correct state when ChangeMonth is called',
      build: () {
        when(
          () => mockRepository.getMonthlyReport(any()),
        ).thenAnswer((_) async => tReport);
        return reportBloc;
      },
      act: (bloc) => bloc.add(ChangeMonth(tMonth)),
      expect: () => [
        isA<ReportState>().having(
          (s) => s.selectedMonth,
          'selectedMonth',
          tMonth,
        ),
        isA<ReportState>().having(
          (s) => s.status,
          'status',
          ReportStatus.loading,
        ),
        isA<ReportState>().having(
          (s) => s.status,
          'status',
          ReportStatus.success,
        ),
      ],
    );

    blocTest<ReportBloc, ReportState>(
      'calls pdf service when ExportToPdf is added',
      build: () {
        when(
          () => mockPdfService.generateAndShare(any(), any()),
        ).thenAnswer((_) async {});
        return reportBloc;
      },
      seed: () => ReportState(
        selectedMonth: tMonth,
        report: tReport,
        status: ReportStatus.success,
      ),
      act: (bloc) => bloc.add(ExportToPdf()),
      verify: (_) {
        verify(
          () => mockPdfService.generateAndShare(tReport, tMonth),
        ).called(1);
      },
    );
  });
}
