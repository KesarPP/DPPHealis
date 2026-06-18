import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_hero_cards.dart';
import '../widgets/dashboard_timeline.dart';
import '../widgets/dashboard_risk_card.dart';
import '../widgets/dashboard_momentum.dart';
import '../widgets/dashboard_achievements.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E8FF).withValues(alpha: 0.5), // Soft lavender from Gelato theme to highlight white cards
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
              slivers: const [
                // 1. Dashboard Header
                SliverToBoxAdapter(
                  child: DashboardHeader(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12)),

                // 2. Hero Progress Area (Weight & Activity)
                SliverToBoxAdapter(
                  child: DashboardHeroCards(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 3. Today's Mission (Timeline)
                SliverToBoxAdapter(
                  child: DashboardTimeline(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 4. Prediabetes Risk Card (Compact)
                SliverToBoxAdapter(
                  child: DashboardRiskCard(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 5. Your Momentum
                SliverToBoxAdapter(
                  child: DashboardMomentum(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 6. Achievement Showcase
                SliverToBoxAdapter(
                  child: DashboardAchievements(),
                ),
                
                // Bottom Padding for BottomNavigationBar
                SliverPadding(padding: EdgeInsets.only(bottom: 120)),
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
