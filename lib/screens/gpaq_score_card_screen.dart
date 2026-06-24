import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/gelato_theme.dart';
import 'gpaq_step1_screen.dart';

class GpaqScoreCardScreen extends StatelessWidget {
  const GpaqScoreCardScreen({super.key});

  Color get levelBg {
    final level = AppState.gpaqLevel;
    if (level == 'High Activity') return GelatoTheme.green;
    if (level == 'Moderate Activity') return GelatoTheme.yellow;
    return GelatoTheme.pink;
  }

  Color get levelDark {
    final level = AppState.gpaqLevel;
    if (level == 'High Activity') return GelatoTheme.greenDark;
    if (level == 'Moderate Activity') return GelatoTheme.yellowDark;
    return GelatoTheme.pinkDark;
  }

  IconData get levelIcon {
    final level = AppState.gpaqLevel;
    if (level == 'High Activity') return Icons.bolt;
    if (level == 'Moderate Activity') return Icons.directions_run;
    return Icons.warning_amber_rounded;
  }

  String get levelDescription {
    final level = AppState.gpaqLevel;
    if (level == 'High Activity') {
      return 'Outstanding physical activity level! Your high MET-minutes significantly lower your insulin resistance and diabetes risk.';
    }
    if (level == 'Moderate Activity') {
      return 'Healthy level of activity! You meet standard physical activity targets, helping maintain blood sugar balance.';
    }
    return 'Sedentary or low activity. Increasing daily physical activity will help you manage and lower your prediabetes risk.';
  }

  Widget _buildCard({required Widget child, Color color = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: child,
    );
  }

  Widget _buildScoreCard() {
    final metMinutes = AppState.gpaqMetMinutes;
    final level = AppState.gpaqLevel;

    return _buildCard(
      child: Column(
        children: [
          const Text(
            'WEEKLY PHYSICAL ACTIVITY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textLight,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$metMinutes',
            style: const TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
              height: 1.0,
            ),
          ),
          const Text(
            'MET-minutes / week',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: GelatoTheme.textLight,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: levelBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: levelBg.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(levelIcon, color: levelDark, size: 18),
                const SizedBox(width: 6),
                Text(
                  level,
                  style: TextStyle(
                    color: levelDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            levelDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: GelatoTheme.textDark,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_run, color: GelatoTheme.purpleDark, size: 28),
            SizedBox(width: 8),
            Text(
              'GPAQ Score Card',
              style: TextStyle(
                color: GelatoTheme.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: GelatoTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!AppState.hasGpaqResult) ...[
                const SizedBox(height: 40),
                const Icon(Icons.directions_run, size: 80, color: GelatoTheme.textLight),
                const SizedBox(height: 24),
                const Text(
                  'Assessment Pending',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You have not completed your GPAQ physical activity assessment yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: GelatoTheme.textLight,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(3.5, 3.5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const GPAQStep1Screen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GelatoTheme.purple,
                      foregroundColor: GelatoTheme.purpleDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.black, width: 2.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Take Assessment Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ] else ...[
                // Section Indicator
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: GelatoTheme.purple.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 1.0),
                    ),
                    child: const Text(
                      'Activity Summary',
                      style: TextStyle(
                        color: GelatoTheme.purpleDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildScoreCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
