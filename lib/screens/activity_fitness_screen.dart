import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/activity_stats.dart';
import '../repositories/activity_repository.dart';
import '../repositories/activity_repository_impl.dart';
import '../services/health_connect_service.dart';
import '../widgets/activity_header.dart';
import '../widgets/hero_banner.dart';
import '../widgets/goal_journey.dart';
import '../widgets/today_activity_score.dart';
import '../widgets/overview_cards.dart';
import '../widgets/weekly_progress.dart';
import '../widgets/daily_goals.dart';
import '../widgets/activity_feed.dart';
import '../widgets/motivation_section.dart';
import '../data/gelato_theme.dart';

class ActivityFitnessScreen extends StatefulWidget {
  const ActivityFitnessScreen({super.key});

  @override
  State<ActivityFitnessScreen> createState() => _ActivityFitnessScreenState();
}

class _ActivityFitnessScreenState extends State<ActivityFitnessScreen> {
  final ScrollController _scrollController = ScrollController();
  late final ActivityRepository _repository;
  ActivityStats? _stats;
  bool _isLoading = true;
  ActivityStats get _activityStats {
    return _stats ?? ActivityStats.empty();
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  Future<void> _loadActivityData() async {
    final stats = await _repository.getActivityStats();
    debugPrint('HEALTH_STATS');
    debugPrint('Steps: ${stats.steps}');
    debugPrint('Distance: ${stats.distance}');
    debugPrint('Calories: ${stats.calories}');
    debugPrint('Active Minutes: ${stats.activeMinutes}');
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    _repository = ActivityRepositoryImpl(
      HealthConnectService(),
    );
    _loadActivityData();
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
                // Fixed header
                const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(height: 12),
                      ActivityHeader(),
                      SizedBox(height: 12),
                    ],
                  ),
                ),

                // Hero Banner
                const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      HeroBanner(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),

                // Journey to Goal
                const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      GoalJourney(
                        currentSteps: 102450,
                        goalSteps: 150000,
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),

                // Today's Activity Score
                const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      TodayActivityScore(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),

                // Today's Overview section (Header + Cards in a BG Card)
                SliverToBoxAdapter(
                  child: Container(
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
                        OverviewCards(
                          stats: _activityStats,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Activity Feed (Today's activities)
                const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ActivityFeed(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),

                // Daily Goals (Goal Summary)
                const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      DailyGoals(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),

                // Weekly Progress
                const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      WeeklyProgress(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),

                // Motivation + Streak
                const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      MotivationSection(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),

                // Bottom padding for navigation bar and floating button
                const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
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
