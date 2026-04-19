import 'dart:io';

import 'package:flutter/foundation.dart';

enum AppFlavor { local, staging, prod }

class AppConfig {
  static const String _flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'local',
  );

  static const String _apiBaseUrlEnv = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_apiBaseUrlEnv.isNotEmpty) return _apiBaseUrlEnv;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  static AppFlavor get flavor => switch (_flavor) {
    'staging' => AppFlavor.staging,
    'prod' => AppFlavor.prod,
    _ => AppFlavor.local,
  };

  static bool get isLocal => flavor == AppFlavor.local;
  static bool get isStaging => flavor == AppFlavor.staging;
  static bool get isProd => flavor == AppFlavor.prod;
}
