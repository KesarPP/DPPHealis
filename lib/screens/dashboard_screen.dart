import 'package:flutter/material.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_risk_card.dart';
import '../widgets/dashboard_progress_snapshot.dart';
import '../widgets/dashboard_ai_coach_card.dart';
import '../widgets/dashboard_timeline.dart';
import '../widgets/dashboard_quick_actions.dart';

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
      backgroundColor: const Color(0xFFF7F9FC), // Cloud background
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Dashboard Header
            const SliverToBoxAdapter(
              child: DashboardHeader(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 2. Prediabetes Risk Card
            const SliverToBoxAdapter(
              child: DashboardRiskCard(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 3. Today's Progress Snapshot
            const SliverToBoxAdapter(
              child: DashboardProgressSnapshot(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 4. AI Coach Card
            const SliverToBoxAdapter(
              child: DashboardAICoachCard(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 5. Today's Timeline Journey
            const SliverToBoxAdapter(
              child: DashboardTimeline(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 6. Quick Actions
            const SliverToBoxAdapter(
              child: DashboardQuickActions(),
            ),
            
            // Bottom Padding for BottomNavigationBar
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}
