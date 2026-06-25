import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
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
import '../widgets/weekly_progress.dart';
import '../widgets/activity_feed.dart';
import '../widgets/motivation_section.dart';
import '../data/gelato_theme.dart';

enum HealthConnectOnboardingState {
  notInstalled,
  permissionsMissing,
  syncing,
  connected,
}

class ActivityFitnessScreen extends StatefulWidget {
  const ActivityFitnessScreen({super.key});

  @override
  State<ActivityFitnessScreen> createState() => _ActivityFitnessScreenState();
}

class _ActivityFitnessScreenState extends State<ActivityFitnessScreen> {
  final ScrollController _scrollController = ScrollController();
  late final HealthSyncService _healthSync;
  ActivityStats? _stats;
  bool _isConnected = false;
  DateTime? _lastSyncTime;
  bool _isLoading = true;

  // State-driven UI state
  HealthConnectOnboardingState _onboardingState = HealthConnectOnboardingState.syncing;

  // Engine metrics
  int _dailyScore = 0;
  String _dailyScoreFeedback = "Loading...";
  int _weeklyTargetMinutes = 150;
  int _currentWeeklyMinutes = 0;
  List<DailyAggregate> _pastDays = [];
  int _programWeek = 6;

  ActivityStats get _activityStats {
    return _stats ?? ActivityStats.empty();
  }

