import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'clinician_dashboard_screen.dart';
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
      if (user != null) {
        role = await authService.getUserRole();
      }
      role ??= prefs.getString('user_role');

      if (mounted) {
        setState(() {
          _isLoggedIn = prefs.getBool('is_logged_in') ?? (user != null);
          _userRole = role;
        });
      }
    } catch (_) {}
  }

  void _navigateNext() {
    if (!mounted) return;

    Widget nextScreen = const LoginScreen();
    if (_isLoggedIn) {
      if (_userRole == 'coach') {
        nextScreen = const ClinicianDashboardScreen();
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
                        // Custom Droplet & Leaf Vector Logo
                        const SizedBox(
                          width: 120,
                          height: 120,
                          child: CustomPaint(
                            painter: _LogoDropletPainter(),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title Text: Diabetes
                        const Text(
                          'Diabetes',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF074840), // Dark elegant teal
                            fontFamily: 'Georgia',
                            letterSpacing: -0.5,
                          ),
                        ),

                        // Title Text: Prevention
                        const Text(
                          'Prevention',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF074840),
                            fontFamily: 'Georgia',
                            letterSpacing: -0.5,
                            height: 0.95,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle Text: — Program —
                        const Text(
                          '— Program —',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF32B396), // Medium mint-green
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 56),

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

// ─── CUSTOM VECTOR LOGO PAINTER (DROPLET & LEAF) ─────────────────────────────

class _LogoDropletPainter extends CustomPainter {
  const _LogoDropletPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final double w = size.width;
    final double h = size.height;

    // Gradient shading for the droplet (cyan-teal gradient matching reference)
    const dropletGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF26A69A), // Teal/cyan
        Color(0xFF00796B), // Dark green-teal
      ],
    );

    // 1. Draw outer droplet shape (outlined)
    final dropletPaint = Paint()
      ..shader = dropletGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dropletPath = Path();
    
    // droplet path points: starts at top center, sweeps down and out, circles back
    dropletPath.moveTo(w * 0.5, h * 0.12);
    dropletPath.cubicTo(
      w * 0.86, h * 0.46,
      w * 0.85, h * 0.88,
      w * 0.5, h * 0.88,
    );
    dropletPath.cubicTo(
      w * 0.15, h * 0.88,
      w * 0.14, h * 0.46,
      w * 0.5, h * 0.12,
    );
    dropletPath.close();
    canvas.drawPath(dropletPath, dropletPaint);

    // 2. Draw inner leaf shape (fill)
    final leafPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Color(0xFF00897B), // Rich dark green-teal
          Color(0xFF26A69A), // Bright minty teal
          Color(0xFF4DB6AC), // Soft light teal
        ],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final leafPath = Path();
    // Leaf starts at bottom center and curves upwards to the right side
    leafPath.moveTo(w * 0.47, h * 0.83);
    // Draw top/left edge of the leaf
    leafPath.quadraticBezierTo(
      w * 0.45, h * 0.60,
      w * 0.70, h * 0.49,
    );
    // Draw bottom/right edge of the leaf
    leafPath.quadraticBezierTo(
      w * 0.73, h * 0.74,
      w * 0.47, h * 0.83,
    );
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);

    // 3. Draw a subtle white-ish leaf vein line
    final veinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final veinPath = Path();
    veinPath.moveTo(w * 0.47, h * 0.83);
    veinPath.quadraticBezierTo(
      w * 0.57, h * 0.71,
      w * 0.70, h * 0.49,
    );
    canvas.drawPath(veinPath, veinPaint);
  }

  @override
  bool shouldRepaint(covariant _LogoDropletPainter oldDelegate) => false;
}
