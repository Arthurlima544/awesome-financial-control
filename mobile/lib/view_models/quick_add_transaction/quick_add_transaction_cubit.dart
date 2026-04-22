import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:afc/utils/config/injection.dart';
import 'package:afc/models/transaction_model.dart';
import 'package:afc/models/recurring_transaction_model.dart';
import 'package:afc/repositories/transaction_list_repository.dart';
import 'package:afc/repositories/recurring_repository.dart';
import 'package:afc/repositories/template_repository.dart';
import 'package:afc/models/template_model.dart';
import 'package:afc/view_models/refresh/app_refresh_bloc.dart';
import 'quick_add_transaction_state.dart';

class QuickAddTransactionCubit extends Cubit<QuickAddTransactionState> {
  final TransactionListRepository _repository;
  final RecurringRepository _recurringRepository;
  final TemplateRepository _templateRepository;
  final AppRefreshBloc _refreshBloc;

  QuickAddTransactionCubit({
    TransactionListRepository? repository,
    RecurringRepository? recurringRepository,
    TemplateRepository? templateRepository,
    AppRefreshBloc? refreshBloc,
  }) : _repository = repository ?? sl<TransactionListRepository>(),
       _recurringRepository = recurringRepository ?? sl<RecurringRepository>(),
       _templateRepository = templateRepository ?? sl<TemplateRepository>(),
       _refreshBloc = refreshBloc ?? sl<AppRefreshBloc>(),
       super(const QuickAddTransactionState()) {
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    try {
      final templates = await _templateRepository.getAll();
      emit(state.copyWith(templates: templates));
    } catch (e) {
      // Fail silently for templates or log error
    }
  }

  void descriptionChanged(String value) {
    emit(state.copyWith(description: value, selectedTemplate: null));
  }

  void amountChanged(String value) {
    emit(state.copyWith(amount: value));
  }

  void typeChanged(TransactionType type) {
    emit(state.copyWith(type: type));
  }

  void categoryChanged(String value) {
    emit(state.copyWith(category: value, selectedTemplate: null));
  }

  void setRecurring(bool value) {
    emit(state.copyWith(isRecurring: value));
  }

  void frequencyChanged(RecurrenceFrequency frequency) {
    emit(state.copyWith(frequency: frequency));
  }

  void setSaveAsTemplate(bool value) {
    emit(state.copyWith(saveAsTemplate: value));
  }

  void applyTemplate(TemplateModel template) {
    emit(
      state.copyWith(
        description: template.description,
        category: template.category ?? '',
        type: template.type,
        selectedTemplate: template.description,
      ),
    );
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

      if (state.saveAsTemplate) {
        await _templateRepository.create(
          TemplateModel(
            id: '',
            description: state.description.trim(),
            category: state.parsedCategory,
            type: state.type,
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
