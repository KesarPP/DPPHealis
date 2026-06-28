import 'package:flutter/material.dart';
import 'clinician_dashboard_screen.dart';
import '../data/gelato_theme.dart';
import '../services/auth_service.dart';

class CoachProfileSetupScreen extends StatefulWidget {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;

  const CoachProfileSetupScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<CoachProfileSetupScreen> createState() => _CoachProfileSetupScreenState();
}

class _CoachProfileSetupScreenState extends State<CoachProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taglineController = TextEditingController();
  final _aboutController = TextEditingController();
  final _specializationsController = TextEditingController();
  final _credentialsController = TextEditingController();

  int _selectedAvatarIndex = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _taglineController.dispose();
    _aboutController.dispose();
    _specializationsController.dispose();
    _credentialsController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authService = AuthService();
      await authService.saveCoachProfile(
        uid: widget.uid,
        name: widget.name,
        email: widget.email,
        phoneNumber: widget.phoneNumber,
        tagline: _taglineController.text.trim(),
        about: _aboutController.text.trim(),
        specializations: _specializationsController.text.trim(),
        credentials: _credentialsController.text.trim(),
        avatarIndex: _selectedAvatarIndex,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Setup Completed!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const ClinicianDashboardScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: GelatoTheme.bg,
        appBar: AppBar(
          backgroundColor: GelatoTheme.bg,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Setup Coach Profile',
            style: TextStyle(
              color: GelatoTheme.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
        ),
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to Healis!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Let\'s customize your public profile that patients see when choosing a coach.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: GelatoTheme.textLight,
                      ),
                    ),
                    const SizedBox(height: 28),
                    
                    // Avatar selector title
                    const Text(
                      'Select Your Avatar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Avatar Selection Grid/Carousel
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedAvatarIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAvatarIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 100,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? GelatoTheme.green.withValues(alpha: 0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? GelatoTheme.greenDark : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(60, 60),
                                    painter: CoachAvatarPainter(index: index),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Option ${index + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                      color: isSelected ? GelatoTheme.greenDark : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Inputs Section
                    _buildInputField(
                      label: 'Tag Line',
                      hint: 'e.g. Empowering you to reach your health goals',
                      controller: _taglineController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a tag line' : null,
                    ),
                    const SizedBox(height: 20),

                    _buildInputField(
                      label: 'Credentials and Certifications',
                      hint: 'e.g. RD, CDE, Wellness Coach',
                      controller: _credentialsController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your credentials' : null,
                    ),
                    const SizedBox(height: 20),

                    _buildInputField(
                      label: 'Specializations',
                      hint: 'e.g. Diabetes prevention, weight management, nutrition coaching',
                      controller: _specializationsController,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter specializations' : null,
                    ),
                    const SizedBox(height: 20),

                    _buildInputField(
                      label: 'About Me',
                      hint: 'Share your background, philosophy, and experience...',
                      controller: _aboutController,
                      maxLines: 4,
                      validator: (value) => value == null || value.trim().isEmpty ? 'Please tell us about yourself' : null,
                    ),
                    const SizedBox(height: 36),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _handleSaveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GelatoTheme.green,
                          foregroundColor: GelatoTheme.greenDark,
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.black, width: 2.0),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: GelatoTheme.greenDark, strokeWidth: 2),
                              )
                            : const Text(
                                'Save & Complete Setup',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: GelatoTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w400),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: GelatoTheme.greenDark, width: 2.0),
            ),
          ),
        ),
      ],
    );
  }
}

class CoachAvatarPainter extends CustomPainter {
  final int index;

  CoachAvatarPainter({required this.index});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Define colors
    final isDarkSkin = (index == 4 || index == 7);
    final skinPaint = Paint()
      ..color = isDarkSkin ? const Color(0xFF8D5524) : const Color(0xFFFFDBAC)
      ..style = PaintingStyle.fill;

    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final lipPaint = Paint()
      ..color = const Color(0xFFE57373)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    // 1. Draw Hair (Back Layer if applicable)
    final hairPaint = Paint()
      ..color = (index == 0 || index == 1 || index == 5 || index == 8 || index == 9)
          ? const Color(0xFF5D4037) // Brown
          : const Color(0xFF212121); // Dark grey/black
    hairPaint.style = PaintingStyle.fill;

