part of 'investment_bloc.dart';

abstract class InvestmentEvent extends Equatable {
  const InvestmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvestments extends InvestmentEvent {}

class CreateInvestment extends InvestmentEvent {
  final Map<String, dynamic> data;
  const CreateInvestment(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateInvestment extends InvestmentEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateInvestment(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteInvestment extends InvestmentEvent {
  final String id;
  const DeleteInvestment(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateInvestmentPrice extends InvestmentEvent {
  final String id;
  final double price;
  const UpdateInvestmentPrice(this.id, this.price);

  @override
  List<Object?> get props => [id, price];
}
