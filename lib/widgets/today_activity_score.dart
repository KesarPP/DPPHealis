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
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.centerLeft,
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                color: GelatoTheme.purpleDark,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "Today's Activity Score",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: GelatoTheme.purpleDark,
                  height: 1.0,
                ),
              ),
              const Text(
                '/100',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: GelatoTheme.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100.0,
              minHeight: 6,
              backgroundColor: const Color(0xFFEFEAEA),
              valueColor: const AlwaysStoppedAnimation(GelatoTheme.purpleDark),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feedbackText,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: GelatoTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
