import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:dpp_app/screens/food_tracking_screen.dart';
import 'package:dpp_app/screens/activity_fitness_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/gelato_theme.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_hero_cards.dart';
import '../widgets/dashboard_timeline.dart';
import '../widgets/dashboard_energy_balance_card.dart';
import '../widgets/user_side_drawer.dart';

import '../providers/food_notifiers.dart';
import 'package:provider/provider.dart';
import '../services/health_sync_service.dart';
import '../services/points_service.dart';
import '../services/achievements_service.dart';
import '../services/firestore_activity_log_service.dart';
import '../repositories/activity_log_repository_impl.dart';
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
  List<DailyAggregate> _past30Days = [];
  bool _isLoading = false;
  SyncStatus _syncStatus = SyncStatus.success;
  int _mealLogCount = 0;
  bool _activityLogged = false;
  bool _waterLogged = false;
  bool _weightLogged = false;
  bool _lessonCompleted = false;
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
          _past30Days = quick.every((item) => item.totalSteps == 0) ? _generateSyncedDefaultAggregates(now) : quick;
        });
      }
    } catch (_) {}
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
      bool sdkUnavailable = true; // TEMPORARILY DISABLED TO PREVENT ANR
      /*
      try {
        final sdkStatus = await Health().getHealthConnectSdkStatus();
        if (sdkStatus == HealthConnectSdkStatus.sdkUnavailable) {
          sdkUnavailable = true;
        }
      } catch (_) {}
      */

      bool granted = false;
      /*
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
      */
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 29));
      List<DailyAggregate> past30Days = [];
      /* TEMPORARILY DISABLED TO PREVENT ANR
      try {
        past30Days = await healthSync.getStatsForInterval(startTime: thirtyDaysAgo, endTime: now).timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('Dashboard getStatsForInterval error: $e');
      }
      */
      
      if (past30Days.isEmpty || past30Days.every((d) => d.totalSteps == 0 && d.totalActiveMinutes == 0)) {
        past30Days = _generateSyncedDefaultAggregates(now);
      }
      
      final int programWeek = _programWeek;

      final achievements = await AchievementsService.evaluateAndSync(
        trailing30Days: past30Days,
        programWeek: programWeek,
        context: mounted ? context : null,
      );

      final prefs = await SharedPreferences.getInstance();
      final nowStr = "${now.year}-${now.month}-${now.day}";
      final isoTodayStr = now.toIso8601String().split('T')[0];
      final user = FirebaseAuth.instance.currentUser;

      // 1. Check Meal Log from backend
      int mealCount = 0;
      if (user != null) {
        try {
          final foodDoc = await FirebaseFirestore.instance
              .collection('logs')
              .doc(user.uid)
              .collection('food_entries')
              .doc(isoTodayStr)
              .get();
          if (foodDoc.exists && foodDoc.data() != null) {
            final entries = foodDoc.data()!['entries'] as List<dynamic>? ?? [];
            mealCount = entries.length;
          }
        } catch (e) {
          debugPrint('Error loading food log: $e');
        }
      }
      if (mealCount == 0) {
        mealCount = prefs.getInt('mission_meal_$nowStr') ?? 0;
      }

      // 2. Check Activity Log from backend
      bool actLogged = false;
      try {
        final activityRepo = ActivityLogRepositoryImpl(FirestoreActivityLogService());
        final todayLogs = await activityRepo.getTodayActivityLogs();
        actLogged = todayLogs.isNotEmpty;
        
        if (actLogged) {
          PointsService.awardPoints(
            action: 'activity_met',
            points: 10,
            referenceId: nowStr,
          );
        }
      } catch (e) {
        debugPrint('Error loading activity logs: $e');
      }

      // 3. Check Weekly Weigh In from backend
      bool weightLoggedThisWeek = false;
      if (user != null) {
        try {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          if (userDoc.exists && userDoc.data() != null) {
            final lastWeighIn = userDoc.data()!['lastWeighInDate'] as Timestamp?;
            if (lastWeighIn != null) {
              final diff = now.difference(lastWeighIn.toDate());
              if (diff.inDays <= 7 && !diff.isNegative) {
                weightLoggedThisWeek = true;
              }
            }
          }
          if (!weightLoggedThisWeek) {
            final weightSnap = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('weight_history')
                .orderBy('date', descending: true)
                .limit(1)
                .get();
            if (weightSnap.docs.isNotEmpty) {
              final ts = weightSnap.docs.first.data()['date'] as Timestamp?;
              if (ts != null && now.difference(ts.toDate()).inDays <= 7) {
                weightLoggedThisWeek = true;
              }
            }
          }
        } catch (e) {
          debugPrint('Error loading weight history: $e');
        }
      }

      final bool water = prefs.getBool('mission_water_$nowStr') ?? false;
      final bool weight = weightLoggedThisWeek || (prefs.getBool('mission_weight_$nowStr') ?? false);
      final bool lesson = prefs.getBool('mission_lesson_$nowStr') ?? false;
      final bool journal = prefs.getBool('mission_journal_$nowStr') ?? false;

      if (mounted) {
        setState(() {
          _past30Days = past30Days;
          _mealLogCount = mealCount;
          _activityLogged = actLogged;
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
        backgroundColor: GelatoTheme.bg,
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
                      const SliverToBoxAdapter(child: SizedBox(height: 14)),
  
                    // 2. Hero Progress Area (Weight)
                    SliverToBoxAdapter(
                      child: DashboardHeroCards(
                              trailing30Days: _past30Days,
                              programWeek: _programWeek,
                              syncStatus: _syncStatus,
                              onRetrySync: _loadData,
                            ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),

                    // 2.5 Hero Progress Area (Activity)
                    SliverToBoxAdapter(
                      child: DashboardActivityCard(
                              trailing30Days: _past30Days,
                              programWeek: _programWeek,
                            ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // 2.5 Energy Balance Card
                  const SliverToBoxAdapter(
                    child: DashboardEnergyBalanceCard(),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 14)),

                  // 3. Today's Mission (Timeline)
                  SliverToBoxAdapter(
                    child: DashboardTimeline(
                            todayAgg: _past30Days.isNotEmpty ? _past30Days.last : null,
                            mealLogCount: _mealLogCount,
                            activityLogged: _activityLogged,
                            waterLogged: _waterLogged,
                            weightLogged: _weightLogged,
                            lessonCompleted: _lessonCompleted,
                            journalLogged: _journalLogged,
                            onToggleItem: _toggleMissionItem,
                          ),
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
    if (index == 0) {
      setState(() {
        _weightLogged = !_weightLogged;
      });
      prefs.setBool('mission_weight_$nowStr', _weightLogged);
    } else if (index == 1) {
      setState(() {
        _lessonCompleted = !_lessonCompleted;
      });
      prefs.setBool('mission_lesson_$nowStr', _lessonCompleted);
      
      if (_lessonCompleted) {
        PointsService.awardPoints(
          action: 'session_completed',
          points: 10,
          referenceId: nowStr,
        );
      }
    } else if (index == 2) {
      _showMealLogBottomSheet();
    } else if (index == 3) {
      if (!_activityLogged) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityFitnessScreen()));
      }
    }
  }

  void _showMealLogBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: GelatoTheme.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final foodNotifier = ctx.watch<FoodDiaryNotifier>();
        final dailyLog = foodNotifier.dailyLog;
        
        final meals = [
          {'name': 'Breakfast', 'type': 'Breakfast', 'icon': Icons.breakfast_dining_rounded, 'color': GelatoTheme.pink},
          {'name': 'Snack 1', 'type': 'Snack 1', 'icon': Icons.bakery_dining_rounded, 'color': GelatoTheme.blue},
          {'name': 'Lunch', 'type': 'Lunch', 'icon': Icons.lunch_dining_rounded, 'color': GelatoTheme.green},
          {'name': 'Snack 2', 'type': 'Snack 2', 'icon': Icons.apple_rounded, 'color': GelatoTheme.purple},
          {'name': 'Dinner', 'type': 'Dinner', 'icon': Icons.dinner_dining_rounded, 'color': GelatoTheme.orange},
        ];

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              const Text(
                'Today\'s Meals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GelatoTheme.textDark),
              ),
              const SizedBox(height: 20),
              ...meals.map((meal) {
                final type = meal['type'] as String;
                final bool hasItems = dailyLog != null && dailyLog.entries.any((e) => e.mealType == type);
                final mealColor = meal['color'] as Color;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: mealColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 0, offset: const Offset(2, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          meal['icon'] as IconData,
                          size: 20,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          meal['name'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: GelatoTheme.textDark,
                          ),
                        ),
                      ),
                      if (hasItems)
                        const Icon(Icons.check_circle_rounded, color: GelatoTheme.greenDark, size: 24)
                      else
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.black, width: 1.5),
                            ),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodTrackingScreen()));
                          },
                          child: const Text('Tap to log in', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  },
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

class SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final double borderRadius;

  SpotlightPainter({this.targetRect, this.borderRadius = 16.0});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final screenPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (targetRect == null) {
      canvas.drawPath(screenPath, backgroundPaint);
      return;
    }

    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(targetRect!, Radius.circular(borderRadius)));

    final resultPath = Path.combine(PathOperation.difference, screenPath, cutoutPath);
    canvas.drawPath(resultPath, backgroundPaint);

    final borderPaint = Paint()
      ..color = GelatoTheme.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRRect(RRect.fromRectAndRadius(targetRect!, Radius.circular(borderRadius)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect || oldDelegate.borderRadius != borderRadius;
  }
}
