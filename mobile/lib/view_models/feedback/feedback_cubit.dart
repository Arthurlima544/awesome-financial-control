import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:afc/repositories/feedback_repository.dart';
import 'dart:io';

enum FeedbackStatus { initial, submitting, success, failure }

class FeedbackState extends Equatable {
  final int rating;
  final String message;
  final FeedbackStatus status;
  final String? errorMessage;

  const FeedbackState({
    this.rating = 0,
    this.message = '',
    this.status = FeedbackStatus.initial,
    this.errorMessage,
  });

  FeedbackState copyWith({
    int? rating,
    String? message,
    FeedbackStatus? status,
    String? errorMessage,
  }) {
    return FeedbackState(
      rating: rating ?? this.rating,
      message: message ?? this.message,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [rating, message, status, errorMessage];
}

class FeedbackCubit extends Cubit<FeedbackState> {
  final FeedbackRepository _repository;

  FeedbackCubit({required FeedbackRepository repository})
    : _repository = repository,
      super(const FeedbackState());

  void updateRating(int rating) {
    emit(state.copyWith(rating: rating));
  }

  void updateMessage(String message) {
    emit(state.copyWith(message: message));
  }

  Future<void> submit() async {
    if (state.rating == 0) return;

    emit(state.copyWith(status: FeedbackStatus.submitting, errorMessage: null));

    try {
      // Mock userId for now since we don't have auth yet
      const userId = '00000000-0000-0000-0000-000000000000';
      const appVersion =
          '1.0.0'; // Should come from package_info_plus in a real app
      final platform = Platform.isAndroid ? 'Android' : 'iOS';

      await _repository.submit(
        userId: userId,
        rating: state.rating,
        message: state.message.isEmpty ? null : state.message,
        appVersion: appVersion,
        platform: platform,
      );

      emit(state.copyWith(status: FeedbackStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: FeedbackStatus.failure,
          errorMessage: 'Falha ao enviar feedback. Tente novamente.',
        ),
      );
    }
  }

  void reset() {
    emit(const FeedbackState());
  }
}
