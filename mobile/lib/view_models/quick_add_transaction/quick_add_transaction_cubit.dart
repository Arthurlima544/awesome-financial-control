import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/models/recurring_transaction_model.dart';
import 'package:afc/repositories/transaction_list_repository.dart';
import 'package:afc/repositories/recurring_repository.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'quick_add_transaction_state.dart';

class QuickAddTransactionCubit extends Cubit<QuickAddTransactionState> {
  final TransactionListRepository _repository;
  final RecurringRepository _recurringRepository;
  final AppRefreshBloc _refreshBloc;

  QuickAddTransactionCubit({
    TransactionListRepository? repository,
    RecurringRepository? recurringRepository,
    AppRefreshBloc? refreshBloc,
  }) : _repository = repository ?? sl<TransactionListRepository>(),
       _recurringRepository = recurringRepository ?? sl<RecurringRepository>(),
       _refreshBloc = refreshBloc ?? sl<AppRefreshBloc>(),
       super(const QuickAddTransactionState());

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value));
  }

  void amountChanged(String value) {
    emit(state.copyWith(amount: value));
  }

  void typeChanged(TransactionType type) {
    emit(state.copyWith(type: type));
  }

  void categoryChanged(String value) {
    emit(state.copyWith(category: value));
  }

  void setRecurring(bool value) {
    emit(state.copyWith(isRecurring: value));
  }

  void frequencyChanged(RecurrenceFrequency frequency) {
    emit(state.copyWith(frequency: frequency));
  }

  void applyTemplate(String description, String category) {
    emit(state.copyWith(description: description, category: category));
  }

  Future<void> submit() async {
    if (!state.isValid) return;

    emit(state.copyWith(status: QuickAddTransactionStatus.loading));
    try {
      await _repository.create(
        description: state.description.trim(),
        amount: state.parsedAmount!,
        type: state.type.name,
        category: state.parsedCategory,
        occurredAt: DateTime.now(),
      );

      if (state.isRecurring) {
        final DateTime nextDueAt = switch (state.frequency) {
          RecurrenceFrequency.daily => DateTime.now().add(
            const Duration(days: 1),
          ),
          RecurrenceFrequency.weekly => DateTime.now().add(
            const Duration(days: 7),
          ),
          RecurrenceFrequency.monthly => DateTime(
            DateTime.now().year,
            DateTime.now().month + 1,
            DateTime.now().day,
          ),
        };

        await _recurringRepository.create(
          RecurringTransactionModel(
            id: '',
            description: state.description.trim(),
            amount: state.parsedAmount!,
            type: state.type,
            category: state.parsedCategory,
            frequency: state.frequency,
            nextDueAt: nextDueAt,
            active: true,
          ),
        );
      }

      _refreshBloc.add(DataChanged());
      emit(state.copyWith(status: QuickAddTransactionStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: QuickAddTransactionStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
