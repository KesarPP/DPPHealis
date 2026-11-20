import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class AppTourCompletionDialog extends StatelessWidget {
  final VoidCallback onFinish;

  const AppTourCompletionDialog({
    super.key,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Celebration Badge Icon (Clean, no mascot)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: GelatoTheme.yellow,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.emoji_events, size: 44, color: GelatoTheme.yellowDark),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "You're All Set! 🎉",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: GelatoTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "You've explored all the features of your Diabetes Prevention Program!\n\nNow it's time to put your knowledge into action. Stay consistent, complete your weekly activities, and celebrate every little achievement along the way.\n\nYour journey to a healthier you starts NOW! 💚",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: GelatoTheme.textDark,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onFinish,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: GelatoTheme.green,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Explore My App',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
