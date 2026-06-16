import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_risk_card.dart';
import '../widgets/dashboard_progress_snapshot.dart';
import '../widgets/dashboard_timeline.dart';
import '../widgets/dashboard_analytics.dart';

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
              slivers: const [
                // 1. Dashboard Header
                SliverToBoxAdapter(
                  child: DashboardHeader(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12)),

                // 2. Prediabetes Risk Card
                SliverToBoxAdapter(
                  child: DashboardRiskCard(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 3. Sessions & Meals Analytics
                SliverToBoxAdapter(
                  child: DashboardAnalytics(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 4. Today's Progress Snapshot
                SliverToBoxAdapter(
                  child: DashboardProgressSnapshot(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 16)),
                
                // 5. Today's Timeline Journey
                SliverToBoxAdapter(
                  child: DashboardTimeline(),
                ),
                
                // Bottom Padding for BottomNavigationBar
                SliverPadding(padding: EdgeInsets.only(bottom: 96)),
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
