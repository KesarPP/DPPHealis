import 'package:flutter/material.dart';
import '../models/week_model.dart';
import '../theme/manuscript_theme.dart';
import '../widgets/ancient_book_background.dart';

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
      body: AncientBookBackground(
        backgroundAsset: 'assets/images/session_timeline/book_background_open.png',
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ManuscriptColors.darkWood),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        week.title,
                        style: ManuscriptTextStyles.cardTitle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // balance back button
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: ManuscriptColors.parchment.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: ManuscriptColors.gold, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ManuscriptColors.gold.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_stories_rounded, color: ManuscriptColors.darkWood, size: 40),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          week.title,
                          textAlign: TextAlign.center,
                          style: ManuscriptTextStyles.pageTitle.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Phase 2 destination for "${week.title}" coming soon.\nThis chapter will feature interactive lessons, video guidance, and daily quests.',
                          textAlign: TextAlign.center,
                          style: ManuscriptTextStyles.pageSubtitle,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
