import 'package:flutter/material.dart';
import '../models/week_model.dart';
import '../theme/manuscript_theme.dart';

/// Placeholder destination for tapping a chapter card.
///
/// Phase 2 will replace this with the real lesson / video / quiz / meal /
/// activity / handouts flows for that week — nothing beyond this
/// placeholder should be implemented here yet.
class SessionDetailPage extends StatelessWidget {
  final WeekModel week;

  const SessionDetailPage({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ManuscriptColors.parchment,
      appBar: AppBar(
        backgroundColor: ManuscriptColors.parchment,
        elevation: 0,
        foregroundColor: ManuscriptColors.darkBrown,
        title: Text(week.title, style: ManuscriptTextStyles.cardTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Phase 2 destination for "${week.title}" coming soon.',
            textAlign: TextAlign.center,
            style: ManuscriptTextStyles.pageSubtitle,
          ),
        ),
      ),
    );
  }
}
