enum AppFlavor { local, staging, prod }

class AppConfig {
  static const String _flavor =
      String.fromEnvironment('FLAVOR', defaultValue: 'local');

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static AppFlavor get flavor => switch (_flavor) {
        'staging' => AppFlavor.staging,
        'prod' => AppFlavor.prod,
        _ => AppFlavor.local,
      };

  static bool get isLocal => flavor == AppFlavor.local;
  static bool get isStaging => flavor == AppFlavor.staging;
  static bool get isProd => flavor == AppFlavor.prod;
}
