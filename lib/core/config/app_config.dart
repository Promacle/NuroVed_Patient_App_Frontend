/// Central application configuration loaded via `--dart-define` or environment.
///
/// Example usage during execution:
/// ```bash
/// flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co \
///             --dart-define=SUPABASE_ANON_KEY=ey... \
///             --dart-define=APP_ENV=development
/// ```
class AppConfig {
  AppConfig._();

  /// Supabase project URL passed via `--dart-define=SUPABASE_URL=...`
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase anonymous public key passed via `--dart-define=SUPABASE_ANON_KEY=...`
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Application environment: 'development', 'staging', 'production'
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  /// Returns `true` if valid backend credentials have been injected.
  static bool get isBackendConfigured =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  /// Returns `true` if running in production mode.
  static bool get isProduction => appEnv.trim().toLowerCase() == 'production';

  /// Returns `true` if running in development mode.
  static bool get isDevelopment => !isProduction;
}
