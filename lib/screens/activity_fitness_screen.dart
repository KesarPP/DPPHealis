import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_stats.dart';
import '../models/ndpp_constants.dart';
import '../services/health_sync_service.dart';
import '../services/activity_metrics_engine.dart';
import '../services/health_connect_service.dart';
import '../widgets/activity_header.dart';
import '../widgets/hero_banner.dart';
import '../widgets/goal_journey.dart';
import '../widgets/today_activity_score.dart';
import '../widgets/overview_cards.dart';
import '../models/activity_log.dart';
import '../repositories/activity_log_repository_impl.dart';
import '../services/firestore_activity_log_service.dart';
import '../widgets/weekly_progress.dart';
import '../widgets/activity_timeline_widget.dart';
import '../widgets/motivation_section.dart';
import '../widgets/activity_feed.dart';
import '../widgets/activities_logged_widget.dart';
import '../data/gelato_theme.dart';

enum HealthConnectOnboardingState {
  notInstalled, // State 1
  permissionsMissing, // State 2
  fitnessAppMissing, // State 3
  waitingForFirstActivity, // State 4
  syncing, // State 5
  connected, // State 6
}

class ActivityFitnessScreen extends StatefulWidget {
  const ActivityFitnessScreen({super.key});

  @override
  State<ActivityFitnessScreen> createState() => _ActivityFitnessScreenState();
}

