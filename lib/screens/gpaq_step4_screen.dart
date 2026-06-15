import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import 'gpaq_results_screen.dart';

class GPAQStep4Screen extends StatefulWidget {
  final bool workVigorous;
  final int workVigorousDays;
  final int workVigorousMinutes;
  final bool workModerate;
  final int workModerateDays;
  final int workModerateMinutes;
  final bool travel;
  final int travelDays;
  final int travelMinutes;
  final bool recVigorous;
  final int recVigorousDays;
  final int recVigorousMinutes;
  final bool recModerate;
  final int recModerateDays;
  final int recModerateMinutes;

  const GPAQStep4Screen({
    super.key,
    required this.workVigorous,
    required this.workVigorousDays,
    required this.workVigorousMinutes,
    required this.workModerate,
    required this.workModerateDays,
    required this.workModerateMinutes,
    required this.travel,
    required this.travelDays,
    required this.travelMinutes,
    required this.recVigorous,
    required this.recVigorousDays,
    required this.recVigorousMinutes,
    required this.recModerate,
    required this.recModerateDays,
    required this.recModerateMinutes,
  });

  @override
  State<GPAQStep4Screen> createState() => _GPAQStep4ScreenState();
}

class _GPAQStep4ScreenState extends State<GPAQStep4Screen> {
  int _sedentaryHours = 6;
  int _sedentaryMins = 0;
  bool _showSedentaryHelp = false;

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
                    const _RiskStepper(activeStep: 7),
                    const SizedBox(height: 16),

                    // Section Indicator Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: GelatoTheme.pink.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black, width: 1.0),
                        ),
                        child: const Text(
                          'Sedentary Behavior',
                          style: TextStyle(
                            color: GelatoTheme.pinkDark,
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
                        'Risk Assessment (Step 7/7)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card: Sedentary Behavior
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '6. How much time do you usually spend sitting or reclining on a typical day?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildHelpToggle(
                            isExpanded: _showSedentaryHelp,
                            onTap: () => setState(() => _showSedentaryHelp = !_showSedentaryHelp),
                          ),
                          if (_showSedentaryHelp)
                            _buildHelpContent(
                              color: GelatoTheme.yellow,
                              darkColor: GelatoTheme.yellowDark,
                              title: 'Sedentary Behavior Examples',
                              examples: [
                                'Sitting at a desk or working on a computer',
                                'Watching television or playing video games',
                                'Reading, writing, or studying while sitting',
                                'Commuting as a passenger in a car, bus, train, or auto-rickshaw',
                                'Visiting friends or family while sitting/reclining (excluding sleeping)',
                              ],
                            ),
                          const SizedBox(height: 20),
                          // Duration selection sub-card
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
                            child: _buildDurationRow(
                              label: 'Typical Daily Sitting Time',
                              hours: _sedentaryHours,
                              mins: _sedentaryMins,
                              onHoursChanged: (val) => setState(() => _sedentaryHours = val),
                              onMinsChanged: (val) => setState(() => _sedentaryMins = val),
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
                        final sedentaryMins = _sedentaryHours * 60 + _sedentaryMins;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GPAQResultsScreen(
                              workVigorous: widget.workVigorous,
                              workVigorousDays: widget.workVigorousDays,
                              workVigorousMinutes: widget.workVigorousMinutes,
                              workModerate: widget.workModerate,
                              workModerateDays: widget.workModerateDays,
                              workModerateMinutes: widget.workModerateMinutes,
                              travel: widget.travel,
                              travelDays: widget.travelDays,
                              travelMinutes: widget.travelMinutes,
                              recVigorous: widget.recVigorous,
                              recVigorousDays: widget.recVigorousDays,
                              recVigorousMinutes: widget.recVigorousMinutes,
                              recModerate: widget.recModerate,
                              recModerateDays: widget.recModerateDays,
                              recModerateMinutes: widget.recModerateMinutes,
                              sedentaryMinutes: sedentaryMins,
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
