import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase_service.dart';

abstract class AuthRepository {
  Future<User?> signIn({required String email, required String password});
  Future<User?> signUp({required String email, required String password});
  Future<void> signOut();
  Future<void> resetPassword({required String email});
  Stream<User?> authStateChanges();
}

class FirebaseAuthRepository implements AuthRepository {
  @override
  Future<User?> signIn({required String email, required String password}) {
    return FirebaseService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<User?> signUp({required String email, required String password}) {
    return FirebaseService.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() {
    return FirebaseService.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) {
    return FirebaseService.resetPassword(email);
  }

  @override
  Stream<User?> authStateChanges() {
    return FirebaseService.authStateChanges;
  }
}
