import 'package:flutter/material.dart';
import '../widgets/activity_header.dart';
import '../widgets/hero_banner.dart';
import '../widgets/goal_journey.dart';
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
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

                // Today's Overview section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bar_chart_rounded, color: GelatoTheme.purpleDark, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Today's Overview",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: GelatoTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(80, 24),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Insights',
                                style: TextStyle(
                                  color: GelatoTheme.purpleDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  size: 16, color: GelatoTheme.purpleDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Overview Cards
                const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      OverviewCards(),
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

                // Daily Goals
                const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      DailyGoals(),
                      SizedBox(height: 16),
                    ],
                  ),
                ),

                // Activity Feed
                const SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ActivityFeed(),
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
