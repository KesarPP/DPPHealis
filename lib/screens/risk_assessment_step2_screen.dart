import 'package:flutter/material.dart';
import '../main.dart'; // MainShell
import '../data/gelato_theme.dart';

class RiskAssessmentStep2Screen extends StatefulWidget {
  const RiskAssessmentStep2Screen({super.key});

  @override
  State<RiskAssessmentStep2Screen> createState() => _RiskAssessmentStep2ScreenState();
}

class _RiskAssessmentStep2ScreenState extends State<RiskAssessmentStep2Screen> {
  // 1 = Yes, 2 = No, 3 = Don't Know
  int _parentDiabetic = 2; // Default to 'No'
  int _siblingDiabetic = 2; // Default to 'No'
  
  // 1 = Yes, 2 = No
  int _hasHighBP = 1; // Default to 'Yes' to show follow-up as in image
  int _prescribedBPMedication = 2; // Default to 'No' in follow-up

  // 1 = Regular, 2 = Mild/occasional, 3 = No exercise
  int _exerciseLevel = 2; // Default to 'Mild/occasional' as in image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        backgroundColor: GelatoTheme.bg,
        elevation: 0,
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
                    const _RiskStepper(activeStep: 3),
                    const SizedBox(height: 16),

                    // Section Indicator Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: GelatoTheme.purple.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1.0),
                        ),
                        child: const Text(
                          'Health History',
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
                        'Risk Assessment (Step 3/7)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card 6: Mother/Father Diabetic
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '6. Is your mother or father prediabetic or diabetic?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSegmentedControl3(
                            value: _parentDiabetic,
                            label1: 'Yes',
                            label2: 'No',
                            label3: "Don't Know",
                            onChanged: (val) => setState(() => _parentDiabetic = val),
                            color: GelatoTheme.blue,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 7: Brother/Sister Diabetic
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '7. Is your brother or sister prediabetic or diabetic?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSegmentedControl3(
                            value: _siblingDiabetic,
                            label1: 'Yes',
                            label2: 'No',
                            label3: "Don't Know",
                            onChanged: (val) => setState(() => _siblingDiabetic = val),
                            color: GelatoTheme.blue,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 8: High Blood Pressure
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '8. Do you have High Blood Pressure?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildSegmentedControl2(
                            value: _hasHighBP,
                            label1: 'Yes',
                            label2: 'No',
                            onChanged: (val) => setState(() => _hasHighBP = val),
                            color: GelatoTheme.blue,
                          ),
                          if (_hasHighBP == 1) ...[
                            const SizedBox(height: 16),
                            // Nested Follow-up card
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: GelatoTheme.pink,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.black, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: GelatoTheme.pink.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'FOLLOW-UP',
                                    style: TextStyle(
                                      color: GelatoTheme.pinkDark,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Are you currently prescribed drugs/medication for High BP?',
                                    style: TextStyle(
                                      color: GelatoTheme.textDark,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildFollowUpButton(
                                          label: 'Yes',
                                          isSelected: _prescribedBPMedication == 1,
                                          onTap: () => setState(() => _prescribedBPMedication = 1),
                                          activeColor: GelatoTheme.pink,
                                          darkColor: GelatoTheme.pinkDark,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildFollowUpButton(
                                          label: 'No',
                                          isSelected: _prescribedBPMedication == 2,
                                          onTap: () => setState(() => _prescribedBPMedication = 2),
                                          activeColor: GelatoTheme.pink,
                                          darkColor: GelatoTheme.pinkDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 9: Exercise
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '9. Do you ever exercise or exert yourself physically?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildExerciseOption(
                            value: 1,
                            label: 'Regular vigorous exercise',
                            icon: Icons.directions_run,
                            color: GelatoTheme.green,
                            darkColor: GelatoTheme.greenDark,
                          ),
                          const SizedBox(height: 12),
                          _buildExerciseOption(
                            value: 2,
                            label: 'Mild/occasional exercise',
                            icon: Icons.directions_walk,
                            color: GelatoTheme.green,
                            darkColor: GelatoTheme.greenDark,
                          ),
                          const SizedBox(height: 12),
                          _buildExerciseOption(
                            value: 3,
                            label: 'No exercise / Sedentary lifestyle',
                            icon: Icons.single_bed_outlined,
                            color: GelatoTheme.green,
                            darkColor: GelatoTheme.greenDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Large Middle Button: Calculate Risk Score
                    Container(
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
                          // Action to calculate risk score
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Calculating your risk score...'),
                              backgroundColor: GelatoTheme.purpleDark,
                            ),
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
                              'Calculate Risk Score',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, size: 16, color: GelatoTheme.textLight),
                        label: const Text(
                          'Go Back to Metrics',
                          style: TextStyle(
                            color: GelatoTheme.textLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
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
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, size: 16, color: GelatoTheme.textLight),
                    label: const Text(
                      'Go Back',
                      style: TextStyle(
                        color: GelatoTheme.textLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainShell(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GelatoTheme.purple,
                        foregroundColor: GelatoTheme.purpleDark,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.black, width: 2.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
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

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: child,
    );
  }

  // Segmented control with 3 options: Yes, No, Don't Know
  Widget _buildSegmentedControl3({
    required int value,
    required String label1,
    required String label2,
    required String label3,
    required ValueChanged<int> onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Light gray background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              label: label1,
              isSelected: value == 1,
              onTap: () => onChanged(1),
              color: color,
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              label: label2,
              isSelected: value == 2,
              onTap: () => onChanged(2),
              color: color,
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              label: label3,
              isSelected: value == 3,
              onTap: () => onChanged(3),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Segmented control with 2 options: Yes, No
  Widget _buildSegmentedControl2({
    required int value,
    required String label1,
    required String label2,
    required ValueChanged<int> onChanged,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              label: label1,
              isSelected: value == 1,
              onTap: () => onChanged(1),
              color: color,
            ),
          ),
          Expanded(
            child: _buildSegmentButton(
              label: label2,
              isSelected: value == 2,
              onTap: () => onChanged(2),
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.black, width: 1.5) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? GelatoTheme.textDark : GelatoTheme.textLight,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required Color darkColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? darkColor : GelatoTheme.textLight,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseOption({
    required int value,
    required String label,
    required IconData icon,
    required Color color,
    required Color darkColor,
  }) {
    final isSelected = _exerciseLevel == value;
    final borderColor = Colors.black;
    final bgColor = isSelected ? color : Colors.white;

    return GestureDetector(
      onTap: () => setState(() => _exerciseLevel = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? darkColor : GelatoTheme.textDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              icon,
              color: isSelected ? darkColor : GelatoTheme.textLight,
              size: 20,
            ),
          ],
        ),
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