    if (index == 0 || index == 5 || index == 6) {
      // Long hair back block
      final hairPath = Path();
      hairPath.moveTo(cx - r * 0.7, cy);
      hairPath.quadraticBezierTo(cx - r * 0.9, cy + r * 0.8, cx - r * 0.6, cy + r * 0.9);
      hairPath.lineTo(cx + r * 0.6, cy + r * 0.9);
      hairPath.quadraticBezierTo(cx + r * 0.9, cy + r * 0.8, cx + r * 0.7, cy);
      canvas.drawPath(hairPath, hairPaint);
      canvas.drawPath(hairPath, outlinePaint);
    } else if (index == 1) {
      // Bun on top of head
      canvas.drawCircle(Offset(cx, cy - r * 0.85), r * 0.3, hairPaint);
      canvas.drawCircle(Offset(cx, cy - r * 0.85), r * 0.3, outlinePaint);
    }

    // 2. Draw Body / Clothes
    final bodyPath = Path();
    bodyPath.moveTo(cx - r * 0.5, cy + r * 0.6);
    bodyPath.lineTo(cx + r * 0.5, cy + r * 0.6);
    bodyPath.lineTo(cx + r * 0.7, cy + r);
    bodyPath.lineTo(cx - r * 0.7, cy + r);
    bodyPath.close();

