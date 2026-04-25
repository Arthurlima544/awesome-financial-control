import 'package:flutter_bloc/flutter_bloc.dart';

class PrivacyState {
  final bool isPrivate;

  const PrivacyState({this.isPrivate = false});

  PrivacyState copyWith({bool? isPrivate}) {
    return PrivacyState(isPrivate: isPrivate ?? this.isPrivate);
  }
}

class PrivacyCubit extends Cubit<PrivacyState> {
  PrivacyCubit() : super(const PrivacyState());

  void togglePrivacy() {
    emit(state.copyWith(isPrivate: !state.isPrivate));
  }
}
