import 'package:equatable/equatable.dart';
import 'package:afc/models/import_candidate_model.dart';
import 'package:afc/services/import_parser_service.dart';

enum ImportStatus {
  initial,
  selectingFile,
  parsing,
  reviewing,
  submitting,
  success,
  failure,
}

class ImportState extends Equatable {
  final ImportStatus status;
  final ImportProfile profile;
  final List<ImportCandidateModel> candidates;
  final String? errorMessage;

  const ImportState({
    this.status = ImportStatus.initial,
    this.profile = ImportProfile.ofxDefault,
    this.candidates = const [],
    this.errorMessage,
  });

  ImportState copyWith({
    ImportStatus? status,
    ImportProfile? profile,
    List<ImportCandidateModel>? candidates,
    Object? errorMessage = const Object(),
  }) {
    return ImportState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      candidates: candidates ?? this.candidates,
      errorMessage: errorMessage == const Object()
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  int get selectedCount => candidates.where((c) => c.isSelected).length;

  @override
  List<Object?> get props => [status, profile, candidates, errorMessage];
}
