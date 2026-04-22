import 'package:equatable/equatable.dart';
import 'package:afc/models/import_candidate_model.dart';

enum ImportStatus {
  initial,
  selectingFile,
  parsing,
  reviewing,
  submitting,
  success,
  failure,
}

enum ImportBank { generic, nubank }

enum ImportType { ofx, extrato, fatura }

class ImportState extends Equatable {
  final ImportStatus status;
  final ImportBank bank;
  final ImportType type;
  final List<ImportCandidateModel> candidates;
  final String? errorMessage;

  const ImportState({
    this.status = ImportStatus.initial,
    this.bank = ImportBank.generic,
    this.type = ImportType.ofx,
    this.candidates = const [],
    this.errorMessage,
  });

  ImportState copyWith({
    ImportStatus? status,
    ImportBank? bank,
    ImportType? type,
    List<ImportCandidateModel>? candidates,
    Object? errorMessage = const Object(),
  }) {
    return ImportState(
      status: status ?? this.status,
      bank: bank ?? this.bank,
      type: type ?? this.type,
      candidates: candidates ?? this.candidates,
      errorMessage: errorMessage == const Object()
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  int get selectedCount => candidates.where((c) => c.isSelected).length;

  @override
  List<Object?> get props => [status, bank, type, candidates, errorMessage];
}
