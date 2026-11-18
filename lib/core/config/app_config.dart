/// Build-time configuration: `flutter run --dart-define=API_URL=http://10.0.2.2:8787`
/// (iOS simulator: localhost works; Android emulator: 10.0.2.2; real phone: your computer's LAN IP / your deployed URL).
class AppConfig {
  static const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:8787');
  /// iOS OAuth client ID (Google Cloud Console). Android uses the signing-key based client; the server's web client ID comes from /auth/config.
  static const googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');
  static const enableLogging = bool.fromEnvironment('API_LOGS', defaultValue: true);
}
