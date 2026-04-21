import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/injection.dart';
import '../model/transaction_model.dart';
import '../repository/transaction_list_repository.dart';
import 'quick_add_transaction_state.dart';

class QuickAddTransactionCubit extends Cubit<QuickAddTransactionState> {
  QuickAddTransactionCubit({TransactionListRepository? repository})
    : _repository = repository ?? sl<TransactionListRepository>(),
      super(const QuickAddTransactionState());

  final TransactionListRepository _repository;

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
