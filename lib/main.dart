import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/food_tracking_screen.dart';
import 'screens/activity_fitness_screen.dart';
import 'screens/sessions_screen.dart';
import 'screens/coach_chat_screen.dart';
import 'screens/ai_chatbot_screen.dart';
import 'data/gelato_theme.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/food_notifiers.dart';
import 'services/auth_service.dart';
import 'services/health_connect_service.dart';
import 'services/notification_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
  );
  try {
    final healthService = HealthConnectService();
    await healthService.requestPermissions();
    await healthService.getTodayDistance();
    await healthService.getTodayCalories();
    await healthService.getTodayActiveMinutes();
  } catch (e) {
    print('Health Error: $e');
  }

  await NotificationService().init();
  await NotificationService().requestPermissions();
  runApp(const DPPApp());
}

class DPPApp extends StatelessWidget {
  const DPPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodSearchNotifier()),
        ChangeNotifierProvider(create: (_) => FoodDiaryNotifier()),
      ],
      child: MaterialApp(
        title: 'Diabetes Prevention Program',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

// ─── Main shell with Bottom Navigation ───────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static MainShellState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainShellState>();
  }

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    if (user != null) {
      user.reload().then((_) {
        if (mounted) {
          setState(() {});
        }
      }).catchError((_) {});
      _checkMissingAssessments(user.uid);
      NotificationService().startChatListener();
    }
  }

  Future<void> _checkMissingAssessments(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final hasIdrs = data['hasIdrsResult'] == true;
        final hasGpaq = data['hasGpaqResult'] == true;
        
        AppState.hasIdrsResult = hasIdrs;
        if (hasIdrs) AppState.idrsScore = data['idrsScore'] ?? 0;
        
        AppState.hasGpaqResult = hasGpaq;
        if (hasGpaq) {
          AppState.gpaqMetMinutes = data['gpaqMetMinutes'] ?? 0;
          AppState.gpaqLevel = data['gpaqLevel'] ?? 'Low Activity';
        }

        // Check if past user
        final createdAt = data['createdAt'] as Timestamp?;
        if (createdAt != null) {
          final age = DateTime.now().difference(createdAt.toDate());
          if (age.inHours > 24) { // past user (older than 24 hours)
            if (!hasIdrs || !hasGpaq) {
              final prefs = await SharedPreferences.getInstance();
              final lastNotificationStr = prefs.getString('last_assessment_notification_date');
              final todayStr = DateTime.now().toIso8601String().substring(0, 10);
              
              if (lastNotificationStr != todayStr) {
                await NotificationService().scheduleAssessmentReminder();
                await prefs.setString('last_assessment_notification_date', todayStr);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to check assessments: $e');
    }
  }

  set selectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    FoodTrackingScreen(),
    ActivityFitnessScreen(),
    SessionsScreen(),
    CoachChatScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant_outlined),
      selectedIcon: Icon(Icons.restaurant),
      label: 'Food',
    ),
    NavigationDestination(
      icon: Icon(Icons.directions_run_outlined),
      selectedIcon: Icon(Icons.directions_run),
      label: 'Activity',
    ),
    NavigationDestination(
      icon: Icon(Icons.play_circle_outline),
      selectedIcon: Icon(Icons.play_circle),
      label: 'Sessions',
    ),
    NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble),
      label: 'Coach',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    Color activeTextColor;
    switch (_selectedIndex) {
      case 0:
        indicatorColor = GelatoTheme.pink;
        activeTextColor = GelatoTheme.pinkDark;
        break;
      case 1:
        indicatorColor = GelatoTheme.green;
        activeTextColor = GelatoTheme.greenDark;
        break;
      case 2:
        indicatorColor = GelatoTheme.orange;
        activeTextColor = GelatoTheme.orangeDark;
        break;
      case 3:
        indicatorColor = GelatoTheme.blue;
        activeTextColor = GelatoTheme.blueDark;
        break;
      case 4:
        indicatorColor = GelatoTheme.purple;
        activeTextColor = GelatoTheme.purpleDark;
        break;
      default:
        indicatorColor = Colors.grey[300]!;
        activeTextColor = Colors.black;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: _selectedIndex < 4
          ? Container(
              margin: const EdgeInsets.only(bottom: 16, right: 8),
              child: AIChatbotButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AiChatbotScreen(),
                    ),
                  );
                },
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: indicatorColor,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: activeTextColor, size: 24);
            }
            return const IconThemeData(color: Color(0xFF64748B), size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontWeight: FontWeight.w900,
                color: activeTextColor,
                fontSize: 12,
              );
            }
            return const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              fontSize: 12,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: _destinations,
        ),
      ),
    );
  }
}

// ─── Custom AI Chatbot Button & Painter ──────────────────────────────────────

class AIChatbotButton extends StatefulWidget {
  final VoidCallback onPressed;
  const AIChatbotButton({super.key, required this.onPressed});

  @override
  State<AIChatbotButton> createState() => _AIChatbotButtonState();
}

class _AIChatbotButtonState extends State<AIChatbotButton> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.92),
        onTapUp: (_) {
          setState(() => _scale = 1.0);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          child: SizedBox(
            width: 76,
            height: 68,
            child: CustomPaint(
              painter: _RobotChatBubblePainter(),
            ),
          ),
        ),
      ),
    );
  }
}

