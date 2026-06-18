import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'signup_screen.dart';
import 'clinician_dashboard_screen.dart';
import 'risk_assessment_step1_screen.dart';
import '../data/gelato_theme.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _brandColor = Color(0xFF1B3D6D);
const _slateGrey = Color(0xFF6B7C93);
const _borderBlue = Color(0xFF4A88C5);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isPatientSelected = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handlePatientLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final authService = AuthService();
    final isTesting = !authService.isFirebaseInitialized;

    if (!isTesting && (email.isEmpty || password.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await authService.signInWithEmailAndPassword(email, password);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const RiskAssessmentStep1Screen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Authentication failed. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address format.';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid credentials provided.';
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticateWithBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      final bool canCheck = await auth.canCheckBiometrics;
      final bool isSupported = await auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication is not supported or set up on this device.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      final List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No biometrics are enrolled. Please register a fingerprint or face in settings.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        }
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to log in to DiaPrevent',
      );

      if (didAuthenticate && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => _isPatientSelected
                ? const RiskAssessmentStep1Screen()
                : const ClinicianDashboardScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric authentication failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isPatientSelected ? GelatoTheme.bg : const Color(0xFFF7F9FC),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: _isPatientSelected ? GelatoTheme.bg : null,
          gradient: _isPatientSelected
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEFE8FC),
                    Color(0xFFFDE8E8),
                  ],
                ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Banner
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          _isPatientSelected
                              ? 'assets/images/login_hero.jpg'
                              : 'assets/images/clinician_login_hero.jpg',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.white,
                              alignment: Alignment.center,
                              child: Text(
                                _isPatientSelected
                                    ? 'Welcome to DiaPrevent'
                                    : 'Welcome to DiaPrevent - Clinician Portal',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _isPatientSelected
                                      ? const Color(0xFF1E1E50)
                                      : const Color(0xFF1B3D6D),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form Container Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
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

                          // Email or Phone Number Field
                          TextField(
                            controller: _emailController,
                            style: TextStyle(
                              color: _isPatientSelected ? GelatoTheme.textDark : _brandColor,
                              fontWeight: _isPatientSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'Email Address',
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
                                  Icons.mail_outline_rounded,
                                  color: _isPatientSelected ? GelatoTheme.blueDark : _borderBlue,
                                  size: 24,
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
                              hintText: 'Password',
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
                          const SizedBox(height: 12),

                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: _isPatientSelected ? GelatoTheme.textDark : _brandColor,
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontWeight: _isPatientSelected ? FontWeight.w900 : FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          _isPatientSelected
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: GelatoTheme.cardShadow,
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: GelatoTheme.purple,
                                      foregroundColor: GelatoTheme.purpleDark,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(color: Colors.black, width: 2.0),
                                      ),
                                    ),
                                    onPressed: _isLoading ? null : _handlePatientLogin,
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              valueColor: AlwaysStoppedAnimation<Color>(GelatoTheme.purpleDark),
                                            ),
                                          )
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF427EBD),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 2,
                                    shadowColor: const Color(0xFF427EBD).withValues(alpha: 0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const ClinicianDashboardScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 20),

                          // OR Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: _isPatientSelected ? Colors.black : const Color(0xFFE2E8F0),
                                  thickness: 1.5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    color: _isPatientSelected ? GelatoTheme.textDark : _slateGrey,
                                    fontWeight: _isPatientSelected ? FontWeight.w900 : FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: _isPatientSelected ? Colors.black : const Color(0xFFE2E8F0),
                                  thickness: 1.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Biometric Login Button
                          _isPatientSelected
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: GelatoTheme.cardShadow,
                                  ),
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: GelatoTheme.textDark,
                                      side: const BorderSide(color: Colors.black, width: 2.0),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    onPressed: _authenticateWithBiometrics,
                                    icon: const Icon(Icons.fingerprint_rounded, color: GelatoTheme.purpleDark, size: 26),
                                    label: const Text(
                                      'Biometric Login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                )
                              : OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _brandColor,
                                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  onPressed: _authenticateWithBiometrics,
                                  icon: const Icon(Icons.fingerprint_rounded, color: _borderBlue, size: 26),
                                  label: const Text(
                                    'Biometric Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 16),

                          // Sign Up Button
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
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                      );
                                    },
                                    child: const Text(
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
                                    backgroundColor: const Color(0xFF90D185),
                                    foregroundColor: _brandColor,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 2,
                                    shadowColor: const Color(0xFF90D185).withValues(alpha: 0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
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
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 15,
                          color: _isPatientSelected ? GelatoTheme.textLight : _slateGrey,
                          fontWeight: _isPatientSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        children: [
                          const TextSpan(text: "Don't have an account? "),
                          TextSpan(
                            text: 'Create one',
                            style: TextStyle(
                              color: _isPatientSelected ? GelatoTheme.purpleDark : _borderBlue,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}