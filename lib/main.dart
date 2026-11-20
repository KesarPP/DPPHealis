import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/ai_chatbot_screen.dart';
import 'screens/puzzles_journey_screen.dart';
import 'screens/manuscript_screen.dart';
import 'data/gelato_theme.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/food_notifiers.dart';
import 'providers/journal_launcher.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/session_video_progress_service.dart';
import 'services/ffq_upload_service.dart';
import 'tour/app_tour_controller.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
    );
  } catch (e) {
    debugPrint("Firebase App Check activation error: $e");
  }

  try {
    await AppState.load();
  } catch (e) {
    debugPrint("AppState load error: $e");
  }

  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint("NotificationService init error: $e");
  }

  runApp(const DPPApp());
}

class DPPApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  const DPPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodSearchNotifier()),
        ChangeNotifierProvider(create: (_) => FoodDiaryNotifier()),
        ChangeNotifierProvider(create: (_) => SessionVideoProgressService()),
        ChangeNotifierProvider(create: (_) => JournalLaunchNotifier()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
    return MainShellState.instance ?? context.findAncestorStateOfType<MainShellState>();
  }

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  static MainShellState? instance;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    instance = this;
    NotificationService().requestPermissions();
    final user = AuthService().currentUser;
    if (user != null) {
      user.reload().then((_) {
        if (mounted) {
          setState(() {});
        }
      }).catchError((_) {});
      _checkMissingAssessments(user.uid);
      NotificationService().startChatListener();
      FfqUploadService().retryPendingUpload();
    }
  }

  @override
  void dispose() {
    if (instance == this) instance = null;
    super.dispose();
  }

  Future<void> _checkMissingAssessments(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final hasIdrs = data['hasIdrsResult'] == true;
        final hasGpaq = data['hasGpaqResult'] == true;
        
        AppState.hasIdrsResult = hasIdrs;
        if (hasIdrs) {
          AppState.idrsScore = data['idrsScore'] ?? 0;
          if (data.containsKey('age')) AppState.age = (data['age'] as num).toInt();
          if (data.containsKey('height')) AppState.heightCm = (data['height'] as num).toDouble();
          if (data.containsKey('currentWeight')) AppState.weightKg = (data['currentWeight'] as num).toDouble();
          if (data.containsKey('gender')) AppState.isMan = data['gender'] == 'male';
          if (AppState.heightCm > 0 && AppState.weightKg > 0) {
            AppState.bmi = AppState.weightKg / ((AppState.heightCm / 100) * (AppState.heightCm / 100));
          }
          AppState.save();
        }
        
        AppState.hasGpaqResult = hasGpaq;
        if (hasGpaq) {
          AppState.gpaqMetMinutes = data['gpaqMetMinutes'] ?? 0;
          AppState.gpaqLevel = data['gpaqLevel'] ?? 'Low Activity';
        }

        // Trigger App Tour if IDRS and GPAQ are completed and tour has not been seen
        if (hasIdrs && hasGpaq) {
          _checkAppTour();
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

  Future<void> _checkAppTour() async {
    final hasSeen = await AppTourController.instance.hasSeenTour();
    if (!hasSeen && mounted) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && !AppTourController.instance.isActive) {
          AppTourController.instance.startTour(context);
        }
      });
    }
  }

  set selectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = const [
    PuzzlesJourneyScreen(),
    ManuscriptScreen(),
    DashboardScreen(),
    LeaderboardScreen(),
    AiChatbotScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.extension_outlined),
      selectedIcon: Icon(Icons.extension),
      label: 'Puzzles',
    ),
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined),
      selectedIcon: Icon(Icons.emoji_events),
      label: 'Leaderboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.chat_bubble_outline),
      selectedIcon: Icon(Icons.chat_bubble),
      label: 'Coach',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int navIndex = _selectedIndex == 1 ? 0 : (_selectedIndex > 1 ? _selectedIndex - 1 : _selectedIndex);
    Color indicatorColor;
    Color activeTextColor;
    switch (navIndex) {
      case 0:
        indicatorColor = GelatoTheme.yellow;
        activeTextColor = GelatoTheme.yellowDark;
        break;
      case 1:
        indicatorColor = GelatoTheme.pink;
        activeTextColor = GelatoTheme.pinkDark;
        break;
      case 2:
        indicatorColor = GelatoTheme.blue;
        activeTextColor = GelatoTheme.blueDark;
        break;
      case 3:
        indicatorColor = GelatoTheme.green;
        activeTextColor = GelatoTheme.greenDark;
        break;
      default:
        indicatorColor = Colors.grey[300]!;
        activeTextColor = Colors.black;
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: NavigationBarTheme(
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
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          elevation: 0,
          selectedIndex: navIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index >= 1 ? index + 1 : index);
          },
          destinations: _destinations,
        ),
      ),
      ),
      ),
    );
  }
}


