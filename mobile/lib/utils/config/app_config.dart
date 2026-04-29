import 'dart:io';

import 'package:flutter/foundation.dart';

enum AppFlavor { local, staging, prod }

class AppConfig {
  static const String _flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'local',
  );

  static const String _apiBaseUrlEnv = String.fromEnvironment('API_BASE_URL');
  static const String _geminiApiKeyEnv = String.fromEnvironment(
    'GEMINI_API_KEY',
  );
  static const String _geminiModelEnv = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );

  static String get apiBaseUrl {
    if (_apiBaseUrlEnv.isNotEmpty) return _apiBaseUrlEnv;

    // Only allow fallback in local dev
    assert(
      isLocal,
      'API_BASE_URL must be set for staging/prod builds via --dart-define',
    );

    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  static String get geminiApiKey => _geminiApiKeyEnv;
  static String get geminiModel => _geminiModelEnv;

  static AppFlavor get flavor => switch (_flavor) {
        'staging' => AppFlavor.staging,
        'prod' => AppFlavor.prod,
        _ => AppFlavor.local,
      };

  static bool get isLocal => flavor == AppFlavor.local;
  static bool get isStaging => flavor == AppFlavor.staging;
  static bool get isProd => flavor == AppFlavor.prod;
}