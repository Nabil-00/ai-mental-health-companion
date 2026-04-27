class AppConstants {
  static const String appName = 'Buddy';
  static const String appVersion = '1.0.0';

  static const String firebaseApiKey = 'YOUR_API_KEY';
  static const String firebaseProjectId = 'buddy-app';
  static const String firebaseStorageBucket = 'buddy-app.appspot.com';
  static const String firebaseMessagingSenderId = '000000000000';
  static const String firebaseAppId = '1:000000000000:android:0000000000000';
  static const String firebaseDatabaseUrl = 'https://buddy-app.firebaseio.com';

  static const String backendProxyBaseUrl = 'http://localhost:8080';
  static const String aiProxyEndpoint = '/api/ai/chat';

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);

  static const int chatMessageMaxLength = 1000;
}
