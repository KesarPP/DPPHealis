import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Saves the profile image locally for the current user.
  Future<String?> saveLocalProfileImage(File imageFile) async {
    final email = currentUser?.email;
    if (email == null) return null;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final String extension = imageFile.path.split('.').last;
      final String newPath = '${appDir.path}/profile_${email.hashCode}.$extension';
      
      // Copy the file to our app directory
      final File savedFile = await imageFile.copy(newPath);

      // Save the path in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_pfp_$email', savedFile.path);

      // Also update the photoURL in Firebase Auth to point to this local path
      if (currentUser != null) {
        await currentUser!.updatePhotoURL(savedFile.path);
        await currentUser!.reload();
      }

      return savedFile.path;
    } catch (_) {
      return null;
    }
  }

  /// Retrieves the local profile image path for the current user.
  Future<String?> getLocalProfileImagePath() async {
    final email = currentUser?.email;
    if (email == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final localPath = prefs.getString('local_pfp_$email');
    if (localPath != null && File(localPath).existsSync()) {
      return localPath;
    }
    
    // Fallback to photoURL if it points to a local file
    final photoUrl = currentUser?.photoURL;
    if (photoUrl != null && (photoUrl.startsWith('/') || photoUrl.contains('profile_'))) {
      if (File(photoUrl).existsSync()) {
        return photoUrl;
      }
    }
    return null;
  }

  /// Returns the Gravatar URL for a given email address.
  String getGravatarUrl(String email) {
    final cleanedEmail = email.trim().toLowerCase();
    final bytes = utf8.encode(cleanedEmail);
    final hash = md5.convert(bytes).toString();
    return 'https://www.gravatar.com/avatar/$hash?s=200&d=identicon';
  }

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
      if (credential.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_user_name', credential.user!.displayName ?? '');
        await prefs.setString('last_user_email', credential.user!.email ?? '');
      }
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_user_name', name);
        await prefs.setString('last_user_email', email);
      }
      return _auth!.currentUser;
    } else {
      // Mock mode for testing/local-only runs.
      await Future.delayed(const Duration(milliseconds: 200));
      return null;
    }
  }

  /// Persists the user's profile details locally.
  Future<void> persistUserProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_user_name', name);
    await prefs.setString('last_user_email', email);
  }

  /// Retrieves the user profile details (falling back to SharedPreferences if Firebase user is null).
  Future<UserProfileData> getUserProfileData() async {
    final user = currentUser;
    final prefs = await SharedPreferences.getInstance();
    
    final String name = user?.displayName ?? prefs.getString('last_user_name') ?? 'Janice Pattice';
    final String email = user?.email ?? prefs.getString('last_user_email') ?? '';
    
    String? localPath = prefs.getString('local_pfp_$email');
    if (localPath == null || !File(localPath).existsSync()) {
      final photoUrl = user?.photoURL;
      if (photoUrl != null && (photoUrl.startsWith('/') || photoUrl.contains('profile_'))) {
        if (File(photoUrl).existsSync()) {
          localPath = photoUrl;
        }
      }
    }

    return UserProfileData(
      displayName: name.isNotEmpty ? name : 'Janice Pattice',
      email: email,
      localImagePath: localPath,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    final auth = _auth;
    if (auth != null) {
      await auth.signOut();
    }
  }
}

class UserProfileData {
  final String displayName;
  final String email;
  final String? localImagePath;

  UserProfileData({
    required this.displayName,
    required this.email,
    this.localImagePath,
  });
}
