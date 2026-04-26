import 'package:afc/models/recurring_transaction_model.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/repositories/recurring_repository.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurringFormState {
  final String description;
  final String amount;
  final TransactionType type;
  final String? category;
  final RecurrenceFrequency frequency;
  final DateTime nextDueAt;
  final bool active;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  RecurringFormState({
    this.description = '',
    this.amount = '',
    this.type = TransactionType.expense,
    this.category,
    this.frequency = RecurrenceFrequency.monthly,
    required this.nextDueAt,
    this.active = true,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  bool get isValid => description.isNotEmpty && amount.isNotEmpty;

  RecurringFormState copyWith({
    String? description,
    String? amount,
    TransactionType? type,
    Object? category = const Object(),
    RecurrenceFrequency? frequency,
    DateTime? nextDueAt,
    bool? active,
    bool? isSubmitting,
    bool? isSuccess,
    Object? errorMessage = const Object(),
  }) {
    return RecurringFormState(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: identical(category, const Object())
          ? this.category
          : category as String?,
      frequency: frequency ?? this.frequency,
      nextDueAt: nextDueAt ?? this.nextDueAt,
      active: active ?? this.active,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: identical(errorMessage, const Object())
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class RecurringFormCubit extends Cubit<RecurringFormState> {
  final RecurringRepository _repository;
  final AppRefreshBloc _refreshBloc;
  final RecurringTransactionModel? _initial;

  RecurringFormCubit({
    RecurringTransactionModel? initial,
    RecurringRepository? repository,
    AppRefreshBloc? refreshBloc,
  }) : _initial = initial,
       _repository = repository ?? sl<RecurringRepository>(),
       _refreshBloc = refreshBloc ?? sl<AppRefreshBloc>(),
       super(
         initial != null
             ? RecurringFormState(
                 description: initial.description,
                 amount: initial.amount.toString(),
                 type: initial.type,
                 category: initial.category,
                 frequency: initial.frequency,
                 nextDueAt: initial.nextDueAt,
                 active: initial.active,
               )
             : RecurringFormState(
                 nextDueAt: DateTime.now().add(const Duration(days: 1)),
               ),
       );

  void onDescriptionChanged(String value) =>
      emit(state.copyWith(description: value));
  void onAmountChanged(String value) => emit(state.copyWith(amount: value));
  void onTypeChanged(TransactionType value) =>
      emit(state.copyWith(type: value));
  void onCategoryChanged(String? value) =>
      emit(state.copyWith(category: value));
  void onFrequencyChanged(RecurrenceFrequency value) =>
      emit(state.copyWith(frequency: value));
  void onNextDueAtChanged(DateTime value) =>
      emit(state.copyWith(nextDueAt: value));
  void onActiveChanged(bool value) => emit(state.copyWith(active: value));

  Future<void> submit() async {
    if (!state.isValid) return;

    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    try {
      final rule = RecurringTransactionModel(
        id: _initial?.id ?? '',
        description: state.description,
        amount: double.parse(state.amount.replaceAll(',', '.')),
        type: state.type,
        category: state.category,
        frequency: state.frequency,
        nextDueAt: state.nextDueAt,
        active: state.active,
      );

      if (_initial == null) {
        await _repository.create(rule);
      } else {
        await _repository.update(rule);
      }
      _refreshBloc.add(DataChanged());
      emit(state.copyWith(isSuccess: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Erro ao salvar transação recorrente'));
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }
}
