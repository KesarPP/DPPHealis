import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Checks if Firebase is initialized.
  bool get isFirebaseInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth? get _auth {
    if (isFirebaseInitialized) {
      return FirebaseAuth.instance;
    }
    return null;
  }

  /// Returns the currently signed-in user.
  User? get currentUser {
    final auth = _auth;
    if (auth != null) {
      return auth.currentUser;
    }
    return null;
  }

  /// Stream of user authentication state changes.
  Stream<User?> get authStateChanges {
    final auth = _auth;
    if (auth != null) {
      return auth.authStateChanges();
    }
    return Stream.value(null);
  }

  /// Authenticate a user with email and password.
  /// Throws a [FirebaseAuthException] or [Exception] on failure.
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    final auth = _auth;
    if (auth != null) {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } else {
      // Mock mode for testing/local-only runs.
      await Future.delayed(const Duration(milliseconds: 200));
      return null;
    }
  }

  /// Register a user with email, password, and name.
  /// Throws a [FirebaseAuthException] or [Exception] on failure.
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    final auth = _auth;
    if (auth != null) {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.reload();
      }
      return _auth!.currentUser;
    } else {
      // Mock mode for testing/local-only runs.
      await Future.delayed(const Duration(milliseconds: 200));
      return null;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    final auth = _auth;
    if (auth != null) {
      await auth.signOut();
    }
  }
}
