import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileEditState extends Equatable {
  final String name;
  final String email;

  const ProfileEditState({required this.name, required this.email});

  ProfileEditState copyWith({String? name, String? email}) =>
      ProfileEditState(name: name ?? this.name, email: email ?? this.email);

  @override
  List<Object?> get props => [name, email];
}

class ProfileEditCubit extends Cubit<ProfileEditState> {
  ProfileEditCubit({required String initialName, required String initialEmail})
    : super(ProfileEditState(name: initialName, email: initialEmail));

  void updateName(String name) => emit(state.copyWith(name: name));
  void updateEmail(String email) => emit(state.copyWith(email: email));
}
