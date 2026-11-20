import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../services/auth_service.dart';

const _brandColor = Color(0xFF1B3D6D);
const _slateGrey = Color(0xFF6B7C93);
const _borderBlue = Color(0xFF4A88C5);

class ForgotPasswordScreen extends StatefulWidget {
  final bool isPatient;
  final String? initialEmail;

  const ForgotPasswordScreen({super.key, required this.isPatient, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid email address.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().sendPasswordReset(email, !widget.isPatient);
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: widget.isPatient ? const BorderSide(color: Colors.black, width: 2) : BorderSide.none,
          ),
          title: const Row(
            children: [
              Icon(Icons.mark_email_read_rounded, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text('Reset Link Sent', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A password reset link has been sent to:\n$email',
                style: const TextStyle(height: 1.4, fontSize: 14),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFD97706)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'If you don\'t see the email within 1–2 minutes, please check your Spam or Junk folder.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.3, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (error) {
      String message = 'Could not send the reset email.';
      if (error.code == 'user-not-found') {
        message = 'No account found with this email address. Please check your spelling or sign up.';
      } else if (error.code == 'invalid-email') {
        message = 'Please enter a valid email address format.';
      } else if (error.code == 'too-many-requests') {
        message = 'Too many attempts. Please wait a few moments before trying again.';
      } else if (error.code == 'network-request-failed') {
        message = 'Network error. Please check your internet connection.';
      } else if (error.message != null) {
        message = error.message!;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.isPatient ? GelatoTheme.textDark : _brandColor;
    final accent = widget.isPatient ? GelatoTheme.purple : const Color(0xFF427EBD);

    return Scaffold(
      backgroundColor: widget.isPatient ? GelatoTheme.bg : const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: foreground, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.isPatient ? GelatoTheme.bg : null,
          gradient: widget.isPatient
              ? null
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEFE8FC), Color(0xFFFDE8E8)],
                ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_reset_rounded, size: 64, color: accent),
                  const SizedBox(height: 20),
                  Text(
                    'Forgot Password?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: foreground),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.isPatient
                        ? 'Enter your registered email address and we will send you a password reset link.'
                        : 'Enter your clinician email address (@healis.org) and we will send you a password reset link.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, height: 1.4, color: widget.isPatient ? GelatoTheme.textLight : _slateGrey),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: widget.isPatient ? GelatoTheme.cardRadius : BorderRadius.circular(28),
                      border: widget.isPatient
                          ? GelatoTheme.cardBorder
                          : Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      boxShadow: widget.isPatient ? GelatoTheme.cardShadow : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter your email address',
                            prefixIcon: Icon(Icons.mail_outline_rounded, color: widget.isPatient ? GelatoTheme.blueDark : _borderBlue),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: widget.isPatient ? Colors.black : _borderBlue, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: widget.isPatient ? Colors.black : _borderBlue, width: 2),
                            ),
                          ),
                          onSubmitted: (_) => _sendResetEmail(),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _sendResetEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: widget.isPatient ? GelatoTheme.purpleDark : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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