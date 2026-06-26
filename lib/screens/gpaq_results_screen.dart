import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/app_state.dart';
import '../main.dart'; // MainShell
import '../data/gelato_theme.dart';
import 'coach_selection_screen.dart';

class GPAQResultsScreen extends StatefulWidget {
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
  final bool recVigorous;
  final int recVigorousDays;
  final int recVigorousMinutes;
  final bool recModerate;
  final int recModerateDays;
  final int recModerateMinutes;
  final int sedentaryMinutes;

  const GPAQResultsScreen({
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
    required this.recVigorous,
    required this.recVigorousDays,
    required this.recVigorousMinutes,
    required this.recModerate,
    required this.recModerateDays,
    required this.recModerateMinutes,
    required this.sedentaryMinutes,
  });

  @override
  State<GPAQResultsScreen> createState() => _GPAQResultsScreenState();
}

class _GPAQResultsScreenState extends State<GPAQResultsScreen> {
  late int totalMetMinutes;
  late String activityLevel;
  late Color levelBg;
  late Color levelDark;
  late String levelDescription;
  late IconData levelIcon;
  late double sedentaryHours;

  late int workVigorousMet;
  late int workModerateMet;
  late int travelMet;
  late int recVigorousMet;
  late int recModerateMet;

  @override
  void initState() {
    super.initState();
    _calculateAndSave();
  }

  void _calculateAndSave() {
    workVigorousMet = widget.workVigorousDays * widget.workVigorousMinutes * 8;
    workModerateMet = widget.workModerateDays * widget.workModerateMinutes * 4;
    travelMet = widget.travelDays * widget.travelMinutes * 4;
    recVigorousMet = widget.recVigorousDays * widget.recVigorousMinutes * 8;
    recModerateMet = widget.recModerateDays * widget.recModerateMinutes * 4;

    totalMetMinutes = workVigorousMet + workModerateMet + travelMet + recVigorousMet + recModerateMet;

    final int vigDays = (widget.workVigorous ? widget.workVigorousDays : 0) + (widget.recVigorous ? widget.recVigorousDays : 0);
    final int modDays = (widget.workModerate ? widget.workModerateDays : 0) + (widget.travel ? widget.travelDays : 0) + (widget.recModerate ? widget.recModerateDays : 0);
    final int totalDays = vigDays + modDays;

    if ((vigDays >= 3 && totalMetMinutes >= 1500) || (totalDays >= 7 && totalMetMinutes >= 3000)) {
      activityLevel = 'High Activity';
      levelBg = GelatoTheme.green;
      levelDark = GelatoTheme.greenDark;
      levelIcon = Icons.bolt;
      levelDescription = 'Outstanding physical activity level! Your high MET-minutes significantly lower your insulin resistance and diabetes risk.';
    } else if ((vigDays >= 3 && (widget.workVigorousMinutes >= 20 || widget.recVigorousMinutes >= 20)) ||
        (modDays >= 5 && (widget.workModerateMinutes >= 30 || widget.travelMinutes >= 30 || widget.recModerateMinutes >= 30)) ||
        (totalMetMinutes >= 600)) {
      activityLevel = 'Moderate Activity';
      levelBg = GelatoTheme.yellow;
      levelDark = GelatoTheme.yellowDark;
      levelIcon = Icons.directions_run;
      levelDescription = 'Healthy level of activity! You meet standard physical activity targets, helping maintain blood sugar balance.';
    } else {
      activityLevel = 'Low Activity';
      levelBg = GelatoTheme.pink;
      levelDark = GelatoTheme.pinkDark;
      levelIcon = Icons.warning_amber_rounded;
      levelDescription = 'Sedentary or low activity. Increasing daily physical activity will help you manage and lower your prediabetes risk.';
    }

    sedentaryHours = widget.sedentaryMinutes / 60.0;

    AppState.gpaqMetMinutes = totalMetMinutes;
    AppState.gpaqLevel = activityLevel;
    AppState.hasGpaqResult = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'gpaqMetMinutes': totalMetMinutes,
          'gpaqLevel': activityLevel,
          'hasGpaqResult': true,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error saving GPAQ score: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        backgroundColor: GelatoTheme.bg,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              color: GelatoTheme.purpleDark,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Activity Results',
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
                    // Result Header Card (Score Meter)
                    _buildCard(
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
                            '$totalMetMinutes',
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
                                  activityLevel,
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
                    ),
                    const SizedBox(height: 16),

                    // Detail Breakdown Card
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detailed Activity Breakdown',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailItem(
                            label: 'Work Physical Activity',
                            value: '${workVigorousMet + workModerateMet} MET-min',
                            color: GelatoTheme.orange,
                            icon: Icons.work_outline,
                          ),
                          const Divider(height: 24),
                          _buildDetailItem(
                            label: 'Travel / Transit Activity',
                            value: '$travelMet MET-min',
                            color: GelatoTheme.blue,
                            icon: Icons.directions_bike_outlined,
                          ),
                          const Divider(height: 24),
                          _buildDetailItem(
                            label: 'Recreational Physical Activity',
                            value: '${recVigorousMet + recModerateMet} MET-min',
                            color: GelatoTheme.green,
                            icon: Icons.sports_basketball_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sedentary time card
                    _buildCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: GelatoTheme.pink,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.single_bed,
                              color: GelatoTheme.pinkDark,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Sitting Time',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: GelatoTheme.textLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${sedentaryHours.toStringAsFixed(1)} hours / day',
                                  style: const TextStyle(
                                    fontSize: 18,
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
              child: Container(
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
                    if (widget.isFromSignup) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CoachSelectionScreen(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainShell(),
                        ),
                      );
                    }
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.isFromSignup ? 'Continue to Coach Selection' : 'Go to Dashboard',
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

  Widget _buildDetailItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Icon(icon, color: Colors.black, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: GelatoTheme.textDark,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: GelatoTheme.textDark,
          ),
        ),
      ],
    );
  }
}