  @override
  void initState() {
    super.initState();
    _healthSync = HealthSyncService();
    _initFlow();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initFlow() async {
    if (mounted) {
      setState(() {
        _onboardingState = HealthConnectOnboardingState.syncing;
      });
    }

    bool available = false;
    try {
      available = await HealthConnectService().isHealthConnectAvailable().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('isHealthConnectAvailable error: $e');
    }

    bool hasPerms = false;
    if (available) {
      try {
        hasPerms = await _healthSync.hasPermissions().timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('hasPermissions error: $e');
      }
    }

    HealthConnectOnboardingState targetState = HealthConnectOnboardingState.connected;
    if (!available) {
      targetState = HealthConnectOnboardingState.notInstalled;
    } else if (!hasPerms) {
      targetState = HealthConnectOnboardingState.permissionsMissing;
    }

    await _loadActivityData(targetOnboardingState: targetState);
  }

  Future<void> _loadActivityData({bool forceRefresh = false, HealthConnectOnboardingState? targetOnboardingState}) async {
    try {
      if (mounted && _onboardingState != HealthConnectOnboardingState.connected && targetOnboardingState == null) {
        setState(() {
          _onboardingState = HealthConnectOnboardingState.syncing;
          _isLoading = true;
        });
      }

      bool connected = false;
      try {
        connected = await HealthConnectService().isHealthConnectAvailable().timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('HealthConnect availability check failed: $e');
      }

      List<DailyAggregate> pastDays = [];
      try {
        pastDays = await _healthSync.getLast7DaysStats().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('HealthSync getLast7DaysStats failed or timed out: $e');
      }

      if (pastDays.isEmpty) {
        final now = DateTime.now();
        for (int i = 6; i >= 0; i--) {
          pastDays.add(DailyAggregate.empty(now.subtract(Duration(days: i))));
        }
      }

      int currentMins = 0;
      int weeklySteps = 0;
      for (var day in pastDays) {
        currentMins += day.qualifyingActiveMinutes;
        weeklySteps += day.totalSteps;
      }

      final today = pastDays.isNotEmpty ? pastDays.last : DailyAggregate.empty(DateTime.now());

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

      if (mounted) {
        setState(() {
          _isConnected = connected;
          _lastSyncTime = DateTime.now();
          _stats = stats;
          _pastDays = pastDays;
          _currentWeeklyMinutes = currentMins;
          _weeklyTargetMinutes = NdppConstants.getWeeklyTargetForWeek(_programWeek);
          _dailyScore = score;
          _dailyScoreFeedback = feedback;
          _onboardingState = targetOnboardingState ?? (connected ? HealthConnectOnboardingState.connected : HealthConnectOnboardingState.notInstalled);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('_loadActivityData overall error: $e');
      if (mounted) {
        setState(() {
          _onboardingState = targetOnboardingState ?? HealthConnectOnboardingState.connected;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onInstallTap() async {
    try {
      await Health().installHealthConnect();
    } catch (e) {
      debugPrint("Could not launch install: $e");
    }
  }

  Future<void> _onGrantPermissionsTap() async {
    setState(() {
      _onboardingState = HealthConnectOnboardingState.syncing;
    });
    final granted = await _healthSync.requestPermissions();
    if (granted) {
      await _loadActivityData();
    } else {
      final hasPerms = await _healthSync.hasPermissions();
      if (hasPerms) {
        await _loadActivityData();
      } else if (mounted) {
        setState(() {
          _onboardingState = HealthConnectOnboardingState.permissionsMissing;
        });
      }
    }
  }

  // Card UI Component Helpers
  Widget _buildState1Card() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
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
            child: const Center(
              child: Icon(Icons.favorite_rounded, color: Color(0xFF1E88E5), size: 40),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Connect Your Health Data',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Automatically track your steps, distance,\ncalories burned and active minutes\nusing Health Connect.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GelatoTheme.pink, GelatoTheme.orange],
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
                onPressed: _onInstallTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Install Health Connect',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.open_in_new_rounded, size: 18, color: GelatoTheme.textDark),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security_rounded, size: 14, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                'Secure • Google Supported',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildState2Card() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
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
            child: const Center(
              child: Icon(Icons.shield_rounded, color: Color(0xFFFB8C00), size: 40),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Almost There!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Health Connect is installed.\n\nAllow DPP to securely read your\nactivity data.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCheckItem('Steps'),
              const SizedBox(width: 12),
              _buildCheckItem('Distance'),
              const SizedBox(width: 12),
              _buildCheckItem('Calories'),
              const SizedBox(width: 12),
              _buildCheckItem('Active Mins'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
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
                onPressed: _onGrantPermissionsTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  'Grant Permissions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: GelatoTheme.textDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, size: 16, color: GelatoTheme.greenDark),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GelatoTheme.textDark)),
      ],
    );
  }

  Widget _buildState3Card() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
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
          colors: [GelatoTheme.green.withValues(alpha: 0.3), Colors.white],
          stops: const [0.0, 0.7],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
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
            child: const Center(
              child: _SpinningSyncIcon(),
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Connected',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: GelatoTheme.textDark,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.check_circle_rounded, color: Color(0xFF00B0FF), size: 24),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Syncing today's activity...",
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: 180,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
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

  Widget _buildDashboardPreview({bool isShimmer = false}) {
    return Opacity(
      opacity: isShimmer ? 0.5 : 0.3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  'Preview of your dashboard',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildPreviewCard('Steps', '--', Icons.directions_walk_rounded)),
                const SizedBox(width: 12),
                Expanded(child: _buildPreviewCard('Distance', '-- km', Icons.location_on_outlined)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPreviewCard('Calories', '-- kcal', Icons.local_fire_department_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildPreviewCard('Active Minutes', '-- min', Icons.bolt_rounded)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(String title, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black45)),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_onboardingState == HealthConnectOnboardingState.syncing) {
      return Column(
        key: const ValueKey('syncing'),
        children: [
          _buildState3Card(),
          _buildDashboardPreview(isShimmer: true),
        ],
      );
    }

    return Column(
      key: ValueKey(_onboardingState.name),
      children: [
        if (_onboardingState == HealthConnectOnboardingState.notInstalled) ...[
          _buildState1Card(),
          const SizedBox(height: 16),
        ] else if (_onboardingState == HealthConnectOnboardingState.permissionsMissing) ...[
          _buildState2Card(),
          const SizedBox(height: 16),
        ],
        const HeroBanner(),
        const SizedBox(height: 16),
        GoalJourney(
          currentMinutes: _currentWeeklyMinutes,
          goalMinutes: _weeklyTargetMinutes,
        ),
        const SizedBox(height: 16),
        TodayActivityScore(
          score: _dailyScore,
          feedbackText: _dailyScoreFeedback,
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),
              OverviewCards(stats: _activityStats),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const ActivityFeed(),
        const SizedBox(height: 16),
        WeeklyProgress(pastDays: _pastDays, programWeek: _programWeek),
        const SizedBox(height: 16),
        MotivationSection(pastDays: _pastDays),
        const SizedBox(height: 16),
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
                        isConnected: _onboardingState == HealthConnectOnboardingState.connected,
                        lastSyncTime: _lastSyncTime,
                        onSyncTap: () => _loadActivityData(forceRefresh: true),
                      ),
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
      child: const Icon(Icons.sync_rounded, color: Color(0xFF009688), size: 40),
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
