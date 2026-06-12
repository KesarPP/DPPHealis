import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart'; // MainShell
import 'risk_assessment_step2_screen.dart';
import '../data/gelato_theme.dart';

class RiskAssessmentStep1Screen extends StatefulWidget {
  const RiskAssessmentStep1Screen({super.key});

  @override
  State<RiskAssessmentStep1Screen> createState() => _RiskAssessmentStep1ScreenState();
}

class _RiskAssessmentStep1ScreenState extends State<RiskAssessmentStep1Screen> {
  int _age = 30;
  bool _isMan = true; // true = Man, false = Woman
  final _heightController = TextEditingController(text: '0');
  final _weightController = TextEditingController(text: '0');
  final _waistController = TextEditingController(text: '0');

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _waistController.dispose();
    super.dispose();
  }

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
                    const _RiskStepper(activeStep: 2),
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
                          'Personal Data',
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
                        'Risk Assessment (Step 2/7)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Tell us a bit about your body.',
                        style: TextStyle(
                          fontSize: 14,
                          color: GelatoTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card 1: Age
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '1. What is your current age?',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: GelatoTheme.textDark,
                                ),
                              ),
                              Text(
                                'Input',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: GelatoTheme.yellowDark,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInputRow(
                            color: GelatoTheme.yellow,
                            label: 'Age (Years)',
                            valueWidget: Row(
                              children: [
                                _buildCircleButton(
                                  icon: Icons.remove,
                                  onPressed: () {
                                    if (_age > 1) {
                                      setState(() => _age--);
                                    }
                                  },
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '$_age',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: GelatoTheme.textDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _buildCircleButton(
                                  icon: Icons.add,
                                  onPressed: () {
                                    setState(() => _age++);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Gender
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '2. Are you a man or a woman?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGenderButton(
                                  label: 'Man',
                                  icon: FontAwesomeIcons.mars,
                                  isSelected: _isMan,
                                  onTap: () => setState(() => _isMan = true),
                                  activeColor: GelatoTheme.blue,
                                  darkColor: GelatoTheme.blueDark,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildGenderButton(
                                  label: 'Woman',
                                  icon: FontAwesomeIcons.venus,
                                  isSelected: !_isMan,
                                  onTap: () => setState(() => _isMan = false),
                                  activeColor: GelatoTheme.pink,
                                  darkColor: GelatoTheme.pinkDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 3: Height
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '3. What is your height?',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: GelatoTheme.textDark,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.straighten,
                                    size: 14,
                                    color: GelatoTheme.blueDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Measurement',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: GelatoTheme.blueDark,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInputRow(
                            color: GelatoTheme.blue,
                            label: 'Height (inches)',
                            valueWidget: SizedBox(
                              width: 80,
                              child: TextField(
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: GelatoTheme.textDark,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 4: Weight
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '4. What is your current weight?',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: GelatoTheme.textDark,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.monitor_weight_outlined,
                                    size: 14,
                                    color: GelatoTheme.orangeDark,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Weight',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: GelatoTheme.orangeDark,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInputRow(
                            color: GelatoTheme.orange,
                            label: 'Weight (kg)',
                            valueWidget: SizedBox(
                              width: 80,
                              child: TextField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: GelatoTheme.textDark,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 5: Waist Circumference
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '5. What is your waist circumference?',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: GelatoTheme.textDark,
                                ),
                              ),
                              const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: GelatoTheme.greenDark,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildInputRow(
                            color: GelatoTheme.green,
                            label: 'Waist Circumference',
                            valueWidget: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: TextField(
                                    controller: _waistController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: GelatoTheme.textDark,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'cm',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: GelatoTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: CustomPaint(
                              size: const Size(200, 180),
                              painter: WaistMeasurementPainter(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              'Measure horizontally at the highest point of your belly button.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: GelatoTheme.textLight,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom Action Area
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: GelatoTheme.bg,
                border: Border(top: BorderSide(color: Colors.black, width: 2.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RiskAssessmentStep2Screen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GelatoTheme.purple,
                        foregroundColor: GelatoTheme.purpleDark,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.black, width: 2.0),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
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
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainShell(),
                          ),
                        );
                      },
                      child: const Text(
                        'Skip for now',
                        style: TextStyle(
                          color: GelatoTheme.textLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
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

  Widget _buildInputRow({required String label, required Widget valueWidget, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
            ),
          ),
          valueWidget,
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    required FaIconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
    required Color darkColor,
  }) {
    final borderColor = Colors.black;
    final bgColor = isSelected ? activeColor : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 28,
              color: isSelected ? darkColor : GelatoTheme.textLight,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isSelected ? darkColor : GelatoTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── CUSTOM RISK STEPPER ──────────────────────────────────────────────

class _RiskStepper extends StatelessWidget {
  final int activeStep; // 1 to 7

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

// ─── WAIST MEASUREMENT PAINTER ──────────────────────────────────────────

class WaistMeasurementPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final double w = size.width;
    final double h = size.height;

    // Center coordinates
    final double cx = w / 2;

    // Draw Head & Neck (outline / skin color)
    paint.color = const Color(0xFFE2E8F0);
    // Draw neck
    final neckPath = Path()
      ..moveTo(cx - 15, h * 0.15)
      ..lineTo(cx + 15, h * 0.15)
      ..lineTo(cx + 12, h * 0.28)
      ..lineTo(cx - 12, h * 0.28)
      ..close();
    canvas.drawPath(neckPath, paint);

    // Draw T-Shirt (Blue)
    paint.color = const Color(0xFF93C5FD);
    final shirtPath = Path()
      ..moveTo(cx - 30, h * 0.28) // neck bottom-left
      ..quadraticBezierTo(cx, h * 0.30, cx + 30, h * 0.28) // neck collar curve
      ..lineTo(cx + 55, h * 0.33) // right shoulder
      ..lineTo(cx + 68, h * 0.45) // right sleeve end top
      ..lineTo(cx + 52, h * 0.52) // right sleeve end bottom
      ..lineTo(cx + 42, h * 0.46) // armpit right
      ..lineTo(cx + 38, h * 0.70) // right waist shirt end
      ..lineTo(cx - 38, h * 0.70) // left waist shirt end
      ..lineTo(cx - 42, h * 0.46) // armpit left
      ..lineTo(cx - 52, h * 0.52) // left sleeve end bottom
      ..lineTo(cx - 68, h * 0.45) // left sleeve end top
      ..lineTo(cx - 55, h * 0.33) // left shoulder
      ..close();
    canvas.drawPath(shirtPath, paint);

    // T-shirt Collar Highlight (White)
    paint.color = Colors.white;
    final collarPath = Path()
      ..moveTo(cx - 22, h * 0.28)
      ..quadraticBezierTo(cx, h * 0.34, cx + 22, h * 0.28)
      ..quadraticBezierTo(cx, h * 0.30, cx - 22, h * 0.28)
      ..close();
    canvas.drawPath(collarPath, paint);

    // Draw Hands (Skin tone, simple paths resting on waist)
    paint.color = const Color(0xFFE2E8F0);
    
    // Left arm/hand
    final leftArm = Path()
      ..moveTo(cx - 50, h * 0.50) // from sleeve
      ..quadraticBezierTo(cx - 65, h * 0.60, cx - 45, h * 0.72)
      ..quadraticBezierTo(cx - 38, h * 0.74, cx - 35, h * 0.70) // resting
      ..quadraticBezierTo(cx - 45, h * 0.60, cx - 44, h * 0.48)
      ..close();
    canvas.drawPath(leftArm, paint);

    // Right arm/hand
    final rightArm = Path()
      ..moveTo(cx + 50, h * 0.50)
      ..quadraticBezierTo(cx + 65, h * 0.60, cx + 45, h * 0.72)
      ..quadraticBezierTo(cx + 38, h * 0.74, cx + 35, h * 0.70)
      ..quadraticBezierTo(cx + 45, h * 0.60, cx + 44, h * 0.48)
      ..close();
    canvas.drawPath(rightArm, paint);

    // Draw Pants (Grey)
    paint.color = const Color(0xFF64748B);
    final pantsPath = Path()
      ..moveTo(cx - 38, h * 0.70) // waist left
      ..lineTo(cx + 38, h * 0.70) // waist right
      ..lineTo(cx + 34, h * 0.95) // right hip
      ..lineTo(cx - 34, h * 0.95) // left hip
      ..close();
    canvas.drawPath(pantsPath, paint);

    // Draw Waist Measuring Tape (Mint Green / Teal wrapping around)
    final tapePaint = Paint()
      ..color = const Color(0xFF34D399) // Mint Green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    final tapePath = Path()
      ..moveTo(cx - 42, h * 0.68)
      ..quadraticBezierTo(cx, h * 0.73, cx + 42, h * 0.68)
      ..quadraticBezierTo(cx + 46, h * 0.73, cx + 38, h * 0.82)
      ..lineTo(cx + 32, h * 0.88);
    canvas.drawPath(tapePath, tapePaint);

    // Extra wrapping hang of the tape on the right side
    final tapeHang = Path()
      ..moveTo(cx + 38, h * 0.72)
      ..quadraticBezierTo(cx + 48, h * 0.80, cx + 40, h * 0.92);
    canvas.drawPath(tapeHang, tapePaint);

    // Draw Dashed Measurement Marks on Tape (White/Black)
    final markPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 9; i++) {
      final double mx = cx - 35 + i * 9;
      final double my = h * 0.705;
      canvas.drawLine(Offset(mx, my - 3), Offset(mx, my + 3), markPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
