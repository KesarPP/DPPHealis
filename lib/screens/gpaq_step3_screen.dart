import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import 'gpaq_step4_screen.dart';

class GPAQStep3Screen extends StatefulWidget {
  final bool isFromSignup;
  final bool workVigorous;
  final int workVigorousDays;
  final int workVigorousMinutes;
  final bool workModerate;
  final int workModerateDays;
  final int workModerateMinutes;
  final bool travel;
  final int travelDays;
  final int travelMinutes;

  const GPAQStep3Screen({
    super.key,
    this.isFromSignup = false,
    required this.workVigorous,
    required this.workVigorousDays,
    required this.workVigorousMinutes,
    required this.workModerate,
    required this.workModerateDays,
    required this.workModerateMinutes,
    required this.travel,
    required this.travelDays,
    required this.travelMinutes,
  });

  @override
  State<GPAQStep3Screen> createState() => _GPAQStep3ScreenState();
}

class _GPAQStep3ScreenState extends State<GPAQStep3Screen> {
  bool _recVigorous = false;
  int _recVigorousDays = 3;
  int _recVigorousHours = 1;
  int _recVigorousMins = 0;
  bool _showVigorousHelp = false;

  bool _recModerate = false;
  int _recModerateDays = 3;
  int _recModerateHours = 1;
  int _recModerateMins = 0;
  bool _showModerateHelp = false;

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
              Icons.directions_run_outlined,
              color: GelatoTheme.purpleDark,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'GPAQ Assessment',
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
                    const _RiskStepper(activeStep: 6),
                    const SizedBox(height: 16),

