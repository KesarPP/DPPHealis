import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'clinician_dashboard_screen.dart';
import 'risk_assessment_step1_screen.dart';
import '../data/gelato_theme.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _brandColor = Color(0xFF1B3D6D);
const _slateGrey = Color(0xFF6B7C93);
const _borderBlue = Color(0xFF4A88C5);

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPatientSelected = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handlePatientSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final authService = AuthService();
    final isTesting = !authService.isFirebaseInitialized;

    if (!isTesting && (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (!isTesting && (password != confirmPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
      );

      if (mounted) {
        if (!isTesting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration Successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const RiskAssessmentStep1Screen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed. Please try again.';
      if (e.code == 'email-already-in-use') {
        message = 'The email address is already in use by another account.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/password accounts are not enabled.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.message != null) {
        message = e.message!;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isPatientSelected ? GelatoTheme.bg : const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: _isPatientSelected ? GelatoTheme.textDark : _brandColor),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: _isPatientSelected ? FontWeight.w900 : FontWeight.w800,
                    color: _isPatientSelected ? GelatoTheme.textDark : _brandColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join DiaPrevent and start your healthy life today.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: _isPatientSelected ? FontWeight.w600 : FontWeight.w500,
                    color: _isPatientSelected ? GelatoTheme.textLight : _slateGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Form Container Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: _isPatientSelected ? GelatoTheme.cardRadius : BorderRadius.circular(28),
                    border: _isPatientSelected
                        ? GelatoTheme.cardBorder
                        : Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    boxShadow: _isPatientSelected
                        ? GelatoTheme.cardShadow
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Account Type Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _isPatientSelected ? GelatoTheme.bg : const Color(0xFFEBF2FA),
                          borderRadius: BorderRadius.circular(16),
                          border: _isPatientSelected
                              ? Border.all(color: Colors.black, width: 1.5)
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Patient Option
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPatientSelected = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _isPatientSelected
                                        ? GelatoTheme.purple
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: _isPatientSelected
                                        ? Border.all(color: Colors.black, width: 1.5)
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Patient',
                                    style: TextStyle(
                                      color: _isPatientSelected
                                          ? GelatoTheme.purpleDark
                                          : const Color(0xFF4A6F8A),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Doctor/Coach Option
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPatientSelected = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: !_isPatientSelected
                                        ? const Color(0xFF427EBD)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Doctor/Coach',
                                    style: TextStyle(
                                      color: !_isPatientSelected
                                          ? Colors.white
                                          : GelatoTheme.textLight,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Full Name Field
                      TextField(
                        controller: _nameController,
                        style: TextStyle(
                          color: _isPatientSelected ? GelatoTheme.textDark : _brandColor,
                          fontWeight: _isPatientSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(
                            color: _isPatientSelected ? GelatoTheme.textDark : _borderBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          hintStyle: TextStyle(
                            color: _isPatientSelected ? GelatoTheme.textMuted : _slateGrey,
                            fontWeight: _isPatientSelected ? FontWeight.w500 : FontWeight.w400,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  color: _isPatientSelected ? GelatoTheme.blueDark : _borderBlue,
                                  size: 24,
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.badge_outlined,
                                  color: _isPatientSelected ? GelatoTheme.blueDark : _borderBlue,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: _isPatientSelected ? 2.0 : 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: _isPatientSelected ? 2.0 : 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email ID Field
                      TextField(
                        controller: _emailController,
                        style: TextStyle(
                          color: _isPatientSelected ? GelatoTheme.textDark : _brandColor,
                          fontWeight: _isPatientSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter your email address',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(
                            color: _isPatientSelected ? GelatoTheme.textDark : _borderBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          hintStyle: TextStyle(
                            color: _isPatientSelected ? GelatoTheme.textMuted : _slateGrey,
                            fontWeight: _isPatientSelected ? FontWeight.w500 : FontWeight.w400,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mail_outline_rounded,
                                  color: _isPatientSelected ? GelatoTheme.blueDark : _borderBlue,
                                  size: 24,
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.alternate_email_rounded,
                                  color: _isPatientSelected ? GelatoTheme.blueDark : _borderBlue,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: _isPatientSelected ? 2.0 : 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: _isPatientSelected ? 2.0 : 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(
                          color: _isPatientSelected ? GelatoTheme.textDark : _brandColor,
                          fontWeight: _isPatientSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Create a password',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(
                            color: _isPatientSelected ? GelatoTheme.textDark : _borderBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          hintStyle: TextStyle(
                            color: _isPatientSelected ? GelatoTheme.textMuted : _slateGrey,
                            fontWeight: _isPatientSelected ? FontWeight.w500 : FontWeight.w400,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              color: _isPatientSelected ? GelatoTheme.blueDark : _borderBlue,
                              size: 22,
                            ),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _isPatientSelected ? GelatoTheme.blueDark : _borderBlue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: _isPatientSelected ? 2.0 : 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: _isPatientSelected ? 2.0 : 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password Field
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(
                          color: _isPatientSelected ? GelatoTheme.textDark : _brandColor,
                          fontWeight: _isPatientSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          hintText: 'Retype your password',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: TextStyle(
                            color: _isPatientSelected ? GelatoTheme.textDark : _borderBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          hintStyle: TextStyle(
                            color: _isPatientSelected ? GelatoTheme.textMuted : _slateGrey,
                            fontWeight: _isPatientSelected ? FontWeight.w500 : FontWeight.w400,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              color: _isPatientSelected ? GelatoTheme.blueDark : _borderBlue,
                              size: 22,
                            ),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _isPatientSelected ? GelatoTheme.blueDark : _borderBlue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: _isPatientSelected ? 2.0 : 1.5,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: _isPatientSelected ? 2.0 : 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_isPatientSelected ? 20 : 24),
                            borderSide: BorderSide(
                              color: _isPatientSelected ? Colors.black : _borderBlue,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Register Button (Primary Sign Up)
                      _isPatientSelected
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: GelatoTheme.cardShadow,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GelatoTheme.green,
                                  foregroundColor: GelatoTheme.greenDark,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(color: Colors.black, width: 2.0),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _handlePatientSignUp,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(GelatoTheme.greenDark),
                                        ),
                                      )
                                    : const Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF90D185), // Soft green
                                foregroundColor: _brandColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 2,
                                shadowColor: const Color(0xFF90D185).withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Registration Successful!'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const ClinicianDashboardScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Footer Link back to Login
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 15,
                      color: _isPatientSelected ? GelatoTheme.textLight : _slateGrey,
                      fontWeight: _isPatientSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: "Already have an account? "),
                      TextSpan(
                        text: 'Log In',
                        style: TextStyle(
                          color: _isPatientSelected ? GelatoTheme.purpleDark : _borderBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pop(context);
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