class _RobotChatBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Main bubble and tail combined path
    final bubblePath = Path()
      ..addRRect(RRect.fromLTRBR(0, 0, w, h * 0.88, Radius.circular(w * 0.44)));
    
    final tailPath = Path();
    tailPath.moveTo(w * 0.65, h * 0.85);
    tailPath.quadraticBezierTo(w * 0.80, h * 0.95, w * 0.88, h);
    tailPath.quadraticBezierTo(w * 0.82, h * 0.90, w * 0.85, h * 0.75);
    tailPath.close();

    final combinedPath = Path.combine(PathOperation.union, bubblePath, tailPath);

    // Draw shadow
    canvas.drawShadow(combinedPath, Colors.black, 6.0, true);

    // Fill bubble
    final bgPaint = Paint()
      ..color = const Color(0xFFDCCCEC)
      ..style = PaintingStyle.fill;
    canvas.drawPath(combinedPath, bgPaint);

    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFFBCA6D7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(combinedPath, borderPaint);

    // Glossy highlight near top right
    final highlightPath = Path();
    highlightPath.addArc(Rect.fromLTRB(w * 0.1, h * 0.05, w * 0.9, h * 0.83), -1.3, 0.7);
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.04;
    canvas.drawPath(highlightPath, highlightPaint);

    // Robot center
    final bh = h * 0.88;
    final center = Offset(w * 0.5, bh * 0.5);

    final headWidth = w * 0.58;
    final headHeight = bh * 0.60;
    final headRect = Rect.fromCenter(center: center, width: headWidth, height: headHeight);

    final earWidth = w * 0.07;
    final earHeight = bh * 0.32;
    final leftEar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx - headWidth * 0.5 - earWidth * 0.3, center.dy), width: earWidth, height: earHeight),
      Radius.circular(earWidth * 0.5),
    );
    final rightEar = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx + headWidth * 0.5 + earWidth * 0.3, center.dy), width: earWidth, height: earHeight),
      Radius.circular(earWidth * 0.5),
    );

    final robotDarkPaint = Paint()
      ..color = const Color(0xFF4A1E63)
      ..style = PaintingStyle.fill;

    final stemPaint = Paint()
      ..color = const Color(0xFF4A1E63)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round;

    final leftTip = Offset(center.dx - headWidth * 0.55, center.dy - headHeight * 0.62);
    final rightTip = Offset(center.dx + headWidth * 0.55, center.dy - headHeight * 0.62);

    // Antenna stems
    canvas.drawLine(Offset(center.dx - headWidth * 0.5, center.dy), leftTip, stemPaint);
    canvas.drawLine(Offset(center.dx + headWidth * 0.5, center.dy), rightTip, stemPaint);

    // Antenna balls
    canvas.drawCircle(leftTip, w * 0.025, robotDarkPaint);
    canvas.drawCircle(rightTip, w * 0.025, robotDarkPaint);

    // Earpieces
    canvas.drawRRect(leftEar, robotDarkPaint);
    canvas.drawRRect(rightEar, robotDarkPaint);

    // White outer casing
    final whiteCasingPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final casingRRect = RRect.fromRectAndRadius(headRect, Radius.circular(w * 0.18));
    canvas.drawShadow(Path()..addRRect(casingRRect), Colors.black, 3.0, true);
    canvas.drawRRect(casingRRect, whiteCasingPaint);

    // Dark face screen
    final screenWidth = headWidth * 0.82;
    final screenHeight = headHeight * 0.78;
    final screenRect = Rect.fromCenter(center: center, width: screenWidth, height: screenHeight);
    final screenRRect = RRect.fromRectAndRadius(screenRect, Radius.circular(w * 0.14));
    canvas.drawRRect(screenRRect, robotDarkPaint);

    // Facial features (smiling eyes and mouth)
    final faceFeaturePaint = Paint()
      ..color = const Color(0xFFDCCCEC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    // Left eye
    final leftEyeCenter = Offset(center.dx - screenWidth * 0.22, center.dy - screenHeight * 0.08);
    final eyeWidth = screenWidth * 0.24;
    final eyeHeight = screenHeight * 0.20;

    final leftEyePath = Path();
    leftEyePath.moveTo(leftEyeCenter.dx - eyeWidth * 0.5, leftEyeCenter.dy + eyeHeight * 0.5);
    leftEyePath.quadraticBezierTo(
      leftEyeCenter.dx, leftEyeCenter.dy - eyeHeight * 0.5,
      leftEyeCenter.dx + eyeWidth * 0.5, leftEyeCenter.dy + eyeHeight * 0.5,
    );
    canvas.drawPath(leftEyePath, faceFeaturePaint);

    // Right eye
    final rightEyeCenter = Offset(center.dx + screenWidth * 0.22, center.dy - screenHeight * 0.08);
    final rightEyePath = Path();
    rightEyePath.moveTo(rightEyeCenter.dx - eyeWidth * 0.5, rightEyeCenter.dy + eyeHeight * 0.5);
    rightEyePath.quadraticBezierTo(
      rightEyeCenter.dx, rightEyeCenter.dy - eyeHeight * 0.5,
      rightEyeCenter.dx + eyeWidth * 0.5, rightEyeCenter.dy + eyeHeight * 0.5,
    );
    canvas.drawPath(rightEyePath, faceFeaturePaint);

    // Mouth
    final mouthCenter = Offset(center.dx, center.dy + screenHeight * 0.22);
    final mouthWidth = screenWidth * 0.25;
    final mouthHeight = screenHeight * 0.18;

    final mouthPath = Path();
    mouthPath.moveTo(mouthCenter.dx - mouthWidth * 0.5, mouthCenter.dy - mouthHeight * 0.5);
    mouthPath.quadraticBezierTo(
      mouthCenter.dx, mouthCenter.dy + mouthHeight * 0.5,
      mouthCenter.dx + mouthWidth * 0.5, mouthCenter.dy - mouthHeight * 0.5,
    );
    canvas.drawPath(mouthPath, faceFeaturePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