                    // Section Indicator Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: GelatoTheme.green.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1.0),
                        ),
                        child: const Text(
                          'Recreational Activities',
                          style: TextStyle(
                            color: GelatoTheme.greenDark,
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
                        'Risk Assessment (Step 6/7)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card 1: Vigorous Recreation Activity
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '4. Does your recreation, sport or leisure involve vigorous-intensity activity that causes large increases in breathing or heart rate (e.g. running, playing football) for at least 10 minutes continuously?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildHelpToggle(
                            isExpanded: _showVigorousHelp,
                            onTap: () => setState(() => _showVigorousHelp = !_showVigorousHelp),
                          ),
                          if (_showVigorousHelp)
                            _buildHelpContent(
                              color: GelatoTheme.yellow,
                              darkColor: GelatoTheme.yellowDark,
                              title: 'Vigorous Recreation Examples',
                              examples: [
                                'Running, jogging, or fast sprinting',
                                'Playing competitive sports like football, basketball, or singles tennis',
                                'High-intensity aerobics or circuit training',
                                'Fast cycling or mountain biking',
                              ],
                            ),
                          const SizedBox(height: 12),
                          _buildSegmentedControl2(
                            value: _recVigorous ? 1 : 2,
                            label1: 'Yes',
                            label2: 'No',
                            onChanged: (val) => setState(() => _recVigorous = val == 1),
                            color: GelatoTheme.green,
                          ),
                          if (_recVigorous) ...[
                            const SizedBox(height: 16),
                            // Nested details card
                            _buildSubCard(
                              color: GelatoTheme.green,
                              darkColor: GelatoTheme.greenDark,
                              title: 'VIGOROUS RECREATION DETAILS',
                              child: Column(
                                children: [
                                  _buildCounterRow(
                                    label: 'Days per week',
                                    value: _recVigorousDays,
                                    onChanged: (val) => setState(() => _recVigorousDays = val),
                                    min: 1,
                                    max: 7,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDurationRow(
                                    label: 'Time per day',
                                    hours: _recVigorousHours,
                                    mins: _recVigorousMins,
                                    onHoursChanged: (val) => setState(() => _recVigorousHours = val),
                                    onMinsChanged: (val) => setState(() => _recVigorousMins = val),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 2: Moderate Recreation Activity
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '5. Does your recreation, sport or leisure involve moderate-intensity activity that causes small increases in breathing or heart rate (e.g. brisk walking, cycling, swimming) for at least 10 minutes continuously?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildHelpToggle(
                            isExpanded: _showModerateHelp,
                            onTap: () => setState(() => _showModerateHelp = !_showModerateHelp),
                          ),
                          if (_showModerateHelp)
                            _buildHelpContent(
                              color: GelatoTheme.yellow,
                              darkColor: GelatoTheme.yellowDark,
                              title: 'Moderate Recreation Examples',
                              examples: [
                                'Brisk walking, dancing, or active play',
                                'Recreational cycling, moderate swimming, or playing badminton/volleyball',
                                'Practicing dynamic yoga or pilates sessions',
                                'Leisurely sports activities',
                              ],
                            ),
                          const SizedBox(height: 12),
                          _buildSegmentedControl2(
                            value: _recModerate ? 1 : 2,
                            label1: 'Yes',
                            label2: 'No',
                            onChanged: (val) => setState(() => _recModerate = val == 1),
                            color: GelatoTheme.green,
                          ),
                          if (_recModerate) ...[
                            const SizedBox(height: 16),
                            // Nested details card
                            _buildSubCard(
                              color: GelatoTheme.green,
                              darkColor: GelatoTheme.greenDark,
                              title: 'MODERATE RECREATION DETAILS',
                              child: Column(
                                children: [
                                  _buildCounterRow(
                                    label: 'Days per week',
                                    value: _recModerateDays,
                                    onChanged: (val) => setState(() => _recModerateDays = val),
                                    min: 1,
                                    max: 7,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDurationRow(
                                    label: 'Time per day',
                                    hours: _recModerateHours,
                                    mins: _recModerateMins,
                                    onHoursChanged: (val) => setState(() => _recModerateHours = val),
                                    onMinsChanged: (val) => setState(() => _recModerateMins = val),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
                        final recVigorousMins = _recVigorous ? (_recVigorousHours * 60 + _recVigorousMins) : 0;
                        final recModerateMins = _recModerate ? (_recModerateHours * 60 + _recModerateMins) : 0;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GPAQStep4Screen(
                              isFromSignup: widget.isFromSignup,
                              workVigorous: widget.workVigorous,
                              workVigorousDays: widget.workVigorousDays,
                              workVigorousMinutes: widget.workVigorousMinutes,
                              workModerate: widget.workModerate,
                              workModerateDays: widget.workModerateDays,
                              workModerateMinutes: widget.workModerateMinutes,
                              travel: widget.travel,
                              travelDays: widget.travelDays,
                              travelMinutes: widget.travelMinutes,
                              recVigorous: _recVigorous,
                              recVigorousDays: _recVigorous ? _recVigorousDays : 0,
                              recVigorousMinutes: recVigorousMins,
                              recModerate: _recModerate,
                              recModerateDays: _recModerate ? _recModerateDays : 0,
                              recModerateMinutes: recModerateMins,
                            ),
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

  Widget _buildSubCard({
    required Color color,
    required Color darkColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: darkColor,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

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

  Widget _buildCounterRow({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    required int min,
    required int max,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: GelatoTheme.textDark,
          ),
        ),
        Row(
          children: [
            _buildCircleButton(
              icon: Icons.remove,
              onPressed: value > min ? () => onChanged(value - 1) : null,
            ),
            const SizedBox(width: 12),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: GelatoTheme.textDark,
              ),
            ),
            const SizedBox(width: 12),
            _buildCircleButton(
              icon: Icons.add,
              onPressed: value < max ? () => onChanged(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationRow({
    required String label,
    required int hours,
    required int mins,
    required ValueChanged<int> onHoursChanged,
    required ValueChanged<int> onMinsChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: GelatoTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hours
            Row(
              children: [
                _buildCircleButton(
                  icon: Icons.remove,
                  onPressed: hours > 0 ? () => onHoursChanged(hours - 1) : null,
                ),
                const SizedBox(width: 8),
                Text(
                  '${hours}h',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                _buildCircleButton(
                  icon: Icons.add,
                  onPressed: hours < 24 ? () => onHoursChanged(hours + 1) : null,
                ),
              ],
            ),
            // Mins
            Row(
              children: [
                _buildCircleButton(
                  icon: Icons.remove,
                  onPressed: mins >= 10 ? () => onMinsChanged(mins - 10) : null,
                ),
                const SizedBox(width: 8),
                Text(
                  '${mins}m',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                _buildCircleButton(
                  icon: Icons.add,
                  onPressed: mins <= 50 ? () => onMinsChanged(mins + 10) : null,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback? onPressed}) {
    final enabled = onPressed != null;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: enabled ? Colors.white : Colors.grey[200],
        border: Border.all(color: enabled ? Colors.black : Colors.grey[400]!, width: 1.5),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16, color: enabled ? Colors.black : Colors.grey[400]),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildHelpToggle({
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 0,
              offset: const Offset(1.5, 1.5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isExpanded ? Icons.lightbulb : Icons.lightbulb_outline,
              size: 14,
              color: isExpanded ? GelatoTheme.yellowDark : GelatoTheme.textLight,
            ),
            const SizedBox(width: 4),
            Text(
              isExpanded ? 'Hide examples' : 'Show examples',
              style: const TextStyle(
                color: GelatoTheme.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpContent({
    required Color color,
    required Color darkColor,
    required String title,
    required List<String> examples,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, size: 16, color: darkColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: darkColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...examples.map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: darkColor, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        ex,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GelatoTheme.textDark,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

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
