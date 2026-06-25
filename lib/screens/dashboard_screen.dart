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
import '../models/ndpp_constants.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Achievement> _achievements = [];
  List<DailyAggregate> _past30Days = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final healthSync = HealthSyncService();
      try {
        await healthSync.requestPermissions().timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('Dashboard requestPermissions error: $e');
      }
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 29));
      List<DailyAggregate> past30Days = [];
      try {
        past30Days = await healthSync.getStatsForInterval(startTime: thirtyDaysAgo, endTime: now).timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Dashboard getStatsForInterval error: $e');
      }
      
      if (past30Days.isEmpty) {
        for (int i = 29; i >= 0; i--) {
          past30Days.add(DailyAggregate.empty(now.subtract(Duration(days: i))));
        }
      }
      
      final pastDays = past30Days.length >= 7 
          ? past30Days.sublist(past30Days.length - 7)
          : past30Days;

      const int mealLogCount = 52;
      const double baselineWeight = 90.0;
      const double currentWeight = 84.0;
      const double riskScore = 28.0;
      const int programWeek = 6;

      final achievements = ActivityMetricsEngine.evaluateAchievements(
        pastDays: pastDays,
        mealLogCount: mealLogCount,
        baselineWeight: baselineWeight,
        currentWeight: currentWeight,
        riskScore: riskScore,
        programWeek: programWeek,
      );

      if (mounted) {
        setState(() {
          _achievements = achievements;
          _past30Days = past30Days;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Dashboard loadData overall error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            CustomScrollView(
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
                  child: _isLoading
                      ? const SizedBox(height: 480, child: Center(child: CircularProgressIndicator()))
                      : DashboardHeroCards(trailing30Days: _past30Days, programWeek: 6),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 3. Today's Mission (Timeline)
                SliverToBoxAdapter(
                  child: _isLoading
                      ? const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()))
                      : DashboardTimeline(
                          todayAgg: _past30Days.isNotEmpty ? _past30Days.last : null,
                          mealLogCount: 2,
                          waterLogged: true,
                          weightLogged: true,
                          lessonCompleted: true,
                          journalLogged: false,
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
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator()) 
                    : DashboardAchievements(achievements: _achievements),
                ),
                
                // Bottom Padding for BottomNavigationBar
                const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
              ],
            ),
          ],
        ),
      ),
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
