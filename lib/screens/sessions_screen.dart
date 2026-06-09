import 'package:flutter/material.dart';
import '../widgets.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: ListView(
        children: const [
          // ── Curriculum ────────────────────────────────────────
          SectionHeader('Curriculum'),
          PlaceholderCard(
            icon: Icons.list_alt,
            title: 'Session List',
            subtitle: 'Placeholder – 16-session core curriculum + follow-on',
          ),
          PlaceholderCard(
            icon: Icons.play_circle_outline,
            title: 'Current Session',
            subtitle: 'Placeholder – continue where you left off',
          ),

          // ── Resources ─────────────────────────────────────────
          SectionHeader('Resources'),
          PlaceholderCard(
            icon: Icons.menu_book_outlined,
            title: 'Resource Library',
            subtitle: 'Placeholder – handouts, recipes, tip sheets',
          ),
          PlaceholderCard(
            icon: Icons.video_library_outlined,
            title: 'Video Library',
            subtitle: 'Placeholder – instructional & motivational videos',
          ),

          // ── Community ─────────────────────────────────────────
          SectionHeader('Community'),
          PlaceholderCard(
            icon: Icons.group_outlined,
            title: 'Group Sessions',
            subtitle: 'Placeholder – live cohort meeting schedule',
          ),
          PlaceholderCard(
            icon: Icons.forum_outlined,
            title: 'Discussion Board',
            subtitle: 'Placeholder – peer support forum',
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }
}
