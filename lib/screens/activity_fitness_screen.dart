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

class _ActivityFitnessScreenState extends State<ActivityFitnessScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedSliver(Widget child, int index) {
    final start = (index * 0.1).clamp(0.0, 1.0);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, childWidget) {
          return Opacity(
            opacity: animation.value,
            child: Transform.translate(
              offset: Offset(0, 40 * (1 - animation.value)),
              child: childWidget,
            ),
          );
        },
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0E5), // very light orange
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
                _buildAnimatedSliver(
                  const Column(
                    children: [
                      SizedBox(height: 12),
                      ActivityHeader(),
                      SizedBox(height: 12),
                    ],
                  ),
                  0,
                ),
                _buildAnimatedSliver(
                  const Column(
                    children: [
                      HeroBanner(),
                      SizedBox(height: 16),
                    ],
                  ),
                  1,
                ),
                _buildAnimatedSliver(
                  const Column(
                    children: [
                      GoalJourney(
                        currentSteps: 102450,
                        goalSteps: 150000,
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                  2,
                ),
                _buildAnimatedSliver(
                  Padding(
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
                  3,
                ),
                _buildAnimatedSliver(
                  const Column(
                    children: [
                      OverviewCards(),
                      SizedBox(height: 16),
                    ],
                  ),
                  4,
                ),
                _buildAnimatedSliver(
                  const Column(
                    children: [
                      WeeklyProgress(),
                      SizedBox(height: 16),
                    ],
                  ),
                  5,
                ),
                _buildAnimatedSliver(
                  const Column(
                    children: [
                      DailyGoals(),
                      SizedBox(height: 16),
                    ],
                  ),
                  6,
                ),
                _buildAnimatedSliver(
                  const Column(
                    children: [
                      ActivityFeed(),
                      SizedBox(height: 16),
                    ],
                  ),
                  7,
                ),
                _buildAnimatedSliver(
                  const Column(
                    children: [
                      MotivationSection(),
                      SizedBox(height: 16),
                    ],
                  ),
                  8,
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