    final isScrubs = (index == 5 || index == 7 || index == 8);
    final clothesColor = isScrubs ? const Color(0xFF1E88E5) : const Color(0xFFEDE7F6);
    final clothesPaint = Paint()
      ..color = clothesColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(bodyPath, clothesPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    if (!isScrubs) {
      // Draw doctor coat lapels and shirt
      final shirtColor = (index == 0) ? const Color(0xFFBBDEFB) :
                         (index == 1) ? const Color(0xFF37474F) :
                         (index == 3) ? const Color(0xFFE1BEE7) :
                         (index == 4) ? const Color(0xFF90CAF9) :
                         (index == 6) ? const Color(0xFFFFF59D) :
                         const Color(0xFFFFCDD2); // tie shirt
      final shirtPaint = Paint()..color = shirtColor..style = PaintingStyle.fill;
      
      final shirtPath = Path();
      shirtPath.moveTo(cx - r * 0.25, cy + r * 0.6);
      shirtPath.lineTo(cx + r * 0.25, cy + r * 0.6);
      shirtPath.lineTo(cx + r * 0.15, cy + r * 0.9);
      shirtPath.lineTo(cx - r * 0.15, cy + r * 0.9);
      shirtPath.close();
      canvas.drawPath(shirtPath, shirtPaint);
      canvas.drawPath(shirtPath, outlinePaint);

      // Red Tie for index 9
      if (index == 9) {
        final tiePath = Path();
        tiePath.moveTo(cx - r * 0.05, cy + r * 0.7);
        tiePath.lineTo(cx + r * 0.05, cy + r * 0.7);
        tiePath.lineTo(cx + r * 0.08, cy + r * 0.92);
        tiePath.lineTo(cx, cy + r * 0.97);
        tiePath.lineTo(cx - r * 0.08, cy + r * 0.92);
        tiePath.close();
        canvas.drawPath(tiePath, Paint()..color = Colors.red.shade700..style = PaintingStyle.fill);
        canvas.drawPath(tiePath, outlinePaint);
      }
    } else {
      // V-neck scrubs line
      final vNeck = Path();
      vNeck.moveTo(cx - r * 0.2, cy + r * 0.6);
      vNeck.lineTo(cx, cy + r * 0.75);
      vNeck.lineTo(cx + r * 0.2, cy + r * 0.6);
      canvas.drawPath(vNeck, outlinePaint);
    }

    // 3. Draw Stethoscope (if index is 2, 5, 8, 9)
    if (index == 2 || index == 5 || index == 8 || index == 9) {
      final stethPaint = Paint()
        ..color = Colors.grey.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      final stethPath = Path();
      stethPath.moveTo(cx - r * 0.35, cy + r * 0.65);
      stethPath.quadraticBezierTo(cx, cy + r * 0.88, cx + r * 0.35, cy + r * 0.65);
      canvas.drawPath(stethPath, stethPaint);

      final bellPath = Path();
      bellPath.moveTo(cx + r * 0.15, cy + r * 0.78);
      bellPath.lineTo(cx + r * 0.15, cy + r * 0.88);
      canvas.drawPath(bellPath, stethPaint);
      canvas.drawCircle(Offset(cx + r * 0.15, cy + r * 0.90), 3, Paint()..color = Colors.grey.shade800);
    }

    // 4. Draw Head
    canvas.drawCircle(Offset(cx, cy - r * 0.1), r * 0.65, skinPaint);
    canvas.drawCircle(Offset(cx, cy - r * 0.1), r * 0.65, outlinePaint);

    // 5. Draw Hair (Front Cap Layer)
    if (index == 0 || index == 5 || index == 6) {
      // Long hair top cap
      final hairCap = Path();
      hairCap.addArc(Rect.fromCircle(center: Offset(cx, cy - r * 0.1), radius: r * 0.65), -3.14, 3.14);
      hairCap.quadraticBezierTo(cx - r * 0.5, cy - r * 0.15, cx - r * 0.65, cy);
      hairCap.lineTo(cx - r * 0.65, cy - r * 0.15);
      hairCap.quadraticBezierTo(cx, cy - r * 0.35, cx + r * 0.65, cy - r * 0.15);
      hairCap.lineTo(cx + r * 0.65, cy);
      hairCap.quadraticBezierTo(cx + r * 0.5, cy - r * 0.15, cx, cy - r * 0.1);
      hairCap.close();
      canvas.drawPath(hairCap, hairPaint);
      canvas.drawPath(hairCap, outlinePaint);
    } else if (index == 1) {
      // Short bun style front cap
      final hairCap = Path();
      hairCap.addArc(Rect.fromCircle(center: Offset(cx, cy - r * 0.1), radius: r * 0.65), -3.0, 3.0);
      hairCap.quadraticBezierTo(cx, cy - r * 0.35, cx - r * 0.65, cy - r * 0.1);
      hairCap.close();
      canvas.drawPath(hairCap, hairPaint);
      canvas.drawPath(hairCap, outlinePaint);
    } else if (index == 2) {
      // Wavy short hair
      final hairCap = Path();
      hairCap.moveTo(cx - r * 0.65, cy - r * 0.1);
      hairCap.quadraticBezierTo(cx - r * 0.3, cy - r * 0.65, cx, cy - r * 0.7);
      hairCap.quadraticBezierTo(cx + r * 0.3, cy - r * 0.65, cx + r * 0.65, cy - r * 0.1);
      hairCap.quadraticBezierTo(cx + r * 0.75, cy - r * 0.3, cx + r * 0.6, cy - r * 0.5);
      hairCap.quadraticBezierTo(cx, cy - r * 0.85, cx - r * 0.6, cy - r * 0.5);
      hairCap.quadraticBezierTo(cx - r * 0.75, cy - r * 0.3, cx - r * 0.65, cy - r * 0.1);
      canvas.drawPath(hairCap, hairPaint);
      canvas.drawPath(hairCap, outlinePaint);
    } else if (index == 3 || index == 4 || index == 9) {
      // Male spiked/cropped hair
      final hairCap = Path();
      hairCap.moveTo(cx - r * 0.66, cy - r * 0.2);
      hairCap.quadraticBezierTo(cx - r * 0.4, cy - r * 0.78, cx, cy - r * 0.82);
      hairCap.quadraticBezierTo(cx + r * 0.4, cy - r * 0.78, cx + r * 0.66, cy - r * 0.2);
      hairCap.quadraticBezierTo(cx + r * 0.3, cy - r * 0.55, cx, cy - r * 0.45);
      hairCap.quadraticBezierTo(cx - r * 0.3, cy - r * 0.55, cx - r * 0.66, cy - r * 0.2);
      canvas.drawPath(hairCap, hairPaint);
      canvas.drawPath(hairCap, outlinePaint);
    } else if (index == 7) {
      // Nurse cap overlay (dark blue)
      final capPaint = Paint()..color = const Color(0xFF0D47A1)..style = PaintingStyle.fill;
      final capPath = Path();
      capPath.moveTo(cx - r * 0.55, cy - r * 0.45);
      capPath.quadraticBezierTo(cx, cy - r * 0.68, cx + r * 0.55, cy - r * 0.45);
      capPath.lineTo(cx + r * 0.45, cy - r * 0.78);
      capPath.quadraticBezierTo(cx, cy - r * 0.85, cx - r * 0.45, cy - r * 0.78);
      capPath.close();
      canvas.drawPath(capPath, capPaint);
      canvas.drawPath(capPath, outlinePaint);
    }

    // 6. Beard (index 3, 4, 8)
    if (index == 3 || index == 4 || index == 8) {
      final beardPaint = Paint()..color = hairPaint.color..style = PaintingStyle.fill;
      final beardPath = Path();
      beardPath.moveTo(cx - r * 0.52, cy + r * 0.1);
      beardPath.quadraticBezierTo(cx - r * 0.5, cy + r * 0.45, cx, cy + r * 0.55);
      beardPath.quadraticBezierTo(cx + r * 0.5, cy + r * 0.45, cx + r * 0.52, cy + r * 0.1);
      beardPath.lineTo(cx + r * 0.42, cy + r * 0.1);
      beardPath.quadraticBezierTo(cx + r * 0.35, cy + r * 0.35, cx, cy + r * 0.42);
      beardPath.quadraticBezierTo(cx - r * 0.35, cy + r * 0.35, cx - r * 0.42, cy + r * 0.1);
      beardPath.close();
      canvas.drawPath(beardPath, beardPaint);
      canvas.drawPath(beardPath, outlinePaint);
    }

    // 7. Face Details (Eyes, Cheeks, Smile, Glasses)
    // Eyes
    canvas.drawCircle(Offset(cx - r * 0.22, cy - r * 0.08), 3.5, eyePaint);
    canvas.drawCircle(Offset(cx + r * 0.22, cy - r * 0.08), 3.5, eyePaint);
    
    // Eye highlights (white dots)
    canvas.drawCircle(Offset(cx - r * 0.20, cy - r * 0.10), 1.0, whitePaint);
    canvas.drawCircle(Offset(cx + r * 0.24, cy - r * 0.10), 1.0, whitePaint);

    // Cheeks
    final cheekPaint = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.55)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.38, cy + r * 0.08), 4.5, cheekPaint);
    canvas.drawCircle(Offset(cx + r * 0.38, cy + r * 0.08), 4.5, cheekPaint);

    // Smiling mouth
    final mouth = Path();
    mouth.moveTo(cx - r * 0.08, cy + r * 0.12);
    mouth.quadraticBezierTo(cx, cy + r * 0.22, cx + r * 0.08, cy + r * 0.12);
    canvas.drawPath(mouth, lipPaint);

    // Glasses (index 1 and 9)
    if (index == 1 || index == 9) {
      final glassesPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(cx - r * 0.22, cy - r * 0.08), r * 0.18, glassesPaint);
      canvas.drawCircle(Offset(cx + r * 0.22, cy - r * 0.08), r * 0.18, glassesPaint);
      canvas.drawLine(Offset(cx - r * 0.04, cy - r * 0.08), Offset(cx + r * 0.04, cy - r * 0.08), glassesPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CoachAvatarPainter oldDelegate) {
    return oldDelegate.index != index;
  }
}
