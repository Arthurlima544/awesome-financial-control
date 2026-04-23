part of 'bill_bloc.dart';

enum BillStatus { initial, loading, success, failure }

class BillState extends Equatable {
  final BillStatus status;
  final List<BillModel> bills;
  final String? errorMessage;

  const BillState({
    this.status = BillStatus.initial,
    this.bills = const [],
    this.errorMessage,
  });

  BillState copyWith({
    BillStatus? status,
    List<BillModel>? bills,
    String? errorMessage,
  }) {
    return BillState(
      status: status ?? this.status,
      bills: bills ?? this.bills,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bills, errorMessage];
}
