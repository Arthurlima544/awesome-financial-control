import 'package:equatable/equatable.dart';
import 'import_state.dart';

abstract class ImportEvent extends Equatable {
  const ImportEvent();

  @override
  List<Object?> get props => [];
}

class ImportBankSelected extends ImportEvent {
  final ImportBank bank;
  const ImportBankSelected(this.bank);

  @override
  List<Object?> get props => [bank];
}

class ImportTypeSelected extends ImportEvent {
  final ImportType type;
  const ImportTypeSelected(this.type);

  @override
  List<Object?> get props => [type];
}

class ImportFileSelected extends ImportEvent {
  final String content;
  const ImportFileSelected(this.content);

  @override
  List<Object?> get props => [content];
}

class ImportCandidateToggled extends ImportEvent {
  final int index;
  const ImportCandidateToggled(this.index);

  @override
  List<Object?> get props => [index];
}

class ImportCandidateCategoryChanged extends ImportEvent {
  final int index;
  final String category;
  const ImportCandidateCategoryChanged(this.index, this.category);

  @override
  List<Object?> get props => [index, category];
}

class ImportSubmitRequested extends ImportEvent {
  const ImportSubmitRequested();
}
