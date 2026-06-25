import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _brandColor = Color(0xFF1B3D6D);
const _slateGrey = Color(0xFF6B7C93);
const _borderBlue = Color(0xFF4A88C5);

class ForgotPasswordScreen extends StatefulWidget {
  final bool isPatient;

  const ForgotPasswordScreen({super.key, required this.isPatient});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleResetPassword() async {
    final emailOrPhone = _controller.text.trim();

    if (emailOrPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address or phone number.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = AuthService();
      final successMessage = await authService.sendPasswordReset(emailOrPhone, !widget.isPatient);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: widget.isPatient ? const BorderSide(color: Colors.black, width: 2) : BorderSide.none,
            ),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: widget.isPatient ? GelatoTheme.greenDark : const Color(0xFF427EBD),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text('Reset Link Sent', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              successMessage,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isPatient ? GelatoTheme.purple : const Color(0xFF427EBD),
                  foregroundColor: widget.isPatient ? GelatoTheme.purpleDark : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: widget.isPatient ? const BorderSide(color: Colors.black, width: 1.5) : BorderSide.none,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  Navigator.of(context).pop(); // return to login screen
                },
                child: const Text('Back to Login', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Password reset failed. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email or phone number.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address format.';
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
            content: Text(e.toString().replaceFirst('Exception: ', '')),
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isPatient ? GelatoTheme.bg : const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: widget.isPatient ? GelatoTheme.textDark : _brandColor,
            size: 28,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: widget.isPatient ? GelatoTheme.bg : null,
          gradient: widget.isPatient
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon Header
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: widget.isPatient ? GelatoTheme.yellow : const Color(0xFFEBF2FA),
                      shape: BoxShape.circle,
                      border: widget.isPatient ? Border.all(color: Colors.black, width: 2) : null,
                      boxShadow: widget.isPatient ? GelatoTheme.cardShadow : null,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 44,
                      color: widget.isPatient ? GelatoTheme.textDark : const Color(0xFF427EBD),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Forgot Password?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: widget.isPatient ? FontWeight.w900 : FontWeight.bold,
                      color: widget.isPatient ? GelatoTheme.textDark : _brandColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    widget.isPatient
                        ? 'Enter your registered email address or phone number, and we will send you instructions to reset your password.'
                        : 'Enter your registered clinician email address (@healis.org) or phone number to receive a password reset link.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: widget.isPatient ? GelatoTheme.textLight : _slateGrey,
                      fontWeight: widget.isPatient ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Container Card
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: widget.isPatient ? GelatoTheme.cardRadius : BorderRadius.circular(28),
                      border: widget.isPatient
                          ? GelatoTheme.cardBorder
                          : Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: widget.isPatient
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
                        // Email or Phone Number Field
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            setState(() {});
                          },
                          style: TextStyle(
                            color: widget.isPatient ? GelatoTheme.textDark : _brandColor,
                            fontWeight: widget.isPatient ? FontWeight.w700 : FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Email Address or Phone Number',
                            hintText: 'Email Address or Phone Number',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelStyle: TextStyle(
                              color: widget.isPatient ? GelatoTheme.textDark : _borderBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            hintStyle: TextStyle(
                              color: widget.isPatient ? GelatoTheme.textMuted : _slateGrey,
                              fontWeight: widget.isPatient ? FontWeight.w500 : FontWeight.w400,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                              child: Icon(
                                RegExp(r'^\d+$').hasMatch(_controller.text.trim())
                                    ? Icons.phone_iphone_rounded
                                    : Icons.mail_outline_rounded,
                                color: widget.isPatient ? GelatoTheme.blueDark : _borderBlue,
                                size: 24,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(widget.isPatient ? 20 : 24),
                              borderSide: BorderSide(
                                color: widget.isPatient ? Colors.black : _borderBlue,
                                width: widget.isPatient ? 2.0 : 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(widget.isPatient ? 20 : 24),
                              borderSide: BorderSide(
                                color: widget.isPatient ? Colors.black : _borderBlue,
                                width: widget.isPatient ? 2.0 : 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(widget.isPatient ? 20 : 24),
                              borderSide: BorderSide(
                                color: widget.isPatient ? Colors.black : _borderBlue,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Reset Password Button
                        widget.isPatient
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
                                  onPressed: _isLoading ? null : _handleResetPassword,
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
                                          'Reset Password',
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
                                onPressed: _isLoading ? null : _handleResetPassword,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Reset Password',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                      ],
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
