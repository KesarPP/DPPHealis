import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class TodayActivityScore extends StatelessWidget {
  const TodayActivityScore({super.key});

  @override
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
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '78',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: GelatoTheme.purpleDark,
                  height: 1.0,
                ),
              ),
              Text(
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
            child: const LinearProgressIndicator(
              value: 0.78,
              minHeight: 10,
              backgroundColor: Color(0xFFEFEAEA),
              valueColor: AlwaysStoppedAnimation(GelatoTheme.purpleDark),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You're ahead of 68% of your weekly average.",
            style: TextStyle(
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
