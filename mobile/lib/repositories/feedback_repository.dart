import 'package:dio/dio.dart';
import 'package:afc/utils/config/app_config.dart';

class FeedbackRepository {
  FeedbackRepository({Dio? dio}) : _dio = dio ?? _buildDio();

  static Dio _buildDio() {
    return Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
  }

  final Dio _dio;

  Future<void> submit({
    required String userId,
    required int rating,
    String? message,
    required String appVersion,
    required String platform,
  }) async {
    await _dio.post<void>(
      '/api/v1/feedbacks',
      data: {
        'userId': userId,
        'rating': rating,
        'message': message,
        'appVersion': appVersion,
        'platform': platform,
      },
    );
  }
}
