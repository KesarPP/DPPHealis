import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../main.dart';
class RiskAssessmentResultScreen extends StatelessWidget {
  final int age;
  final bool isMan;
  final double waist;
  final double height; // in inches
  final double weight; // in kg
  final int parentDiabetic;
  final int siblingDiabetic;
  final int hasHighBP;
  final int prescribedBPMedication;
  final int exerciseLevel;

  const RiskAssessmentResultScreen({
    super.key,
    required this.age,
    required this.isMan,
    required this.waist,
    required this.height,
    required this.weight,
    required this.parentDiabetic,
    required this.siblingDiabetic,
    required this.hasHighBP,
    required this.prescribedBPMedication,
    required this.exerciseLevel,
  });

  // Calculate IDRS Score
  int get idrsScore {
    int score = 0;

    // 1. Age Score
    if (age < 35) {
      score += 0;
    } else if (age < 50) {
      score += 20;
    } else {
      score += 30;
    }

    // 2. Waist Score
    if (isMan) {
      if (waist < 90) {
        score += 0;
      } else if (waist < 100) {
        score += 10;
      } else {
        score += 20;
      }
    } else {
      if (waist < 80) {
        score += 0;
      } else if (waist < 90) {
        score += 10;
      } else {
        score += 20;
      }
    }

    // 3. Exercise Score
    if (exerciseLevel == 1) {
      score += 0;
    } else if (exerciseLevel == 2) {
      score += 20;
    } else {
      score += 30;
    }

    // 4. Family History Score
    if (parentDiabetic == 1 && siblingDiabetic == 1) {
      score += 20;
    } else if (parentDiabetic == 1 || siblingDiabetic == 1) {
      score += 10;
    } else {
      score += 0;
    }

    return score;
  }

  // Risk Classification
  String get riskCategory {
    final score = idrsScore;
    if (score < 30) {
      return 'Low Risk';
    }
    if (score <= 50) {
      return 'Moderate Risk';
    }
    return 'High Risk';
  }

  Color get riskColor {
    final score = idrsScore;
    if (score < 30) {
      return GelatoTheme.green;
    }
    if (score <= 50) {
      return GelatoTheme.yellow;
    }
    return GelatoTheme.pink;
  }

  Color get riskDarkColor {
    final score = idrsScore;
    if (score < 30) {
      return GelatoTheme.greenDark;
    }
    if (score <= 50) {
      return GelatoTheme.yellowDark;
    }
    return GelatoTheme.pinkDark;
  }

  String get riskDescription {
    final score = idrsScore;
    if (score < 30) {
      return 'Your score is low! Keep maintaining physical activity and a healthy diet to stay in this bracket.';
    }
    if (score <= 50) {
      return 'Moderate risk detected. Incorporating more daily exercise and monitoring sugar intake is recommended.';
    }
    return 'High risk detected. It is highly recommended that you consult a healthcare clinician and check fasting blood glucose levels.';
  }

