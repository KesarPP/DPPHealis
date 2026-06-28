import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/coach_profile.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Saves the profile image locally for the current user.
  Future<String?> saveLocalProfileImage(File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = currentUser?.email ?? prefs.getString('last_user_email');
      if (email == null || email.isEmpty) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final String extension = imageFile.path.split('.').last;
      final String newPath = '${appDir.path}/profile_${email.hashCode}.$extension';
      
      // Copy the file to our app directory
      final File savedFile = await imageFile.copy(newPath);

      // Save the path in SharedPreferences
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = currentUser?.email ?? prefs.getString('last_user_email');
      if (email == null || email.isEmpty) return null;

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
    } catch (_) {}
    return null;
  }

  /// Removes the local profile image.
  Future<void> removeLocalProfileImage() async {
    final email = currentUser?.email ?? (await SharedPreferences.getInstance()).getString('last_user_email');
    if (email == null || email.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('local_pfp_$email');

      if (currentUser != null) {
        await currentUser!.updatePhotoURL(null);
        await currentUser!.reload();
      }
    } catch (_) {}
  }

  /// Returns the Gravatar URL for a given email address.
  String getGravatarUrl(String email) {
    final cleanedEmail = email.trim().toLowerCase();
    final bytes = utf8.encode(cleanedEmail);
    final hash = md5.convert(bytes).toString();
    return 'https://www.gravatar.com/avatar/$hash?s=200&d=identicon';
  }


  /// Persists the user's profile details locally AND to Firestore.
  Future<void> persistUserProfile(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_user_name', name);
    await prefs.setString('last_user_email', email);
    // Also write to Firestore so the name reflects everywhere (admin panel, etc.)
    try {
      final uid = currentUser?.uid;
      if (uid != null && isFirebaseInitialized) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set({'name': name}, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  /// Retrieves the user profile details.
  /// Priority: Firestore > Firebase Auth displayName > SharedPreferences.
  Future<UserProfileData> getUserProfileData() async {
    final user = currentUser;
    final prefs = await SharedPreferences.getInstance();

    String name = user?.displayName ?? prefs.getString('last_user_name') ?? 'Janice Pattice';
    final String email = user?.email ?? prefs.getString('last_user_email') ?? '';

    // Read latest name from Firestore (most authoritative source)
    try {
      if (user != null && isFirebaseInitialized) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final firestoreName = doc.data()?['name'] as String?;
        if (firestoreName != null && firestoreName.isNotEmpty) {
          name = firestoreName;
          // Keep local cache in sync
          await prefs.setString('last_user_name', name);
        }
      }
    } catch (_) {}

    String? localPath = prefs.getString('local_pfp_$email');
    if (localPath == null || !File(localPath).existsSync()) {
      final photoUrl = user?.photoURL;
      if (photoUrl != null && (photoUrl.startsWith('/') || photoUrl.contains('profile_'))) {
        if (File(photoUrl).existsSync()) {
          localPath = photoUrl;
        }
      }
    }

    final String bgColor = prefs.getString('profile_bg_color_$email') ?? 'pink';

    return UserProfileData(
      displayName: name.isNotEmpty ? name : 'Janice Pattice',
      email: email,
      localImagePath: localPath,
      profileBgColor: bgColor,
    );
  }

  /// Persists the selected profile background color name.
  Future<void> persistProfileBgColor(String colorName) async {
    final prefs = await SharedPreferences.getInstance();
    final email = currentUser?.email ?? prefs.getString('last_user_email') ?? '';
    await prefs.setString('profile_bg_color_$email', colorName);
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
  Future<User?> signInWithEmailAndPassword(String emailOrPhone, String password) async {
    final auth = _auth;
    final prefs = await SharedPreferences.getInstance();
    String resolvedEmail = emailOrPhone;

    final isPhone = RegExp(r'^\d{10}$').hasMatch(emailOrPhone);
    if (isPhone) {
      if (_firestore != null) {
        final docQuery = await _firestore!
            .collection('users')
            .where('phoneNumber', isEqualTo: emailOrPhone)
            .limit(1)
            .get();
        if (docQuery.docs.isNotEmpty) {
          resolvedEmail = docQuery.docs.first.data()['email'] as String;
        } else {
          throw Exception('No patient account found with this phone number.');
        }
      } else {
        // Mock mode lookup
        resolvedEmail = prefs.getString('phone_email_map_$emailOrPhone') ?? '$emailOrPhone@mock.com';
      }
    }

    if (auth != null) {
      final credential = await auth.signInWithEmailAndPassword(
        email: resolvedEmail,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await prefs.setString('last_user_name', user.displayName ?? '');
        await prefs.setString('last_user_email', user.email ?? '');

        // Verify this account is registered as a patient, not a coach.
        final doc = await _firestore!.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await auth.signOut();
          throw Exception(
            'This account is not registered as a patient. Please use the Doctor/Coach login.',
          );
        }
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_role', 'user');
      }
      return user;
    } else {
      // Mock mode for testing/local-only runs.
      await Future.delayed(const Duration(milliseconds: 200));
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_role', 'user');
      await prefs.setString('last_user_email', resolvedEmail);
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
    required String phoneNumber,
  }) async {
    final auth = _auth;
    final prefs = await SharedPreferences.getInstance();
    if (phoneNumber.isNotEmpty) {
      await prefs.setString('phone_email_map_$phoneNumber', email);
    }
    if (auth != null) {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        
        await prefs.setString('last_user_name', name);
        await prefs.setString('last_user_email', email);

        // Tag this account as a 'user/patient' in Firestore.
        await _firestore!.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_role', 'user');
      }
      return _auth!.currentUser;
    } else {
      // Mock mode for testing/local-only runs.
      await Future.delayed(const Duration(milliseconds: 200));
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_role', 'user');
      await prefs.setString('last_user_email', email);
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
      String emailOrPhone, String password) async {
    final auth = _auth;
    final prefs = await SharedPreferences.getInstance();
    String resolvedEmail = emailOrPhone;

    final isPhone = RegExp(r'^\d{10}$').hasMatch(emailOrPhone);
    if (isPhone) {
      if (_firestore != null) {
        final docQuery = await _firestore!
            .collection('coaches')
            .where('phoneNumber', isEqualTo: emailOrPhone)
            .limit(1)
            .get();
        if (docQuery.docs.isNotEmpty) {
          resolvedEmail = docQuery.docs.first.data()['email'] as String;
        } else {
          throw Exception('No coach account found with this phone number.');
        }
      } else {
        // Mock mode lookup
        resolvedEmail = prefs.getString('phone_email_map_$emailOrPhone') ?? '$emailOrPhone@healis.org';
      }
    }

    _assertCoachEmail(resolvedEmail);
    if (auth != null) {
      final credential = await auth.signInWithEmailAndPassword(
        email: resolvedEmail,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await prefs.setString('last_user_name', user.displayName ?? '');
        await prefs.setString('last_user_email', user.email ?? '');

        // Verify this account is registered as a coach, not a patient.
        final doc = await _firestore!.collection('coaches').doc(user.uid).get();
        if (!doc.exists) {
          throw Exception('PROFILE_INCOMPLETE');
        }
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_role', 'coach');
      }
      return user;
    } else {
      // Mock mode for testing/local-only runs.
      await Future.delayed(const Duration(milliseconds: 200));
      final isComplete = prefs.getBool('coach_profile_complete_mock_uid') ?? false;
      if (!isComplete) {
        throw Exception('PROFILE_INCOMPLETE');
      }
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_role', 'coach');
      await prefs.setString('last_user_name', 'Dr. Sarah Mitchell');
      await prefs.setString('last_user_email', resolvedEmail);
      return null;
    }
  }

  /// Register a coach with email, password, and name.
  /// Validates healis.org domain and creates a Firebase Auth user.
  /// Throws if the email is not a healis.org address, or on Firebase failure.
  Future<User?> signUpCoachWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
  }) async {
    _assertCoachEmail(email);
    final auth = _auth;
    final prefs = await SharedPreferences.getInstance();
    if (phoneNumber.isNotEmpty) {
      await prefs.setString('phone_email_map_$phoneNumber', email);
    }
    if (auth != null) {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        
        await prefs.setString('last_user_name', name);
        await prefs.setString('last_user_email', email);
      }
      return _auth!.currentUser;
    } else {
      // Mock mode for testing/local-only runs.
      await Future.delayed(const Duration(milliseconds: 200));
      await prefs.setString('last_user_name', name);
      await prefs.setString('last_user_email', email);
      return null;
    }
  }

  /// Persist the complete profile of the coach to Firestore and SharedPreferences.
  Future<void> saveCoachProfile({
    required String uid,
    required String name,
    required String email,
    required String phoneNumber,
    required String tagline,
    required String about,
    required String specializations,
    required String credentials,
    required int avatarIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (isFirebaseInitialized && _firestore != null) {
      await _firestore!.collection('coaches').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'tagline': tagline,
        'specialty': specializations,
        'about': about,
        'specializations': specializations,
        'credentials': credentials,
        'avatarIndex': avatarIndex,
        'role': 'coach',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Save login status and local caches
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_role', 'coach');
    await prefs.setBool('coach_profile_complete_$uid', true);
    await prefs.setBool('coach_profile_complete_mock_uid', true); // fallback for mock
    await prefs.setString('last_user_name', name);
    await prefs.setString('last_user_email', email);
    await prefs.setInt('local_avatar_index_$uid', avatarIndex);
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    final auth = _auth;
    if (auth != null) {
      await auth.signOut();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    await prefs.remove('user_role');
  }

  /// Sends a password reset email.
  Future<String> sendPasswordReset(String email, bool isCoach) async {
    final auth = _auth;
    String resolvedEmail = email.trim();

    if (isCoach) {
      _assertCoachEmail(resolvedEmail);
    }

    if (auth != null) {
      await auth.sendPasswordResetEmail(email: resolvedEmail);
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
    }

    return 'A password reset link has been sent to $resolvedEmail.';
  }

  /// Initiates phone number verification for password reset.
  Future<void> verifyPhoneNumberForReset(
    String phoneNumber,
    bool isCoach, {
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    final auth = _auth;
    final prefs = await SharedPreferences.getInstance();
    final cleanPhone = phoneNumber.trim();

    // Verify phone number exists in Firestore or local mock
    if (_firestore != null) {
      final collectionName = isCoach ? 'coaches' : 'users';
      final docQuery = await _firestore!
          .collection(collectionName)
          .where('phoneNumber', isEqualTo: cleanPhone)
          .limit(1)
          .get();
      if (docQuery.docs.isEmpty) {
        onError('No ${isCoach ? 'coach' : 'patient'} account found with this phone number.');
        return;
      }
    } else {
      final mappedEmail = prefs.getString('phone_email_map_$cleanPhone');
      if (mappedEmail == null && cleanPhone != '9876543210' && cleanPhone != '1234567890') {
        // Allow fallback test numbers or mapped numbers in mock mode
        await prefs.setString('phone_email_map_$cleanPhone', '$cleanPhone@${isCoach ? 'healis.org' : 'mock.com'}');
      }
    }

    if (auth != null) {
      try {
        // We ensure phone has country code for Firebase Auth, default to +91 or +1 if not present
        String formattedPhone = cleanPhone;
        if (!formattedPhone.startsWith('+')) {
          formattedPhone = '+91$cleanPhone'; // default India/standard prefix if user enters 10 digits
        }
        await auth.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            onError(e.message ?? 'Phone verification failed.');
          },
          codeSent: (String verificationId, int? resendToken) {
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } catch (e) {
        onError(e.toString());
      }
    } else {
      // Mock mode: simulate code sent
      await Future.delayed(const Duration(milliseconds: 400));
      onCodeSent('mock_verification_id');
    }
  }

  /// Confirms OTP and resets the password.
  Future<void> confirmPasswordResetWithOtp({
    required String verificationId,
    required String smsCode,
    required String newPassword,
    required String phoneNumber,
    required bool isCoach,
  }) async {
    final auth = _auth;
    final prefs = await SharedPreferences.getInstance();

    if (auth != null && verificationId != 'mock_verification_id') {
      try {
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode.trim(),
        );
        // Sign in with the credential to authenticate the user
        final userCredential = await auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          await userCredential.user!.updatePassword(newPassword);
          // Sign out so they can log in with their new password
          await auth.signOut();
        } else {
          throw Exception('Failed to authenticate with OTP.');
        }
      } catch (e) {
        throw Exception('Invalid OTP or failed to reset password: ${e.toString().replaceFirst('Exception: ', '')}');
      }
    } else {
      // Mock mode verification
      if (smsCode.trim() != '123456') {
        throw Exception('Invalid OTP. For mock testing, please enter 123456.');
      }
      await Future.delayed(const Duration(milliseconds: 400));
      // Save updated mock state if needed
      await prefs.setString('mock_password_$phoneNumber', newPassword);
    }
  }

  // ─── Coach Profile Persistence & Retrieval ─────────────────────────────────

  /// Saves the coach's profile to Firestore (if initialized) and SharedPreferences.
  Future<void> saveCoachProfile(CoachProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save locally in SharedPreferences
      final profileMap = profile.toMap();
      final profileJson = json.encode(profileMap);
      await prefs.setString('coach_profile_${profile.uid}', profileJson);
      await prefs.setString('last_coach_profile', profileJson);

      // Save to Firestore if available
      final firestore = _firestore;
      if (firestore != null) {
        await firestore.collection('coaches').doc(profile.uid).set(profileMap, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  /// Retrieves a specific coach's profile by UID, falling back to SharedPreferences and defaults.
  Future<CoachProfile> getCoachProfile(String uid) async {
    try {
      final defaultName = 'Dr. Sarah Mitchell';
      final defaultEmail = 'sarah.mitchell@healis.org';

      // 1. Try fetching from Firestore
      final firestore = _firestore;
      if (firestore != null) {
        try {
          final doc = await firestore.collection('coaches').doc(uid).get();
          if (doc.exists && doc.data() != null) {
            return CoachProfile.fromMap(doc.data()!, defaultName: defaultName, defaultEmail: defaultEmail);
          }
        } catch (_) {}
      }

      // 2. Fall back to local SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('coach_profile_$uid');
      if (localJson != null) {
        return CoachProfile.fromJson(localJson, defaultName: defaultName, defaultEmail: defaultEmail);
      }
    } catch (_) {}

    // 3. Fallback to default CoachProfile
    return CoachProfile.fromMap({'uid': uid}, defaultName: 'Dr. Sarah Mitchell', defaultEmail: 'sarah.mitchell@healis.org');
  }

  /// Retrieves the first available coach profile, or falls back to last_coach_profile / defaults.
  Future<CoachProfile> getFirstCoachProfile() async {
    try {
      final defaultName = 'Dr. Sarah Mitchell';
      final defaultEmail = 'sarah.mitchell@healis.org';

      // 1. Try fetching first from Firestore
      final firestore = _firestore;
      if (firestore != null) {
        try {
          final querySnapshot = await firestore.collection('coaches').get();
          if (querySnapshot.docs.isNotEmpty) {
            final docs = querySnapshot.docs;
            // Prioritize Kesar Parab or a custom coach
            final bestDoc = docs.firstWhere(
              (doc) {
                final name = (doc.data()['name'] as String? ?? '').toLowerCase();
                final email = (doc.data()['email'] as String? ?? '').toLowerCase();
                return name.contains('kesar') || 
                       (email != 'coach@healis.org' && email != 'sarah.mitchell@healis.org' && email != 'default_coach');
              },
              orElse: () => docs.first,
            );
            return CoachProfile.fromMap(bestDoc.data(), defaultName: defaultName, defaultEmail: defaultEmail);
          }
        } catch (_) {}
      }

      // 2. Fall back to local SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('last_coach_profile');
      if (localJson != null) {
        return CoachProfile.fromJson(localJson, defaultName: defaultName, defaultEmail: defaultEmail);
      }
    } catch (_) {}

    // 3. Fallback to default
    return CoachProfile.fromMap({'uid': 'default_coach'}, defaultName: 'Dr. Sarah Mitchell', defaultEmail: 'sarah.mitchell@healis.org');
  }
}

class UserProfileData {
  final String displayName;
  final String email;
  final String? localImagePath;
  final String profileBgColor;

  UserProfileData({
    required this.displayName,
    required this.email,
    this.localImagePath,
    required this.profileBgColor,
  });
}
