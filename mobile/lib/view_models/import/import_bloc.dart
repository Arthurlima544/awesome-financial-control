import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/services/import_parser_service.dart';
import 'package:afc/repositories/transaction_list_repository.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:afc/models/import_candidate_model.dart';
import 'import_event.dart';
import 'import_state.dart';

class ImportBloc extends Bloc<ImportEvent, ImportState> {
  final ImportParserService _parserService;
  final TransactionListRepository _repository;
  final AppRefreshBloc _refreshBloc;

  ImportBloc({
    ImportParserService? parserService,
    required TransactionListRepository repository,
    required AppRefreshBloc refreshBloc,
  }) : _parserService = parserService ?? ImportParserService(),
       _repository = repository,
       _refreshBloc = refreshBloc,
       super(const ImportState()) {
    on<ImportProfileSelected>(_onProfileSelected);
    on<ImportFileSelected>(_onFileSelected);
    on<ImportCandidateToggled>(_onCandidateToggled);
    on<ImportCandidateCategoryChanged>(_onCandidateCategoryChanged);
    on<ImportSubmitRequested>(_onSubmitRequested);
  }

  void _onProfileSelected(
    ImportProfileSelected event,
    Emitter<ImportState> emit,
  ) {
    emit(state.copyWith(profile: event.profile));
  }

  Future<void> _onFileSelected(
    ImportFileSelected event,
    Emitter<ImportState> emit,
  ) async {
    emit(state.copyWith(status: ImportStatus.parsing, errorMessage: null));
    try {
      final candidates = _parserService.parse(event.content, state.profile);

      // Basic Duplicate Check against current transactions (within last 90 days usually enough)
      final currentTransactions = await _repository.getAll();

      final markedCandidates = candidates.map((c) {
        final isDuplicate = currentTransactions.any(
          (t) =>
              t.amount == c.amount &&
              t.description == c.description &&
              t.occurredAt.year == c.occurredAt.year &&
              t.occurredAt.month == c.occurredAt.month &&
              t.occurredAt.day == c.occurredAt.day,
        );
        return c.copyWith(isDuplicate: isDuplicate, isSelected: !isDuplicate);
      }).toList();

      if (markedCandidates.isEmpty) {
        emit(
          state.copyWith(
            status: ImportStatus.failure,
            errorMessage: 'No valid transactions found in the file.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ImportStatus.reviewing,
            candidates: markedCandidates,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ImportStatus.failure,
          errorMessage: 'Failed to parse file: $e',
        ),
      );
    }
  }

  void _onCandidateToggled(
    ImportCandidateToggled event,
    Emitter<ImportState> emit,
  ) {
    final newCandidates = List<ImportCandidateModel>.from(state.candidates);
    final current = newCandidates[event.index];
    newCandidates[event.index] = current.copyWith(
      isSelected: !current.isSelected,
    );
    emit(state.copyWith(candidates: newCandidates));
  }

  void _onCandidateCategoryChanged(
    ImportCandidateCategoryChanged event,
    Emitter<ImportState> emit,
  ) {
    final newCandidates = List<ImportCandidateModel>.from(state.candidates);
    final current = newCandidates[event.index];
    newCandidates[event.index] = current.copyWith(category: event.category);
    emit(state.copyWith(candidates: newCandidates));
  }

  Future<void> _onSubmitRequested(
    ImportSubmitRequested event,
    Emitter<ImportState> emit,
  ) async {
    final selected = state.candidates.where((c) => c.isSelected).toList();
    if (selected.isEmpty) return;

    emit(state.copyWith(status: ImportStatus.submitting));

    try {
      final data = selected
          .map(
            (c) => {
              'description': c.description,
              'amount': c.amount,
              'type': c.type.name.toUpperCase(),
              'category': c.category,
              'occurredAt': c.occurredAt.toUtc().toIso8601String(),
            },
          )
          .toList();

      await _repository.createBulk(data);

      _refreshBloc.add(DataChanged());
      emit(state.copyWith(status: ImportStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: ImportStatus.failure,
          errorMessage: 'Failed to save transactions.',
        ),
      );
      // Keep reviewing state so they can try again
      emit(state.copyWith(status: ImportStatus.reviewing));
    }
  }
}