class _ActivityFitnessScreenState extends State<ActivityFitnessScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  late final HealthSyncService _healthSync;
  final _activityLogRepository = ActivityLogRepositoryImpl(
    FirestoreActivityLogService(),
  );
  List<ActivityLog> _todayLogs = [];
  bool _isLoadingLogs = false;
  String? _logsError;
  ActivityStats? _stats;
  DateTime? _lastSyncTime;
  bool _isLoading = true;

  // State-driven UI state
  HealthConnectOnboardingState _onboardingState = HealthConnectOnboardingState.syncing;

  // Simulation fallback for Windows/web testing (strictly UI state, no static activity data)
  static bool _simulatedInstalled = true;
  static bool _simulatedPermissions = false;
  bool _showAppsAndPermissions = false;

  Timer? _backgroundPollingTimer;

  // Fitness app package mapping
  static const Map<String, String> _appPackages = {
    'Google Fit (Recommended)': 'com.google.android.apps.fitness',
    'Samsung Health': 'com.sec.android.app.shealth',
    'Fitbit': 'com.fitbit.FitbitMobile',
    'Garmin Connect': 'com.garmin.android.apps.connectmobile',
    'Mi Fitness': 'com.xiaomi.wearable',
  };

  Map<String, bool> _installedApps = {};
  bool _sessionState3Dismissed = false;

  // Engine metrics
  int _dailyScore = 0;
  String _dailyScoreFeedback = "Loading...";
  int _weeklyTargetMinutes = 150;
  int _currentWeeklyMinutes = 0;
  List<DailyAggregate> _pastDays = [];
  int _programWeek = 8;

  ActivityStats get _activityStats {
    final s = _stats;
    int steps = s?.steps ?? 0;
    double dist = s?.distance ?? 0.0;
    double cals = s?.calories ?? 0.0;
    int mins = s?.activeMinutes ?? 0;
    int wSteps = s?.weeklySteps ?? 0;

    if (wSteps == 0) {
      wSteps = steps * 7;
    }
    return ActivityStats(
      steps: steps,
      distance: dist,
      calories: cals,
      activeMinutes: mins,
      weeklySteps: wSteps,
    );
  }

  int get _effectiveWeeklyMinutes => _currentWeeklyMinutes;

  int get _effectiveDailyScore => _dailyScore;

  List<DailyAggregate> get _sanitizedPastDays {
    return _pastDays;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _healthSync = HealthSyncService();
    _initCacheAndFlow();
  }

  Timer? _bg15MinSyncTimer;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundPollingTimer?.cancel();
    _bg15MinSyncTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_onboardingState != HealthConnectOnboardingState.connected) {
        _checkStateAndProceed(isSilent: true);
      }
      if (_onboardingState == HealthConnectOnboardingState.fitnessAppMissing) {
        _checkInstalledApps();
      }
    }
  }

  Future<void> _loadTodayLogs() async {
    setState(() { _isLoadingLogs = true; _logsError = null; });
    try {
      final logs = await _activityLogRepository.getTodayActivityLogs();
      if (mounted) setState(() { _todayLogs = logs; _isLoadingLogs = false; });
    } catch (e) {
      if (mounted) setState(() { _logsError = "Couldn't load today's activities"; _isLoadingLogs = false; });
    }
  }

  Future<void> _loadActivityData() async {
    await Future.wait([
      _checkStateAndProceed(isSilent: false),
      _loadTodayLogs(),
    ]);
  }

  Future<void> _initCacheAndFlow() async {
    final prefs = await SharedPreferences.getInstance();
    final bool purgedV5 = prefs.getBool('hc_demo_purged_v5') ?? false;
    if (!purgedV5) {
      final keys = prefs.getKeys().toList();
      for (var k in keys) {
        if (k.startsWith('hc_persist_') || k.startsWith('hc_cached_')) {
          await prefs.remove(k);
        }
      }
      await prefs.setBool('hc_demo_purged_v5', true);
    }
    await prefs.remove('hc_state3_dismissed');

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 29));
    List<DailyAggregate> initial30Days = [];
    try {
      initial30Days = await _healthSync.getStatsForInterval(startTime: thirtyDaysAgo, endTime: now).timeout(const Duration(seconds: 4));
    } catch (_) {}

    if (initial30Days.isEmpty || initial30Days.every((d) => d.totalSteps == 0 && d.totalActiveMinutes == 0)) {
      initial30Days = _generateSyncedDefaultAggregates(now);
    }

    if (mounted) {
      setState(() {
        _pastDays = initial30Days;
        final today = initial30Days.last;
        final last7Days = initial30Days.length > 7 ? initial30Days.sublist(initial30Days.length - 7) : initial30Days;
        _stats = ActivityStats(
          steps: today.totalSteps,
          distance: today.totalDistance,
          calories: today.totalCalories,
          activeMinutes: today.totalActiveMinutes,
          weeklySteps: last7Days.fold<int>(0, (sum, item) => sum + item.totalSteps),
        );
        _currentWeeklyMinutes = last7Days.fold<int>(0, (sum, item) => sum + item.qualifyingActiveMinutes);
        _dailyScore = ActivityMetricsEngine.calculateActivityScore(today, _programWeek);
        _dailyScoreFeedback = ActivityMetricsEngine.getDailyScoreFeedback(
          _dailyScore,
          _currentWeeklyMinutes,
          NdppConstants.getWeeklyTargetForWeek(_programWeek),
        );
        _weeklyTargetMinutes = NdppConstants.getWeeklyTargetForWeek(_programWeek);
        _isLoading = false;
      });
    }

    _loadTodayLogs();
    _checkStateAndProceed(isSilent: true);
    _startBackgroundPolling();
  }

  void _startBackgroundPolling() {
    _backgroundPollingTimer?.cancel();
    _bg15MinSyncTimer?.cancel();
    _bg15MinSyncTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      if (!mounted) return;
      if (_onboardingState == HealthConnectOnboardingState.connected) {
        _checkStateAndProceed(isSilent: true);
      }
    });
  }

  Future<void> _checkInstalledApps() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    Map<String, bool> updated = {};
    for (var entry in _appPackages.entries) {
      try {
        final bool inst = await const MethodChannel('com.example.dpp_app/app_launcher')
            .invokeMethod('isAppInstalled', {'packageId': entry.value}) ?? false;
        updated[entry.key] = inst;
      } catch (_) {
        updated[entry.key] = false;
      }
    }
    if (mounted) {
      setState(() {
        _installedApps = updated;
      });
    }
  }

  bool _isCheckingState = false;

  Future<void> _checkStateAndProceed({required bool isSilent}) async {
    if (_isCheckingState) return;
    _isCheckingState = true;
    try {
      await _doCheckStateAndProceed(isSilent: isSilent);
    } finally {
      _isCheckingState = false;
    }
  }

  Future<void> _doCheckStateAndProceed({required bool isSilent}) async {
    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

    bool available = false;
    if (isAndroid) {
      try {
        available = await HealthConnectService().isHealthConnectAvailable().timeout(const Duration(seconds: 3));
      } catch (_) {}
    } else {
      available = _simulatedInstalled;
    }

    if (!available) {
      if (mounted && _onboardingState != HealthConnectOnboardingState.notInstalled) {
        setState(() {
          _onboardingState = HealthConnectOnboardingState.notInstalled;
          _isLoading = false;
        });
      }
      return;
    }

    bool hasPerms = false;
    if (isAndroid) {
      try {
        hasPerms = await _healthSync.hasPermissions().timeout(const Duration(seconds: 3));
      } catch (_) {}
    } else {
      hasPerms = _simulatedPermissions;
    }

    if (!hasPerms) {
      if (!isSilent) {
        try {
          hasPerms = await _healthSync.requestPermissions().timeout(const Duration(seconds: 15));
        } catch (_) {}
      }
      if (!hasPerms) {
        if (mounted && _onboardingState != HealthConnectOnboardingState.permissionsMissing) {
          setState(() {
            _onboardingState = HealthConnectOnboardingState.permissionsMissing;
            _isLoading = false;
          });
        }
        return;
      }
    }

    // Permissions granted! Fetch real live activity stats strictly from Health Connect.
    // ZERO static or mock data is generated.
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 29));
    List<DailyAggregate> pastDays = [];
    try {
      pastDays = await _healthSync.getStatsForInterval(startTime: thirtyDaysAgo, endTime: now).timeout(const Duration(seconds: 4));
    } catch (_) {}

    if (pastDays.isEmpty || pastDays.every((d) => d.totalSteps == 0 && d.totalActiveMinutes == 0)) {
      pastDays = _generateSyncedDefaultAggregates(now);
    }

    final today = pastDays.last;
    final bool hasValidData = pastDays.isNotEmpty;

    if (hasValidData) {
      final last7Days = pastDays.length > 7 ? pastDays.sublist(pastDays.length - 7) : pastDays;
      int currentMins = 0;
      int weeklySteps = 0;
      for (var day in last7Days) {
        currentMins += day.qualifyingActiveMinutes;
        weeklySteps += day.totalSteps;
      }

      final stats = ActivityStats(
        steps: today.totalSteps,
        distance: today.totalDistance,
        calories: today.totalCalories,
        activeMinutes: today.totalActiveMinutes,
        weeklySteps: weeklySteps,
      );

      int score = ActivityMetricsEngine.calculateActivityScore(today, _programWeek);
      String feedback = ActivityMetricsEngine.getDailyScoreFeedback(
        score,
        currentMins,
        NdppConstants.getWeeklyTargetForWeek(_programWeek),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hc_cached_connected', true);
      await prefs.setInt('hc_cached_steps', stats.steps);
      await prefs.setDouble('hc_cached_distance', stats.distance);
      await prefs.setDouble('hc_cached_calories', stats.calories);
      await prefs.setInt('hc_cached_active_mins', stats.activeMinutes);
      await prefs.setInt('hc_cached_weekly_steps', stats.weeklySteps);
      await prefs.setInt('hc_cached_score', score);
      await prefs.setString('hc_cached_feedback', feedback);
      await prefs.setInt('hc_cached_weekly_mins', currentMins);

      if (mounted) {
        if (_onboardingState != HealthConnectOnboardingState.connected && !isSilent) {
          setState(() {
            _onboardingState = HealthConnectOnboardingState.syncing;
            _isLoading = false;
          });
          await Future.delayed(const Duration(milliseconds: 2200));
        }

        if (mounted) {
          setState(() {
            _lastSyncTime = DateTime.now();
            _stats = stats;
            _pastDays = pastDays;
            _currentWeeklyMinutes = currentMins;
            _weeklyTargetMinutes = NdppConstants.getWeeklyTargetForWeek(_programWeek);
            _dailyScore = score;
            _dailyScoreFeedback = feedback;
            _onboardingState = HealthConnectOnboardingState.connected;
            _isLoading = false;
          });
        }
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final bool cachedConn = prefs.getBool('hc_cached_connected') ?? false;

      bool hasAnyHistory = false;
      for (var d in pastDays) {
        if (d.totalSteps > 0 || d.totalActiveMinutes > 0) hasAnyHistory = true;
      }

      if (_sessionState3Dismissed && (hasAnyHistory || cachedConn)) {
        await prefs.setBool('hc_cached_connected', true);
        final int cSteps = prefs.getInt('hc_cached_steps') ?? 0;

        int stepsToUse = today.totalSteps;
        double distToUse = today.totalDistance;
        double calsToUse = today.totalCalories;
        int minsToUse = today.totalActiveMinutes;

        await prefs.setInt('hc_cached_steps', stepsToUse);
        await prefs.setDouble('hc_cached_distance', distToUse);
        await prefs.setDouble('hc_cached_calories', calsToUse);
        await prefs.setInt('hc_cached_active_mins', minsToUse);
        await prefs.setInt('hc_cached_weekly_steps', pastDays.fold<int>(0, (sum, item) => sum + item.totalSteps));

        if (pastDays.isNotEmpty) {
          final lastAgg = pastDays.last;
          final int effMins = max(lastAgg.qualifyingActiveMinutes, minsToUse);
          pastDays[pastDays.length - 1] = DailyAggregate(
            date: lastAgg.date,
            totalSteps: stepsToUse,
            totalDistance: distToUse,
            totalCalories: calsToUse,
            totalActiveMinutes: minsToUse,
            qualifyingActiveMinutes: effMins,
            isActiveDay: effMins >= 10 || stepsToUse >= 3000,
            coreSessions: lastAgg.coreSessions,
            lifestyleSessions: lastAgg.lifestyleSessions,
          );
        }

        final int weeklyMinsToUse = pastDays.fold<int>(0, (sum, item) => sum + max(item.qualifyingActiveMinutes, item.totalActiveMinutes));
        final int scoreToUse = prefs.getInt('hc_cached_score') ?? 85;
        final String feedbackToUse = prefs.getString('hc_cached_feedback') ?? "Great job staying active today!";

        if (mounted) {
          setState(() {
            _lastSyncTime = DateTime.now();
            _stats = ActivityStats(
              steps: stepsToUse,
              distance: distToUse,
              calories: calsToUse,
              activeMinutes: minsToUse,
              weeklySteps: pastDays.fold<int>(0, (sum, item) => sum + item.totalSteps),
            );
            _pastDays = pastDays;
            _currentWeeklyMinutes = weeklyMinsToUse;
            _weeklyTargetMinutes = NdppConstants.getWeeklyTargetForWeek(_programWeek);
            _dailyScore = scoreToUse;
            _dailyScoreFeedback = feedbackToUse;
            _onboardingState = HealthConnectOnboardingState.connected;
            _isLoading = false;
          });
        }
        return;
      }

      HealthConnectOnboardingState nextState;
      if (!_sessionState3Dismissed) {
        nextState = HealthConnectOnboardingState.fitnessAppMissing;
        _checkInstalledApps();
      } else if (!hasAnyHistory) {
        nextState = HealthConnectOnboardingState.waitingForFirstActivity;
      } else {
        nextState = HealthConnectOnboardingState.connected;
      }

      if (mounted && _onboardingState != nextState) {
        setState(() {
          _onboardingState = nextState;
          _isLoading = false;
        });
      }
    }
  }

  List<DailyAggregate> _generateSyncedDefaultAggregates(DateTime now) {
    List<DailyAggregate> list = [];
    for (int i = 29; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      list.add(DailyAggregate(
        date: d,
        totalSteps: 0,
        totalDistance: 0.0,
        totalCalories: 0.0,
        totalActiveMinutes: 0,
        qualifyingActiveMinutes: 0,
        isActiveDay: false,
        coreSessions: const [],
        lifestyleSessions: const [],
      ));
    }
    return list;
  }

  Future<void> _onInstallTap() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      setState(() {
        _simulatedInstalled = true;
      });
      await _checkStateAndProceed(isSilent: false);
      return;
    }
    try {
      await Health().installHealthConnect();
    } catch (e) {
      debugPrint("Could not launch install: $e");
    }
  }

  Future<void> _onGrantPermissionsTap() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      setState(() {
        _simulatedPermissions = true;
      });
      await _checkStateAndProceed(isSilent: false);
      return;
    }
    setState(() {
      _onboardingState = HealthConnectOnboardingState.syncing;
    });
    bool granted = await _healthSync.hasPermissions();
    if (!granted) {
      granted = await _healthSync.requestPermissions();
    }
    if (granted) {
      await _checkStateAndProceed(isSilent: false);
    } else {
      final hasPerms = await _healthSync.hasPermissions();
      if (hasPerms) {
        await _checkStateAndProceed(isSilent: false);
      } else if (mounted) {
        setState(() {
          _onboardingState = HealthConnectOnboardingState.permissionsMissing;
        });
      }
    }
  }

  Future<void> _onConnectAppTap(String appName) async {
    final pkg = _appPackages[appName];
    if (pkg == null) return;

    _showAppConnectInstructionModal(appName, pkg);
  }

  void _showAppConnectInstructionModal(String appName, String packageId) {
    final cleanName = appName.replaceAll(' (Recommended)', '');
    final bool isGoogleFit = packageId == 'com.google.android.apps.fitness';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, spreadRadius: 5)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: GelatoTheme.orange.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.sync_rounded, color: GelatoTheme.orangeDark, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect $cleanName',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GelatoTheme.textDark),
                      ),
                      Text(
                        'One quick step inside the app',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              isGoogleFit
                  ? 'When $cleanName opens, look for this exact card on your home tab and tap "Get started":'
                  : 'When $cleanName opens, go to its settings menu and turn on "Sync with Health Connect":',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: GelatoTheme.textDark, height: 1.4),
            ),
            const SizedBox(height: 16),
            if (isGoogleFit) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF202124),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sync Fit with Health Connect',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Share stats between Fit and your other apps, like your calories, heart rate and body measurements',
                                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                          child: const Icon(Icons.health_and_safety, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Get started',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF8AB4F8)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: GelatoTheme.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.settings_suggest_rounded, color: GelatoTheme.textDark, size: 32),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Look for Health Connect permission settings inside $cleanName to enable syncing.',
                        style: const TextStyle(fontSize: 13, color: GelatoTheme.textDark, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _sessionState3Dismissed = true;
                    _onboardingState = HealthConnectOnboardingState.waitingForFirstActivity;
                  });
                  try {
                    const MethodChannel('com.example.dpp_app/app_launcher')
                        .invokeMethod('launchOrInstallApp', {'packageId': packageId});
                  } catch (e) {
                    debugPrint('Launch error: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GelatoTheme.orangeDark,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Open $cleanName Now', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_new_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDismissState3Tap() {
    if (mounted) {
      setState(() {
        _sessionState3Dismissed = true;
        _showAppsAndPermissions = false;
        if (_onboardingState == HealthConnectOnboardingState.fitnessAppMissing) {
          _onboardingState = HealthConnectOnboardingState.waitingForFirstActivity;
        }
      });
    }
  }

  // --- UI COMPONENTS FOR ONBOARDING STATES ---

  Widget _buildState1Card() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GelatoTheme.pink.withValues(alpha: 0.25), Colors.white],
          stops: const [0.0, 0.55],
        ),
      ),
      child: Column(
        children: [
          const _FloatingIllustrationBox(
            color: Color(0xFFE3F2FD),
            icon: Icons.favorite_rounded,
            iconColor: Color(0xFF1E88E5),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GelatoTheme.greenDark.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'HEALTH CONNECT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: GelatoTheme.greenDark,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Connect Your Health Data',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Automatically track your daily activity, calories burned, steps, distance travelled and active minutes using Health Connect.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildPremiumButton(
            text: 'Install Health Connect',
            icon: Icons.open_in_new_rounded,
            gradientColors: const [GelatoTheme.pink, GelatoTheme.orange],
            onTap: _onInstallTap,
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildBadgeItem(Icons.shop_rounded, 'Google Play'),
              _buildBadgeItem(Icons.security_rounded, 'Secure & Private'),
              _buildBadgeItem(Icons.verified_rounded, 'Recommended by Google'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildState2Card() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GelatoTheme.orange.withValues(alpha: 0.25), Colors.white],
          stops: const [0.0, 0.55],
        ),
      ),
      child: Column(
        children: [
          const _FloatingIllustrationBox(
            color: Color(0xFFFFF3E0),
            icon: Icons.shield_rounded,
            iconColor: Color(0xFFFB8C00),
          ),
          const SizedBox(height: 20),
          const Text(
            'Allow Activity Access',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const Text(
            'To personalise your health journey, DPP needs permission to securely read:\n\n• Steps\n• Distance\n• Calories Burned\n• Active Minutes',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildPremiumButton(
            text: 'Grant Permissions',
            icon: Icons.lock_open_rounded,
            gradientColors: const [Color(0xFFFFB74D), Color(0xFFFF8A65)],
            onTap: _onGrantPermissionsTap,
          ),
        ],
      ),
    );
  }

  Widget _buildState3Card() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const _FloatingIllustrationBox(
            color: Color(0xFFF3E5F5),
            icon: Icons.fitness_center_rounded,
            iconColor: GelatoTheme.purpleDark,
          ),
          const SizedBox(height: 20),
          const Text(
            'No Activity Data Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const Text(
            'Health Connect is connected successfully, but no fitness data has been detected.\n\nTo automatically track your daily activity, connect one of these supported fitness apps.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Recommended Google Fit
          _buildRecommendationCard(
            appName: 'Google Fit (Recommended)',
            desc: 'Official Google activity tracker',
            icon: Icons.favorite_rounded,
            iconColor: Colors.redAccent,
            isRecommended: true,
          ),
          const SizedBox(height: 12),
          _buildRecommendationCard(
            appName: 'Samsung Health',
            desc: 'Seamless Galaxy tracking',
            icon: Icons.monitor_heart_rounded,
            iconColor: Colors.blueAccent,
            isRecommended: false,
          ),
          const SizedBox(height: 12),
          _buildRecommendationCard(
            appName: 'Fitbit',
            desc: 'Wearable health & fitness',
            icon: Icons.watch_rounded,
            iconColor: Colors.teal,
            isRecommended: false,
          ),
          const SizedBox(height: 12),
          _buildRecommendationCard(
            appName: 'Garmin Connect',
            desc: 'Advanced sport analytics',
            icon: Icons.directions_run_rounded,
            iconColor: Colors.orange,
            isRecommended: false,
          ),
          const SizedBox(height: 12),
          _buildRecommendationCard(
            appName: 'Mi Fitness',
            desc: 'Xiaomi smart band sync',
            icon: Icons.track_changes_rounded,
            iconColor: Colors.deepPurpleAccent,
            isRecommended: false,
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _onDismissState3Tap,
            child: const Text(
              'Continue Without Connecting',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required String appName,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required bool isRecommended,
  }) {
    final bool isInstalled = _installedApps[appName] ?? false;
    const String ctaText = 'Open';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRecommended ? const Color(0xFFFFF0F5) : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRecommended ? GelatoTheme.pinkDark : Colors.black12,
          width: isRecommended ? 2.0 : 1.0,
        ),
        boxShadow: isRecommended
            ? [BoxShadow(color: GelatoTheme.pink.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.2),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isRecommended ? FontWeight.w900 : FontWeight.w700,
                    color: GelatoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _onConnectAppTap(appName),
            style: ElevatedButton.styleFrom(
              backgroundColor: !isInstalled && isRecommended ? GelatoTheme.pinkDark : Colors.white,
              foregroundColor: !isInstalled && isRecommended ? Colors.white : GelatoTheme.textDark,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.black, width: 1.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ctaText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: !isInstalled && isRecommended ? Colors.white : GelatoTheme.textDark,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 14,
                  color: !isInstalled && isRecommended ? Colors.white : GelatoTheme.textDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildState4Card() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF0E5),
            Color(0xFFF3E5F5),
            Color(0xFFE8F5E9),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(color: GelatoTheme.orange.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 4),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 76,
                  height: 76,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(GelatoTheme.orangeDark),
                  ),
                ),
                SizedBox(
                  width: 58,
                  height: 58,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    value: 0.75,
                    valueColor: AlwaysStoppedAnimation<Color>(GelatoTheme.pink),
                    backgroundColor: GelatoTheme.pink.withValues(alpha: 0.15),
                  ),
                ),
                const Icon(Icons.favorite_rounded, color: GelatoTheme.pinkDark, size: 28),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Syncing Your Activity...',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            "We're live-checking Health Connect for your synced fitness records. Take a few steps or check back in a moment!",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A4A4A),
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: GelatoTheme.orange.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.local_fire_department_rounded, color: GelatoTheme.orangeDark, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    '"Small movements today lead to massive health breakthroughs tomorrow. Keep going!"',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: GelatoTheme.textDark,
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF202124),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF81C995)),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'LIVE CHECKING HEALTH CONNECT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey[200], letterSpacing: 0.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildState5Card() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 35,
            offset: const Offset(0, 12),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF3E0),
            Color(0xFFFCE4EC),
            Color(0xFFE8F5E9),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF202124),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF81C995),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'HEALTH CONNECT LIVE SYNC',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: GelatoTheme.orangeDark.withValues(alpha: 0.3),
                  blurRadius: 25,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const SizedBox(
                  width: 88,
                  height: 88,
                  child: CircularProgressIndicator(
                    strokeWidth: 4.5,
                    valueColor: AlwaysStoppedAnimation<Color>(GelatoTheme.orangeDark),
                  ),
                ),
                SizedBox(
                  width: 68,
                  height: 68,
                  child: CircularProgressIndicator(
                    strokeWidth: 4.5,
                    value: 0.8,
                    valueColor: const AlwaysStoppedAnimation<Color>(GelatoTheme.pinkDark),
                    backgroundColor: GelatoTheme.pink.withValues(alpha: 0.2),
                  ),
                ),
                const _SpinningSyncIcon(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Calibrating Activity & Fitness',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Syncing your steps, calories, and active minutes cleanly before revealing your personalized dashboard.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: GelatoTheme.orangeDark.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: GelatoTheme.orange.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, color: GelatoTheme.orangeDark, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MOTIVATIONAL BOOSTER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.orangeDark,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '"Every step you take today builds the strength and vitality for tomorrow\'s breakthroughs. Stay consistent!"',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: GelatoTheme.textDark,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 220,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(GelatoTheme.greenDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[800]),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildPremiumButton({
    required String text,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textDark,
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 18, color: GelatoTheme.textDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return Column(
        key: const ValueKey('init_loading'),
        children: [
          // const HeroBanner(), // Stashed for now
          const SizedBox(height: 16),
          _buildState5Card(),
        ],
      );
    }

    if (_showAppsAndPermissions) {
      return Column(
        key: const ValueKey('manage_apps_and_permissions'),
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Connected Apps & Permissions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GelatoTheme.textDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => setState(() => _showAppsAndPermissions = false),
                  icon: const Icon(Icons.close_rounded, color: GelatoTheme.textDark),
                  label: const Text('Back to Dashboard', style: TextStyle(fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildState3Card(),
          const SizedBox(height: 24),
        ],
      );
    }

    if (_onboardingState != HealthConnectOnboardingState.connected) {
      Widget card;
      switch (_onboardingState) {
        case HealthConnectOnboardingState.notInstalled:
          card = _buildState1Card();
          break;
        case HealthConnectOnboardingState.permissionsMissing:
        case HealthConnectOnboardingState.fitnessAppMissing:
          card = _buildState3Card();
          break;
        case HealthConnectOnboardingState.waitingForFirstActivity:
          card = _buildState4Card();
          break;
        case HealthConnectOnboardingState.syncing:
          card = _buildState5Card();
          break;
        case HealthConnectOnboardingState.connected:
          card = const SizedBox.shrink();
          break;
      }
      return Column(
        key: ValueKey(_onboardingState.name),
        children: [
          // const HeroBanner(), // Stashed for now
          const SizedBox(height: 16),
          card,
          const SizedBox(height: 16),
        ],
      );
    }

    // STATE 6: CONNECTED - REVEAL DASHBOARD IN REQUESTED ORDER
    return Column(
      key: const ValueKey('connected_dashboard'),
      children: [
        // const HeroBanner(), // Stashed for now
        const SizedBox(height: 14),
        // 1. Today's Activity Score
        TodayActivityScore(
          score: _effectiveDailyScore,
          feedbackText: _dailyScoreFeedback,
        ),
        const SizedBox(height: 14),
        // 2. Journey to Your Goal
        GoalJourney(
          currentMinutes: _effectiveWeeklyMinutes,
          goalMinutes: _weeklyTargetMinutes,
        ),
        const SizedBox(height: 14),
        // 3. Today's Overview
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: GelatoTheme.cardRadius,
            border: GelatoTheme.cardBorder,
            boxShadow: GelatoTheme.cardShadow,
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart_rounded, color: GelatoTheme.purpleDark, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Today's Overview",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: GelatoTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OverviewCards(
                stats: _activityStats,
                isConnected: _onboardingState == HealthConnectOnboardingState.connected,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // 4. Streak
        MotivationSection(pastDays: _sanitizedPastDays),
        const SizedBox(height: 14),
        // 5. Activities Logged In
        ActivitiesLoggedWidget(
          pastDays: _sanitizedPastDays,
          isConnected: _onboardingState == HealthConnectOnboardingState.connected,
          onConnectGoogleFit: () => _checkStateAndProceed(isSilent: false),
        ),
        const SizedBox(height: 14),
        // 6. Weekly Progress
        WeeklyProgress(pastDays: _sanitizedPastDays, programWeek: _programWeek),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.orange.withValues(alpha: 0.4),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DotsPainter(color: Colors.black87.withValues(alpha: 0.04)),
              ),
            ),
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      ActivityHeader(
                        isConnected: _onboardingState != HealthConnectOnboardingState.notInstalled &&
                            _onboardingState != HealthConnectOnboardingState.permissionsMissing,
                        lastSyncTime: _lastSyncTime,
                        onSyncTap: () => _loadActivityData(),
                      ),
                      if ((_onboardingState != HealthConnectOnboardingState.connected && _onboardingState != HealthConnectOnboardingState.syncing) || _showAppsAndPermissions) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: InkWell(
                            onTap: () => setState(() => _showAppsAndPermissions = !_showAppsAndPermissions),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: GelatoTheme.orangeDark.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: GelatoTheme.orange.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.fitness_center_rounded, color: GelatoTheme.orangeDark, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _showAppsAndPermissions ? 'Hide Apps & Permissions' : 'Fitness Apps & Permissions',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: GelatoTheme.textDark,
                                          ),
                                        ),
                                        Text(
                                          _showAppsAndPermissions ? 'Return to your activity dashboard' : 'Manage Google Fit, Samsung Health, Fitbit & permissions',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    _showAppsAndPermissions ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                    color: GelatoTheme.textDark,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _buildMainContent(),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingIllustrationBox extends StatefulWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;

  const _FloatingIllustrationBox({
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<_FloatingIllustrationBox> createState() => _FloatingIllustrationBoxState();
}

class _FloatingIllustrationBoxState extends State<_FloatingIllustrationBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
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
      animation: _floatAnim,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: child,
        );
      },
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(widget.icon, color: widget.iconColor, size: 44),
        ),
      ),
    );
  }
}

class _SpinningSyncIcon extends StatefulWidget {
  const _SpinningSyncIcon();

  @override
  State<_SpinningSyncIcon> createState() => _SpinningSyncIconState();
}

class _SpinningSyncIconState extends State<_SpinningSyncIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Icon(Icons.sync_rounded, color: Color(0xFF009688), size: 44),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color color;
  const _DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double gridSize = 16.0;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x <= size.width; x += gridSize) {
      for (double y = 0; y <= size.height; y += gridSize) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) => oldDelegate.color != color;
}
