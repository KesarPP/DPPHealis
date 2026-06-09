import 'package:flutter/material.dart';

/// A reusable placeholder card shown on every screen.
/// Replace the content with real widgets during feature development.
class PlaceholderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PlaceholderCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = 'Coming soon',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: colorScheme.outline, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

/// A simple section header label.
class SectionHeader extends StatelessWidget {
  final String label;
  const SectionHeader(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
