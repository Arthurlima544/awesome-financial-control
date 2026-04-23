import 'package:afc/models/bill_model.dart';
import 'package:afc/repositories/bill_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'bill_event.dart';
part 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final BillRepository _repository;

  BillBloc({required BillRepository repository})
    : _repository = repository,
      super(const BillState()) {
    on<LoadBills>(_onLoadBills);
    on<CreateBill>(_onCreateBill);
    on<UpdateBill>(_onUpdateBill);
    on<DeleteBill>(_onDeleteBill);
  }

  Future<void> _onLoadBills(LoadBills event, Emitter<BillState> emit) async {
    emit(state.copyWith(status: BillStatus.loading));
    try {
      final bills = await _repository.getAllBills();
      emit(state.copyWith(status: BillStatus.success, bills: bills));
    } catch (e) {
      emit(
        state.copyWith(status: BillStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCreateBill(CreateBill event, Emitter<BillState> emit) async {
    try {
      await _repository.createBill(event.data);
      add(const LoadBills());
    } catch (e) {
      emit(
        state.copyWith(status: BillStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateBill(UpdateBill event, Emitter<BillState> emit) async {
    try {
      await _repository.updateBill(event.id, event.data);
      add(const LoadBills());
    } catch (e) {
      emit(
        state.copyWith(status: BillStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeleteBill(DeleteBill event, Emitter<BillState> emit) async {
    try {
      await _repository.deleteBill(event.id);
      add(const LoadBills());
    } catch (e) {
      emit(
        state.copyWith(status: BillStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
