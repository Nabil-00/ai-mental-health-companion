class AppConstants {
  static const String appName = 'Buddy';
  static const String appVersion = '1.0.0';

  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY';
  static const String firebaseProjectId = 'your-firebase-project-id';
  static const String firebaseStorageBucket =
      'your-firebase-project-id.firebasestorage.app';
  static const String firebaseMessagingSenderId = '000000000000';
  static const String firebaseAppId =
      '1:000000000000:android:yourfirebaseappid';
  static const String firebaseDatabaseUrl =
      'https://your-firebase-project-id.firebaseio.com';

  static const String backendProxyBaseUrl = String.fromEnvironment(
    'BUDDY_API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);

  static const int maxMoodLevel = 5;
  static const int chatMessageMaxLength = 1000;
}
