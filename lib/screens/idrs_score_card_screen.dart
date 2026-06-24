import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../data/gelato_theme.dart';
import 'risk_assessment_step1_screen.dart';

class IdrsScoreCardScreen extends StatelessWidget {
  const IdrsScoreCardScreen({super.key});

  String get riskCategory {
    final score = AppState.idrsScore;
    if (score < 30) return 'Low Risk';
    if (score < 60) return 'Moderate Risk';
    return 'High Risk';
  }

  Color get riskColor {
    final score = AppState.idrsScore;
    if (score < 30) return GelatoTheme.green;
    if (score < 60) return GelatoTheme.yellow;
    return GelatoTheme.pink;
  }

  Color get riskDarkColor {
    final score = AppState.idrsScore;
    if (score < 30) return GelatoTheme.greenDark;
    if (score < 60) return GelatoTheme.yellowDark;
    return GelatoTheme.pinkDark;
  }

  String get riskDescription {
    final score = AppState.idrsScore;
    if (score < 30) {
      return 'Your score is low! Keep maintaining physical activity and a healthy diet to stay in this bracket.';
    }
    if (score < 60) {
      return 'Moderate risk detected. Incorporating more daily exercise and monitoring sugar intake is recommended.';
    }
    return 'High risk detected. It is highly recommended that you consult a healthcare clinician and check fasting blood glucose levels.';
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
    final score = AppState.idrsScore;
    final pillColor = riskColor;
    final pillTextDark = riskDarkColor;

    return _buildCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: pillColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL RISK SCORE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: GelatoTheme.textLight,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: pillColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Text(
                        riskCategory,
                        style: TextStyle(
                          color: pillTextDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.black12, thickness: 1.5),
          const SizedBox(height: 8),
          Text(
            riskDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: GelatoTheme.textDark,
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
            Icon(Icons.analytics_outlined, color: GelatoTheme.purpleDark, size: 28),
            SizedBox(width: 8),
            Text(
              'IDRS Score Card',
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
              if (!AppState.hasIdrsResult) ...[
                const SizedBox(height: 40),
                const Icon(Icons.assignment_late, size: 80, color: GelatoTheme.textLight),
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
                  'You have not completed your IDRS risk assessment yet.',
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
                        MaterialPageRoute(builder: (_) => const RiskAssessmentStep1Screen()),
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
                      'Assessment Results',
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
