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
  final _ageController = TextEditingController(text: '30');
  bool _isMan = true; // true = Man, false = Woman
  String _heightUnit = 'inches'; // 'cm', 'inches', 'ft_in'
  final _heightCmController = TextEditingController(text: '170');
  final _heightInchesController = TextEditingController(text: '67');
  final _heightFtController = TextEditingController(text: '5');
  final _heightInController = TextEditingController(text: '7');
  final _weightController = TextEditingController(text: '0');
  final _waistController = TextEditingController(text: '0');

  @override
  void dispose() {
    _ageController.dispose();
    _heightCmController.dispose();
    _heightInchesController.dispose();
    _heightFtController.dispose();
    _heightInController.dispose();
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
                              const Expanded(
                                child: Text(
                                  '1. What is your current age?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: GelatoTheme.textDark,
                                  ),
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
                                    final val = int.tryParse(_ageController.text) ?? 30;
                                    if (val > 1) {
                                      _ageController.text = '${val - 1}';
                                    }
                                  },
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                    controller: _ageController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
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
                                const SizedBox(width: 16),
                                _buildCircleButton(
                                  icon: Icons.add,
                                  onPressed: () {
                                    final val = int.tryParse(_ageController.text) ?? 30;
                                    _ageController.text = '${val + 1}';
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
                              const Expanded(
                                child: Text(
                                  '3. What is your height?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: GelatoTheme.textDark,
                                  ),
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
                          Row(
                            children: [
                              _buildUnitTab('inches', 'Inches'),
                              const SizedBox(width: 8),
                              _buildUnitTab('cm', 'cm'),
                              const SizedBox(width: 8),
                              _buildUnitTab('ft_in', 'Feet & Inches'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_heightUnit == 'inches')
                            _buildInputRow(
                              color: GelatoTheme.blue,
                              label: 'Height',
                              valueWidget: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: TextField(
                                      controller: _heightInchesController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                                    'in',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: GelatoTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (_heightUnit == 'cm')
                            _buildInputRow(
                              color: GelatoTheme.blue,
                              label: 'Height',
                              valueWidget: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: TextField(
                                      controller: _heightCmController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                            )
                          else if (_heightUnit == 'ft_in')
                            _buildInputRow(
                              color: GelatoTheme.blue,
                              label: 'Height',
                              valueWidget: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 35,
                                    child: TextField(
                                      controller: _heightFtController,
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
                                    'ft',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: GelatoTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 35,
                                    child: TextField(
                                      controller: _heightInController,
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
                                    'in',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: GelatoTheme.textDark,
                                    ),
                                  ),
                                ],
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
                              const Expanded(
                                child: Text(
                                  '4. What is your current weight?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: GelatoTheme.textDark,
                                  ),
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
                              const Expanded(
                                child: Text(
                                  '5. What is your waist circumference?',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: GelatoTheme.textDark,
                                  ),
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
                            child: Image.asset(
                              'assets/images/waist_measurement.png',
                              height: 180,
                              fit: BoxFit.contain,
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
                        final ageVal = int.tryParse(_ageController.text) ?? 30;
                        final waistVal = double.tryParse(_waistController.text) ?? 0.0;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RiskAssessmentStep2Screen(
                              age: ageVal,
                              isMan: _isMan,
                              waist: waistVal,
                            ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onHeightUnitChanged(String newUnit) {
    if (_heightUnit == newUnit) return;

    double inches = 0.0;
    
    // Parse current value to inches
    if (_heightUnit == 'cm') {
      final cm = double.tryParse(_heightCmController.text) ?? 0.0;
      inches = cm / 2.54;
    } else if (_heightUnit == 'inches') {
      inches = double.tryParse(_heightInchesController.text) ?? 0.0;
    } else if (_heightUnit == 'ft_in') {
      final ft = double.tryParse(_heightFtController.text) ?? 0.0;
      final inchVal = double.tryParse(_heightInController.text) ?? 0.0;
      inches = (ft * 12) + inchVal;
    }

    // Convert and set new unit values
    setState(() {
      _heightUnit = newUnit;
      if (newUnit == 'cm') {
        final cmVal = inches * 2.54;
        _heightCmController.text = cmVal == 0.0 ? '0' : cmVal.toStringAsFixed(1);
      } else if (newUnit == 'inches') {
        _heightInchesController.text = inches == 0.0 ? '0' : inches.toStringAsFixed(1);
      } else if (newUnit == 'ft_in') {
        final totalInches = inches.round();
        final ft = totalInches ~/ 12;
        final inchVal = totalInches % 12;
        _heightFtController.text = '$ft';
        _heightInController.text = '$inchVal';
      }
    });
  }

  Widget _buildUnitTab(String unit, String label) {
    final isSelected = _heightUnit == unit;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onHeightUnitChanged(unit),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? GelatoTheme.blue : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: isSelected ? 2.0 : 1.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: GelatoTheme.blueDark.withValues(alpha: 0.3),
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isSelected ? GelatoTheme.textDark : GelatoTheme.textLight,
            ),
          ),
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
