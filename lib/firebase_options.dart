import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:buddy/core/constants/app_constants.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: AppConstants.firebaseApiKey,
    appId: AppConstants.firebaseAppId,
    messagingSenderId: AppConstants.firebaseMessagingSenderId,
    projectId: AppConstants.firebaseProjectId,
    storageBucket: AppConstants.firebaseStorageBucket,
    databaseURL: AppConstants.firebaseDatabaseUrl,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: AppConstants.firebaseApiKey,
    appId: AppConstants.firebaseAppId,
    messagingSenderId: AppConstants.firebaseMessagingSenderId,
    projectId: AppConstants.firebaseProjectId,
    storageBucket: AppConstants.firebaseStorageBucket,
    databaseURL: AppConstants.firebaseDatabaseUrl,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: AppConstants.firebaseApiKey,
    appId: AppConstants.firebaseAppId,
    messagingSenderId: AppConstants.firebaseMessagingSenderId,
    projectId: AppConstants.firebaseProjectId,
    storageBucket: AppConstants.firebaseStorageBucket,
    databaseURL: AppConstants.firebaseDatabaseUrl,
    iosBundleId: 'com.example.buddy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: AppConstants.firebaseApiKey,
    appId: AppConstants.firebaseAppId,
    messagingSenderId: AppConstants.firebaseMessagingSenderId,
    projectId: AppConstants.firebaseProjectId,
    storageBucket: AppConstants.firebaseStorageBucket,
    databaseURL: AppConstants.firebaseDatabaseUrl,
    iosBundleId: 'com.example.buddy',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: AppConstants.firebaseApiKey,
    appId: AppConstants.firebaseAppId,
    messagingSenderId: AppConstants.firebaseMessagingSenderId,
    projectId: AppConstants.firebaseProjectId,
    storageBucket: AppConstants.firebaseStorageBucket,
    databaseURL: AppConstants.firebaseDatabaseUrl,
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: AppConstants.firebaseApiKey,
    appId: AppConstants.firebaseAppId,
    messagingSenderId: AppConstants.firebaseMessagingSenderId,
    projectId: AppConstants.firebaseProjectId,
    storageBucket: AppConstants.firebaseStorageBucket,
    databaseURL: AppConstants.firebaseDatabaseUrl,
  );
}
