import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:buddy/core/constants/app_constants.dart';
import 'package:buddy/firebase_options.dart';

class FirebaseService {
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;

  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      _app = Firebase.app();
      _auth = FirebaseAuth.instanceFor(app: _app!);
      return;
    }

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      _app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      _app = await Firebase.initializeApp();
    }

    _auth = FirebaseAuth.instanceFor(app: _app!);
  }

  static FirebaseAuth get auth {
    if (_auth == null && Firebase.apps.isNotEmpty) {
      _auth = FirebaseAuth.instanceFor(app: Firebase.app());
    }
    if (_auth == null) throw Exception('Firebase not initialized');
    return _auth!;
  }

  static User? get currentUser => _auth?.currentUser;

  static Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? Stream<User?>.value(null);

  static Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .timeout(const Duration(seconds: 20));
    return credential.user;
  }

  static Future<User?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await auth
        .signInWithCredential(credential)
        .timeout(const Duration(seconds: 20));
    return userCredential.user;
  }

  static Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .timeout(const Duration(seconds: 20));
    return credential.user;
  }

  static Future<void> signOut() async => auth.signOut();

  static Future<void> resetPassword(String email) async =>
      auth.sendPasswordResetEmail(email: email);
}

class ApiProxyService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'BUDDY_API_BASE_URL',
        defaultValue: AppConstants.backendProxyBaseUrl,
      ),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? userId,
    Map<String, dynamic>? context,
    List<Map<String, String>>? history,
    String? firstName,
  }) async {
    try {
      final response = await _dio.post(
        '/chat',
        data: {
          'message': message,
          ...?userId == null ? null : {'userId': userId},
          ...?context == null ? null : {'context': context},
          ...?history == null || history.isEmpty ? null : {'history': history},
          ...?firstName == null || firstName.trim().isEmpty
              ? null
              : {'firstName': firstName.trim()},
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final baseUrl = _dio.options.baseUrl;
      final status = e.response?.statusCode;
      if (status != null) {
        throw Exception('AI proxy returned HTTP $status');
      }
      throw Exception(
        'Unable to reach AI proxy at $baseUrl. Set --dart-define=BUDDY_API_BASE_URL=http://<host>:<port>.',
      );
    }
  }

  static Future<Map<String, dynamic>> getAiResponse(
    String conversationId,
  ) async {
    try {
      final response = await _dio.get('/chat/$conversationId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to get AI response');
    }
  }
}
