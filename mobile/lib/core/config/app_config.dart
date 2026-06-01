/// Runtime configuration — override via `--dart-define` for staging/production.
abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const cdnBaseUrl = String.fromEnvironment(
    'CDN_BASE_URL',
    defaultValue: '',
  );

  static const environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';
  static bool get useRemoteContent => cdnBaseUrl.isNotEmpty;
}
