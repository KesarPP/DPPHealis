import 'package:flutter/material.dart';
import '../widgets.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          // ── Avatar / name banner ──────────────────────────────
          const _ProfileBanner(),

          // ── Goals ─────────────────────────────────────────────
          const SectionHeader('Goals'),
          const PlaceholderCard(
            icon: Icons.flag,
            title: 'Goals',
            subtitle: 'Placeholder – weight loss %, activity minutes target',
          ),

          // ── Health history ────────────────────────────────────
          const SectionHeader('Health History'),
          const PlaceholderCard(
            icon: Icons.monitor_weight_outlined,
            title: 'Weight History',
            subtitle: 'Placeholder – all logged weigh-ins over time',
          ),
          const PlaceholderCard(
            icon: Icons.biotech_outlined,
            title: 'Lab History',
            subtitle: 'Placeholder – A1c, fasting glucose, lipid panels',
          ),
          const PlaceholderCard(
            icon: Icons.medication_outlined,
            title: 'Medications',
            subtitle: 'Placeholder – current medication list',
          ),

          // ── Settings ──────────────────────────────────────────
          const SectionHeader('Settings'),
          const PlaceholderCard(
            icon: Icons.notifications_outlined,
            title: 'Notification Preferences',
            subtitle: 'Placeholder – reminder times & channels',
          ),
          const PlaceholderCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy & Data',
            subtitle: 'Placeholder – data sharing and export options',
          ),

          // ── Sign out ──────────────────────────────────────────
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              onPressed: () {
                // TODO: Clear auth state before navigating
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.person, size: 36, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jane Doe',
                style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                'DPP Participant – Cohort 3',
                style: TextStyle(color: colorScheme.outline, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                'Lifestyle Coach: Placeholder',
                style: TextStyle(color: colorScheme.outline, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
