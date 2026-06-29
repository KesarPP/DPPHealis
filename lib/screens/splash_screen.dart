import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'clinician_dashboard_screen.dart';
import 'coach_profile_setup_screen.dart';
import '../main.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoggedIn = false;
  String? _userRole;
  bool _isProfileComplete = true;

  @override
  void initState() {
    super.initState();


    // Configure Logo and Text entry animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.80, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.90, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start a timer for the minimum splash duration (2.6 seconds)
    final minDelay = Future.delayed(const Duration(milliseconds: 2600));
    
    // Concurrently load the logged-in status
    await _loadLoggedInStatus();
    
    // Wait until the minimum splash duration has elapsed
    await minDelay;
    
    // Navigate to the next screen
    if (mounted) {
      _navigateNext();
    }
  }

  Future<void> _loadLoggedInStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authService = AuthService();
      final user = authService.currentUser;
      
      String? role;
      bool isProfileComplete = true;
      if (user != null) {
        role = await authService.getUserRole();
        if (role == 'coach') {
          if (authService.isFirebaseInitialized) {
            try {
              final doc = await FirebaseFirestore.instance.collection('coaches').doc(user.uid).get();
              isProfileComplete = doc.exists;
            } catch (_) {
              isProfileComplete = false;
            }
          } else {
            isProfileComplete = prefs.getBool('coach_profile_complete_${user.uid}') ?? false;
          }
        }
      }
      role ??= prefs.getString('user_role');

      if (mounted) {
        setState(() {
          _isLoggedIn = prefs.getBool('is_logged_in') ?? (user != null);
          _userRole = role;
          _isProfileComplete = isProfileComplete;
        });
      }
    } catch (_) {}
  }

  void _navigateNext() {
    if (!mounted) return;

    Widget nextScreen = const LoginScreen();
    if (_isLoggedIn) {
      if (_userRole == 'coach') {
        if (!_isProfileComplete) {
          final user = AuthService().currentUser;
          nextScreen = CoachProfileSetupScreen(
            uid: user?.uid ?? 'mock_coach_uid',
            name: user?.displayName ?? 'Dr. Sarah Mitchell',
            email: user?.email ?? '',
            phoneNumber: '',
          );
        } else {
          nextScreen = const ClinicianDashboardScreen();
        }
      } else {
        nextScreen = const MainShell();
      }
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradient Container
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF0FAF8), // Very soft light minty white
                  Color(0xFFD3EFEA), // Soft light teal-mint
                ],
              ),
            ),
          ),

          // 2. Responsive Scattered Watermark Icons
          const _WatermarkBackground(),

          // 3. Custom Canvas Overlapping Wave Drawing at the Bottom
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BottomWavePainter(),
              ),
            ),
          ),

          // 4. Center Logo & Branding Block (Animated)
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo Image
                        Image.asset(
                          'assets/images/Splashscreenlogo.png',
                          width: 280,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 24),

                        // Title Text: Diabetes Prevention Program
                        const Text(
                          'Diabetes Prevention',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF074840), // Dark elegant teal
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'Program',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF074840),
                            letterSpacing: -0.5,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Subtle matching progress indicator
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF32B396)),
                            backgroundColor: const Color(0xFF074840).withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BACKGROUND WATERMARK COMPONENT ──────────────────────────────────────────

class _WatermarkBackground extends StatelessWidget {
  const _WatermarkBackground();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double w = size.width;
    final double h = size.height;

    return Stack(
      children: [
        // Top Left quadrant
        _buildWatermark(Icons.monitor_weight_outlined, 56, w * 0.10, h * 0.08, -0.2),
        _buildWatermark(Icons.water_drop_outlined, 38, w * 0.38, h * 0.10, 0.1),
        _buildWatermark(Icons.spa_outlined, 42, w * 0.05, h * 0.26, -0.4),

        // Top Right quadrant
        _buildWatermark(Icons.eco_outlined, 48, w * 0.70, h * 0.04, 0.3),
        _buildWatermark(Icons.restaurant_outlined, 52, w * 0.78, h * 0.15, -0.1),

        // Middle Left
        _buildWatermark(Icons.directions_walk_rounded, 46, w * 0.04, h * 0.44, 0.25),

        // Middle Right
        _buildWatermark(Icons.monitor_heart_outlined, 54, w * 0.80, h * 0.28, 0.15),
        _buildWatermark(Icons.edit_outlined, 44, w * 0.85, h * 0.41, -0.5),

        // Lower Left
        _buildWatermark(Icons.medication_outlined, 52, w * 0.06, h * 0.60, -0.15),
        _buildWatermark(Icons.grass_outlined, 46, w * 0.05, h * 0.76, 0.35),
        _buildWatermark(Icons.circle_outlined, 40, w * 0.20, h * 0.84, 0.0), // Apple outline shape

        // Lower Right
        _buildWatermark(Icons.shield_outlined, 44, w * 0.74, h * 0.64, 0.2),
        _buildWatermark(Icons.assignment_outlined, 54, w * 0.70, h * 0.78, -0.1),
      ],
    );
  }

  Widget _buildWatermark(IconData icon, double size, double left, double top, double rotation) {
    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: rotation,
        child: Icon(
          icon,
          size: size,
          color: const Color(0x0C0D4F45), // ~4.7% opacity dark teal
        ),
      ),
    );
  }
}

// ─── BOTTOM DOUBLE WAVE PAINTER ──────────────────────────────────────────────

class _BottomWavePainter extends CustomPainter {
  const _BottomWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final double w = size.width;

    // Draw bottom wave 1
    final paint1 = Paint()
      ..color = const Color(0xFFBFECE3).withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, h);
    path1.lineTo(0, h - 55);
    path1.quadraticBezierTo(w * 0.3, h - 90, w * 0.6, h - 45);
    path1.quadraticBezierTo(w * 0.8, h - 15, w, h - 65);
    path1.lineTo(w, h);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Draw bottom wave 2 (overlapping)
    final paint2 = Paint()
      ..color = const Color(0xFFBFECE3).withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, h);
    path2.lineTo(0, h - 35);
    path2.quadraticBezierTo(w * 0.4, h - 15, w * 0.75, h - 60);
    path2.quadraticBezierTo(w * 0.9, h - 75, w, h - 40);
    path2.lineTo(w, h);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _BottomWavePainter oldDelegate) => false;
}


