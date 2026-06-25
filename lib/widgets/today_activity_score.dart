import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class TodayActivityScore extends StatelessWidget {
  final int score;
  final String feedbackText;

  const TodayActivityScore({
    super.key,
    required this.score,
    required this.feedbackText,
  });
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF6F2FA), // Light purple tint
            Colors.white,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: GelatoTheme.purpleDark,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Today's Activity Score",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: GelatoTheme.purpleDark,
                  height: 1.0,
                ),
              ),
              const Text(
                '/100',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: GelatoTheme.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score / 100.0,
              minHeight: 10,
              backgroundColor: const Color(0xFFEFEAEA),
              valueColor: const AlwaysStoppedAnimation(GelatoTheme.purpleDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feedbackText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: GelatoTheme.textDark,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