  // Calculate BMI
  double get bmi {
    if (height <= 0 || weight <= 0) {
      return 0.0;
    }
    // Height conversion: inches to meters
    final heightInMeters = (height * 2.54) / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String get bmiCategory {
    final val = bmi;
    if (val <= 0) {
      return 'N/A';
    }
    if (val < 18.5) {
      return 'Underweight';
    }
    if (val < 25.0) {
      return 'Normal Weight';
    }
    if (val < 30.0) {
      return 'Overweight';
    }
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    final calculatedScore = idrsScore;

    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        backgroundColor: GelatoTheme.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: GelatoTheme.purpleDark,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'IDRS Assessment',
              style: TextStyle(
                color: GelatoTheme.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stepper Row
                    const _RiskStepper(activeStep: 4),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 12),

                    // Screen Title
                    const Center(
                      child: Text(
                        'Your Risk Profile (Step 4/7)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Score Card
                    _buildScoreCard(calculatedScore),
                    const SizedBox(height: 20),

                    // Breakdown Title
                    const Text(
                      'Score Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Breakdown Items
                    _buildBreakdownList(),
                    const SizedBox(height: 20),

                    // Additional Health Metrics Card
                    const Text(
                      'Other Health Indicators',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildHealthMetricsCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom Action Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              decoration: const BoxDecoration(
                color: GelatoTheme.bg,
                border: Border(top: BorderSide(color: Colors.black, width: 2.0)),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 0,
                          offset: const Offset(3.5, 3.5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainShell(),
                          ),
                          (route) => false,
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue to Dashboard',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.check_circle_outline, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Edit Questionnaire Answers',
                      style: TextStyle(
                        color: GelatoTheme.textLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildScoreCard(int score) {
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

  Widget _buildBreakdownList() {
    // 1. Age Points
    int ageScore = 0;
    if (age < 35) {
      ageScore = 0;
    } else if (age < 50) {
      ageScore = 20;
    } else {
      ageScore = 30;
    }

    // 2. Waist Points
    int waistScore = 0;
    if (isMan) {
      if (waist < 90) {
        waistScore = 0;
      } else if (waist < 100) {
        waistScore = 10;
      } else {
        waistScore = 20;
      }
    } else {
      if (waist < 80) {
        waistScore = 0;
      } else if (waist < 90) {
        waistScore = 10;
      } else {
        waistScore = 20;
      }
    }

    // 3. Exercise Points
    int exerciseScore = 0;
    String exerciseLabel = '';
    if (exerciseLevel == 1) {
      exerciseScore = 0;
      exerciseLabel = 'Regular vigorous';
    } else if (exerciseLevel == 2) {
      exerciseScore = 20;
      exerciseLabel = 'Mild/occasional';
    } else {
      exerciseScore = 30;
      exerciseLabel = 'Sedentary';
    }

    // 4. Family Points
    int familyScore = 0;
    String familyLabel = '';
    if (parentDiabetic == 1 && siblingDiabetic == 1) {
      familyScore = 20;
      familyLabel = 'Parents & Siblings';
    } else if (parentDiabetic == 1 || siblingDiabetic == 1) {
      familyScore = 10;
      familyLabel = 'One relative';
    } else {
      familyScore = 0;
      familyLabel = 'None';
    }

    return _buildCard(
      child: Column(
        children: [
          _buildBreakdownRow(
            icon: Icons.cake_rounded,
            color: GelatoTheme.yellow,
            title: 'Age Metric',
            value: '$age years',
            points: ageScore,
          ),
          const Divider(color: Colors.black12),
          _buildBreakdownRow(
            icon: Icons.straighten_rounded,
            color: GelatoTheme.blue,
            title: 'Waist Size',
            value: '${waist.toStringAsFixed(0)} cm (${isMan ? 'Man' : 'Woman'})',
            points: waistScore,
          ),
          const Divider(color: Colors.black12),
          _buildBreakdownRow(
            icon: Icons.directions_run_rounded,
            color: GelatoTheme.green,
            title: 'Physical Activity',
            value: exerciseLabel,
            points: exerciseScore,
          ),
          const Divider(color: Colors.black12),
          _buildBreakdownRow(
            icon: Icons.people_rounded,
            color: GelatoTheme.purple,
            title: 'Diabetic Family History',
            value: familyLabel,
            points: familyScore,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required int points,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Icon(icon, color: GelatoTheme.textDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: GelatoTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: points > 0 ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 1.0),
            ),
            child: Text(
              '+$points pts',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: points > 0 ? Colors.red[900] : Colors.green[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsCard() {
    final bmiVal = bmi;
    final bmiCat = bmiCategory;
    final hasBp = hasHighBP == 1;
    final hasBpPrescribed = prescribedBPMedication == 1;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_weight_outlined, color: GelatoTheme.orangeDark, size: 20),
              const SizedBox(width: 8),
              Text(
                'BMI: ${bmiVal.toStringAsFixed(1)} ($bmiCat)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: GelatoTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Based on height: ${height.toStringAsFixed(1)} inches, weight: ${weight.toStringAsFixed(0)} kg',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: GelatoTheme.textLight,
            ),
          ),
          const Divider(color: Colors.black12, height: 24),
          Row(
            children: [
              const Icon(Icons.favorite_border_rounded, color: GelatoTheme.pinkDark, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasBp
                      ? 'Hypertension: History of High BP${hasBpPrescribed ? ' (Prescribed Meds)' : ''}'
                      : 'Hypertension: No history of High BP',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Stepper widget repeated for local module file compilation simplicity or reusability
class _RiskStepper extends StatelessWidget {
  final int activeStep;

  const _RiskStepper({required this.activeStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(13, (index) {
        if (index.isEven) {
          final stepNum = (index ~/ 2) + 1;
          final isCompleted = stepNum < activeStep;
          final isActive = stepNum == activeStep;

          if (isCompleted) {
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: GelatoTheme.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Icon(
                Icons.check,
                color: GelatoTheme.greenDark,
                size: 16,
              ),
            );
          } else if (isActive) {
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: GelatoTheme.purple,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              alignment: Alignment.center,
              child: Text(
                '$stepNum',
                style: const TextStyle(
                  color: GelatoTheme.purpleDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            );
          } else {
            return Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.0),
              ),
              alignment: Alignment.center,
              child: Text(
                '$stepNum',
                style: const TextStyle(
                  color: GelatoTheme.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            );
          }
        } else {
          final stepBefore = index ~/ 2 + 1;
          final isCompleted = stepBefore < activeStep;

          return Container(
            width: 14,
            height: 2,
            color: isCompleted ? Colors.black : Colors.black26,
          );
        }
      }),
    );
  }
}
