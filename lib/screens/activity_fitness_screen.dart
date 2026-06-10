import 'package:flutter/material.dart';
import '../widgets/activity_header.dart';
import '../widgets/hero_banner.dart';
import '../widgets/goal_journey.dart';
import '../widgets/overview_cards.dart';
import '../widgets/weekly_progress.dart';
import '../widgets/daily_goals.dart';
import '../widgets/activity_feed.dart';
import '../widgets/motivation_section.dart';
import '../widgets/ai_coach_card.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Fixed header
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  SizedBox(height: 12),
                  ActivityHeader(),
                  SizedBox(height: 12),
                ],
              ),
            ),

            // Hero Banner
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  HeroBanner(),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // Journey to Goal
            SliverToBoxAdapter(
              child: Column(
                children: const [
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
                    Row(
                      children: [
                        const Text('📊', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          "Today's Overview",
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1A1A2E),
                                  ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(80, 24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'View Insights',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 16, color: Color(0xFF10B981)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Overview Cards
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  OverviewCards(),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // Weekly Progress
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  WeeklyProgress(),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // Daily Goals
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  DailyGoals(),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // Activity Feed
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  ActivityFeed(),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // Motivation + Streak
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  MotivationSection(),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // AI Coach CTA
            SliverToBoxAdapter(
              child: Column(
                children: const [
                  AiCoachCard(),
                ],
              ),
            ),

            // Bottom padding for navigation bar
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }
}
