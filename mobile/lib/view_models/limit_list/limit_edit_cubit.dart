import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:afc/models/limit_model.dart';

enum LimitEditStatus { initial, loading, success, error }

class LimitEditState extends Equatable {
  const LimitEditState({
    this.amount = '',
    this.status = LimitEditStatus.initial,
    this.errorMessage,
  });

  final String amount;
  final LimitEditStatus status;
  final String? errorMessage;

  LimitEditState copyWith({
    String? amount,
    LimitEditStatus? status,
    String? errorMessage,
  }) {
    return LimitEditState(
      amount: amount ?? this.amount,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [amount, status, errorMessage];

  double? get parsedAmount {
    final parsed = double.tryParse(amount.trim().replaceAll(',', '.'));
    if (parsed != null && parsed > 0) return parsed;
    return null;
  }

  bool get isAmountValid => parsedAmount != null;

  bool get isValid => isAmountValid;
}

class LimitEditCubit extends Cubit<LimitEditState> {
  LimitEditCubit({LimitModel? initialLimit})
    : super(
        LimitEditState(amount: initialLimit?.amount.toStringAsFixed(2) ?? ''),
      );

  void amountChanged(String value) => emit(state.copyWith(amount: value));

  void saved() => emit(state.copyWith(status: LimitEditStatus.success));
}
