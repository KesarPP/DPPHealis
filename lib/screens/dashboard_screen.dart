import 'package:flutter/material.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_risk_card.dart';
import '../widgets/dashboard_progress_snapshot.dart';
import '../widgets/dashboard_timeline.dart';
import '../widgets/dashboard_analytics.dart';
import '../data/gelato_theme.dart';

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
        child: CustomScrollView(
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
            const SliverToBoxAdapter(
              child: DashboardAnalytics(),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 4. Today's Progress Snapshot
            const SliverToBoxAdapter(
              child: DashboardProgressSnapshot(),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 5. Today's Timeline Journey
            SliverToBoxAdapter(
              child: DashboardTimeline(),
            ),
            
            // Bottom Padding for BottomNavigationBar
            const SliverPadding(padding: EdgeInsets.only(bottom: 96)),
          ],
        ),
      ),
    );
  }
}
