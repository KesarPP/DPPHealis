import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_hero_cards.dart';
import '../widgets/dashboard_timeline.dart';
import '../widgets/dashboard_risk_card.dart';
import '../widgets/dashboard_momentum.dart';
import '../widgets/dashboard_achievements.dart';
import '../widgets/user_side_drawer.dart';
import '../services/health_sync_service.dart';
import '../services/activity_metrics_engine.dart';
import '../services/achievements_service.dart';
import '../models/ndpp_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health/health.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  List<Achievement> _achievements = [];
  List<DailyAggregate> _past30Days = [];
  bool _isLoading = false;
  SyncStatus _syncStatus = SyncStatus.success;
  int _mealLogCount = 1;
  bool _waterLogged = true;
  bool _weightLogged = true;
  bool _lessonCompleted = true;
  bool _journalLogged = false;
  int _programWeek = 8;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final now = DateTime.now();
    for (int i = 29; i >= 0; i--) {
      _past30Days.add(DailyAggregate.empty(now.subtract(Duration(days: i))));
    }
    _initQuickRestore();
    _loadData();
  }

  Future<void> _initQuickRestore() async {
    try {
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
      final now = DateTime.now();
      List<DailyAggregate> quick = [];
      for (int i = 29; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        final local = d.toLocal();
        final key = "${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}";
        final pSteps = prefs.getInt('hc_persist_steps_$key');
        if (pSteps != null && pSteps > 0) {
          final dist = prefs.getDouble('hc_persist_dist_$key') ?? (pSteps * 0.00076);
          final cals = prefs.getDouble('hc_persist_cals_$key') ?? 0.0;
          final act = prefs.getInt('hc_persist_act_mins_$key') ?? 0;
          final qual = prefs.getInt('hc_persist_qual_mins_$key') ?? 0;
          quick.add(DailyAggregate(
            date: d,
            totalSteps: pSteps,
            totalDistance: dist,
            totalCalories: cals,
            totalActiveMinutes: act,
            qualifyingActiveMinutes: qual,
            isActiveDay: qual >= NdppConstants.minQualifyingSessionMinutes,
            coreSessions: const [],
            lifestyleSessions: const [],
          ));
        } else {
          quick.add(DailyAggregate.empty(d));
        }
      }
      if (mounted && _past30Days.every((item) => item.totalSteps == 0)) {
        setState(() {
          _past30Days = quick;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    if (mounted) setState(() { _syncStatus = SyncStatus.syncing; });
    try {
      final healthSync = HealthSyncService();
      bool sdkUnavailable = false;
      try {
        final sdkStatus = await Health().getHealthConnectSdkStatus();
        if (sdkStatus == HealthConnectSdkStatus.sdkUnavailable) {
          sdkUnavailable = true;
        }
      } catch (_) {}

      bool granted = false;
      if (!sdkUnavailable) {
        try {
          granted = await healthSync.hasPermissions();
          if (!granted) {
            granted = await healthSync.requestPermissions().timeout(const Duration(seconds: 15));
          }
        } catch (e) {
          debugPrint('Dashboard requestPermissions error: $e');
        }
      }
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 29));
      List<DailyAggregate> past30Days = [];
      try {
        past30Days = await healthSync.getStatsForInterval(startTime: thirtyDaysAgo, endTime: now).timeout(const Duration(seconds: 25));
      } catch (e) {
        debugPrint('Dashboard getStatsForInterval error: $e');
      }
      
      if (past30Days.isEmpty) {
        for (int i = 29; i >= 0; i--) {
          past30Days.add(DailyAggregate.empty(now.subtract(Duration(days: i))));
        }
      }
      
      final int programWeek = _programWeek;

      final achievements = await AchievementsService.evaluateAndSync(
        trailing30Days: past30Days,
        programWeek: programWeek,
        context: mounted ? context : null,
      );

      final prefs = await SharedPreferences.getInstance();
      final nowStr = "${now.year}-${now.month}-${now.day}";
      final int mealCount = prefs.getInt('mission_meal_$nowStr') ?? 1;
      final bool water = prefs.getBool('mission_water_$nowStr') ?? true;
      final bool weight = prefs.getBool('mission_weight_$nowStr') ?? true;
      final bool lesson = prefs.getBool('mission_lesson_$nowStr') ?? true;
      final bool journal = prefs.getBool('mission_journal_$nowStr') ?? false;

      if (mounted) {
        setState(() {
          _achievements = achievements;
          _past30Days = past30Days;
          _mealLogCount = mealCount;
          _waterLogged = water;
          _weightLogged = weight;
          _lessonCompleted = lesson;
          _journalLogged = journal;
          _syncStatus = sdkUnavailable
              ? SyncStatus.healthConnectUnavailable
              : (!granted && past30Days.every((d) => d.totalSteps == 0))
                  ? SyncStatus.permissionDenied
                  : SyncStatus.success;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Dashboard loadData overall error: $e');
      if (mounted) {
        setState(() {
          _syncStatus = SyncStatus.error;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF).withValues(alpha: 0.5),
      endDrawer: const UserSideDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DotsPainter(color: GelatoTheme.purpleDark.withValues(alpha: 0.05)),
              ),
            ),
            RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. Dashboard Header
                  const SliverToBoxAdapter(
                    child: DashboardHeader(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // 2. Hero Progress Area (Weight & Activity)
                  SliverToBoxAdapter(
                    child: DashboardHeroCards(
                            trailing30Days: _past30Days,
                            programWeek: _programWeek,
                            syncStatus: _syncStatus,
                            onRetrySync: _loadData,
                          ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 3. Today's Mission (Timeline)
                SliverToBoxAdapter(
                  child: DashboardTimeline(
                          todayAgg: _past30Days.isNotEmpty ? _past30Days.last : null,
                          mealLogCount: _mealLogCount,
                          waterLogged: _waterLogged,
                          weightLogged: _weightLogged,
                          lessonCompleted: _lessonCompleted,
                          journalLogged: _journalLogged,
                          onToggleItem: _toggleMissionItem,
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 4. Prediabetes Risk Card (Compact)
                const SliverToBoxAdapter(
                  child: DashboardRiskCard(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 5. Your Momentum
                const SliverToBoxAdapter(
                  child: DashboardMomentum(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 6. Achievement Showcase
                SliverToBoxAdapter(
                  child: DashboardAchievements(achievements: _achievements),
                ),
                
                // Bottom Padding for BottomNavigationBar
                const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _toggleMissionItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final nowStr = "${now.year}-${now.month}-${now.day}";
    setState(() {
      if (index == 0) {
        _mealLogCount = (_mealLogCount >= 2) ? 0 : _mealLogCount + 1;
        prefs.setInt('mission_meal_$nowStr', _mealLogCount);
      } else if (index == 2) {
        _waterLogged = !_waterLogged;
        prefs.setBool('mission_water_$nowStr', _waterLogged);
      } else if (index == 3) {
        _weightLogged = !_weightLogged;
        prefs.setBool('mission_weight_$nowStr', _weightLogged);
      } else if (index == 4) {
        _lessonCompleted = !_lessonCompleted;
        prefs.setBool('mission_lesson_$nowStr', _lessonCompleted);
      } else if (index == 5) {
        _journalLogged = !_journalLogged;
        prefs.setBool('mission_journal_$nowStr', _journalLogged);
      }
    });
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
