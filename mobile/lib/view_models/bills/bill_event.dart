part of 'bill_bloc.dart';

abstract class BillEvent extends Equatable {
  const BillEvent();

  @override
  List<Object?> get props => [];
}

class LoadBills extends BillEvent {
  const LoadBills();
}

class CreateBill extends BillEvent {
  final Map<String, dynamic> data;
  const CreateBill(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateBill extends BillEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateBill(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteBill extends BillEvent {
  final String id;
  const DeleteBill(this.id);

  @override
  List<Object?> get props => [id];
}
