import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingState extends Equatable {
  final int currentPage;
  final bool isCompleted;
  final bool isLoading;

  const OnboardingState({
    this.currentPage = 0,
    this.isCompleted = false,
    this.isLoading = true,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? isCompleted,
    bool? isLoading,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [currentPage, isCompleted, isLoading];
}

class OnboardingCubit extends Cubit<OnboardingState> {
  static const String _onboardingKey = 'onboarding_done';

  OnboardingCubit() : super(const OnboardingState());

  Future<void> loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isDone = prefs.getBool(_onboardingKey) ?? false;
    emit(state.copyWith(isCompleted: isDone, isLoading: false));
  }

  void setPage(int page) {
    emit(state.copyWith(currentPage: page));
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    emit(state.copyWith(isCompleted: true));
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, false);
    emit(state.copyWith(isCompleted: false, currentPage: 0));
  }

  static Future<bool> shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_onboardingKey) ?? false);
  }
}
