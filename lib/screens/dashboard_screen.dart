import 'package:flutter/material.dart';
import '../widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Open notifications panel
            },
          ),
        ],
      ),
      body: ListView(
        children: const [
          // ── Greeting banner ───────────────────────────────────
          _WelcomeBanner(),

          // ── Today's summary ───────────────────────────────────
          SectionHeader('Today\'s Summary'),
          PlaceholderCard(
            icon: Icons.restaurant,
            title: 'Food Progress',
            subtitle: 'Placeholder – calories & macros will appear here',
          ),
          PlaceholderCard(
            icon: Icons.directions_run,
            title: 'Activity Progress',
            subtitle: 'Placeholder – steps & minutes will appear here',
          ),

          // ── Trends ────────────────────────────────────────────
          SectionHeader('Trends'),
          PlaceholderCard(
            icon: Icons.show_chart,
            title: 'Weight Trend',
            subtitle: 'Placeholder – weight chart will appear here',
          ),

          // ── Engagement ────────────────────────────────────────
          SectionHeader('Engagement'),
          PlaceholderCard(
            icon: Icons.local_fire_department,
            title: 'Streaks',
            subtitle: 'Placeholder – logging streak will appear here',
          ),
          PlaceholderCard(
            icon: Icons.emoji_events_outlined,
            title: 'Achievements',
            subtitle: 'Placeholder – badges & milestones will appear here',
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning! 👋',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Week 1 of your DPP journey',
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
