import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  FirebaseFirestore? get _firestore {
    if (isFirebaseInitialized) {
      return FirebaseFirestore.instance;
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

  /// Retrieves the role of the currently signed-in user from Firestore.
  /// Returns 'user', 'coach', or null if not found.
  Future<String?> getUserRole() async {
    final user = currentUser;
    if (user == null || _firestore == null) return null;

    try {
      // Check if user is a coach
      final coachDoc = await _firestore!.collection('coaches').doc(user.uid).get();
      if (coachDoc.exists) return 'coach';

      // Check if user is a patient
      final userDoc = await _firestore!.collection('users').doc(user.uid).get();
      if (userDoc.exists) return 'user';
    } catch (_) {}

    return null;
  }

  // ─── Patient (User) methods ───────────────────────────────────────────────

  /// Authenticate a patient with email and password.
  /// Verifies the account belongs to the 'users' collection in Firestore.
  /// Throws a [FirebaseAuthException] or [Exception] on failure.
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    final auth = _auth;
    if (auth != null) {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        // Verify this account is registered as a patient, not a coach.
        final doc = await _firestore!.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await auth.signOut();
          throw Exception(
            'This account is not registered as a patient. Please use the Doctor/Coach login.',
          );
        }
      }
      return user;
    } else {
      // Mock mode for testing/local-only runs.
      await Future.delayed(const Duration(milliseconds: 200));
      return null;
    }
  }

  /// Register a patient with email, password, and name.
  /// Creates a Firestore document under 'users/{uid}' to tag this as a patient account.
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
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        // Tag this account as a 'user/patient' in Firestore.
        await _firestore!.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return _auth!.currentUser;
    } else {
      // Mock mode for testing/local-only runs.
      await Future.delayed(const Duration(milliseconds: 200));
      return null;
    }
  }

  // ─── Coach-specific methods ──────────────────────────────────────────────

  /// Validates that [email] belongs to the healis.org domain.
  /// Throws an [Exception] if the check fails.
  void _assertCoachEmail(String email) {
    if (!email.toLowerCase().contains('healis.org')) {
      throw Exception('Coach accounts must use a @healis.org email address.');
    }
  }

  /// Sign in a coach with email and password.
  /// Validates healis.org domain AND verifies the account is in the 'coaches' Firestore collection.
  /// Throws if the email is not a healis.org address, or on Firebase failure.
  Future<User?> signInCoachWithEmailAndPassword(
      String email, String password) async {
    _assertCoachEmail(email);
    final auth = _auth;
    if (auth != null) {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        // Verify this account is registered as a coach, not a patient.
        final doc = await _firestore!.collection('coaches').doc(user.uid).get();
        if (!doc.exists) {
          await auth.signOut();
          throw Exception(
            'No coach account found. Please sign up first or use Patient login.',
          );
        }
      }
      return user;
    } else {
      // Mock mode for testing/local-only runs.
      await Future.delayed(const Duration(milliseconds: 200));
      return null;
    }
  }

  /// Register a coach with email, password, and name.
  /// Validates healis.org domain AND creates a Firestore document under 'coaches/{uid}'.
  /// Throws if the email is not a healis.org address, or on Firebase failure.
  Future<User?> signUpCoachWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    _assertCoachEmail(email);
    final auth = _auth;
    if (auth != null) {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        // Tag this account as a 'coach' in Firestore.
        await _firestore!.collection('coaches').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': 'coach',
          'createdAt': FieldValue.serverTimestamp(),
        });
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
