import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrivacyState extends Equatable {
  final bool isPrivate;

  const PrivacyState({this.isPrivate = false});

  PrivacyState copyWith({bool? isPrivate}) {
    return PrivacyState(isPrivate: isPrivate ?? this.isPrivate);
  }

  @override
  List<Object?> get props => [isPrivate];
}

class PrivacyCubit extends Cubit<PrivacyState> {
  PrivacyCubit() : super(const PrivacyState());

  void togglePrivacy() {
    emit(state.copyWith(isPrivate: !state.isPrivate));
  }
}
