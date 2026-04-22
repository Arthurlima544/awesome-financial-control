import 'package:equatable/equatable.dart';
import 'package:afc/services/import_parser_service.dart';

abstract class ImportEvent extends Equatable {
  const ImportEvent();

  @override
  List<Object?> get props => [];
}

class ImportProfileSelected extends ImportEvent {
  final ImportProfile profile;
  const ImportProfileSelected(this.profile);

  @override
  List<Object?> get props => [profile];
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
