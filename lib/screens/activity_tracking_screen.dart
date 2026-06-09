import 'package:flutter/material.dart';
import '../widgets.dart';

class ActivityTrackingScreen extends StatelessWidget {
  const ActivityTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Tracking')),
      body: ListView(
        children: const [
          // ── Log activity ──────────────────────────────────────
          SectionHeader('Log Activity'),
          PlaceholderCard(
            icon: Icons.add_circle_outline,
            title: 'Activity Log',
            subtitle: 'Placeholder – manually log exercise sessions',
          ),
          PlaceholderCard(
            icon: Icons.watch_outlined,
            title: 'Wearable Sync',
            subtitle: 'Placeholder – sync from fitness tracker / Apple Watch',
          ),

          // ── Progress ──────────────────────────────────────────
          SectionHeader('Progress'),
          PlaceholderCard(
            icon: Icons.bar_chart,
            title: 'Weekly Progress',
            subtitle: 'Placeholder – minutes of activity per week',
          ),
          PlaceholderCard(
            icon: Icons.directions_walk,
            title: 'Step Count',
            subtitle: 'Placeholder – daily step goal and trend',
          ),
          PlaceholderCard(
            icon: Icons.local_fire_department_outlined,
            title: 'Calories Burned',
            subtitle: 'Placeholder – active calorie expenditure',
          ),

          // ── Goals ─────────────────────────────────────────────
          SectionHeader('Goals'),
          PlaceholderCard(
            icon: Icons.flag_outlined,
            title: 'Activity Goals',
            subtitle: 'Placeholder – set weekly minute targets',
          ),

          SizedBox(height: 24),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open log activity bottom sheet
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Activity'),
      ),
    );
  }
}
