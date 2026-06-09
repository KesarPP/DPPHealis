import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../main.dart'; // MainShell
import 'signup_screen.dart';
import 'clinician_dashboard_screen.dart';

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
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (didAuthenticate && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => _isPatientSelected
                ? const MainShell()
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
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome Header
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: _brandColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your path to a healthier life starts here.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _slateGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Healthcare Illustration
                Image.asset(
                  'assets/images/diaprevent_illustration.png',
                  height: 210,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 210,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.medical_services_outlined,
                        size: 80,
                        color: _slateGrey,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Form Container Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                    boxShadow: [
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
                          color: const Color(0xFFEBF2FA),
                          borderRadius: BorderRadius.circular(16),
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
                                        ? const Color(0xFF427EBD)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Patient',
                                    style: TextStyle(
                                      color: _isPatientSelected
                                          ? Colors.white
                                          : const Color(0xFF4A6F8A),
                                      fontWeight: FontWeight.bold,
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
                                          : const Color(0xFF4A6F8A),
                                      fontWeight: FontWeight.bold,
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
                        style: const TextStyle(color: _brandColor, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Email or Phone Number',
                          hintText: 'Email or Phone Number',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: const TextStyle(
                            color: _borderBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          hintStyle: const TextStyle(
                            color: _slateGrey,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 16.0, right: 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person_outline_rounded, color: _borderBlue, size: 24),
                                SizedBox(width: 6),
                                Icon(Icons.phone_android_rounded, color: _borderBlue, size: 24),
                              ],
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: _borderBlue, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: _borderBlue, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: _borderBlue, width: 2.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: _brandColor, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Password',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          labelStyle: const TextStyle(
                            color: _borderBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          hintStyle: const TextStyle(
                            color: _slateGrey,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 16.0, right: 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_outline_rounded, color: _borderBlue, size: 22),
                                SizedBox(width: 6),
                                Icon(Icons.vpn_key_outlined, color: _borderBlue, size: 22),
                              ],
                            ),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: _borderBlue,
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
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: _borderBlue, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: _borderBlue, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: _borderBlue, width: 2.0),
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
                            foregroundColor: _brandColor,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      ElevatedButton(
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
                              builder: (_) => _isPatientSelected
                                  ? const MainShell()
                                  : const ClinicianDashboardScreen(),
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
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1.5)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: _slateGrey,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1.5)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Biometric Login Button
                      OutlinedButton.icon(
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
                      ElevatedButton(
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
                const SizedBox(height: 24),

                // Footer
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      color: _slateGrey,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: "Don't have an account? "),
                      TextSpan(
                        text: 'Create one',
                        style: const TextStyle(
                          color: _borderBlue,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
