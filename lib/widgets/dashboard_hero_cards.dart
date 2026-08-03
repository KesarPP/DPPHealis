import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../data/gelato_theme.dart';
import '../models/ndpp_constants.dart';
import '../services/activity_metrics_engine.dart';
import '../services/health_sync_service.dart';
import '../models/calorie_goal_calculator.dart';
import '../data/app_state.dart';

class DashboardHeroCards extends StatefulWidget {
  final List<DailyAggregate> trailing30Days;
  final int programWeek;
  final MissionGoalMode missionGoalMode;
  final double stretchMultiplier;
  final SyncStatus syncStatus;
  final VoidCallback? onRetrySync;
  const DashboardHeroCards({
    super.key,
    required this.trailing30Days,
    required this.programWeek,
    this.missionGoalMode = MissionGoalMode.ndppStrict,
    this.stretchMultiplier = 1.0,
    this.syncStatus = SyncStatus.success,
    this.onRetrySync,
  });

  @override
  State<DashboardHeroCards> createState() => _DashboardHeroCardsState();
}

class _DashboardHeroCardsState extends State<DashboardHeroCards> {
  int _selectedSegment = 0; // 0 = Weekly, 1 = Monthly

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: GelatoTheme.blue,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: GelatoTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unified Card Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.dashboard_rounded, color: GelatoTheme.purpleDark, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Weight Summary",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                _buildSegmentedToggle(const Color(0xFF1E293B), Colors.white, const Color(0xFF64748B)),
              ],
            ),
            const SizedBox(height: 8),
            const _WeightSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedToggle(
      Color pillColor, Color selectedTextColor, Color unselectedTextColor) {
    return Container(
      width: 114,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            top: 2,
            bottom: 2,
            left: _selectedSegment == 0 ? 2 : 56,
            width: 54,
            child: Container(
              decoration: BoxDecoration(
                color: pillColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: _buildSegmentButton(
                      'Weekly', 0, selectedTextColor, unselectedTextColor)),
              Expanded(
                  child: _buildSegmentButton(
                      'Monthly', 1, selectedTextColor, unselectedTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String title, int index, Color selectedTextColor,
      Color unselectedTextColor) {
    final isSelected = _selectedSegment == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedSegment = index;
        });
      },
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? selectedTextColor : unselectedTextColor,
          ),
        ),
      ),
    );
  }
}

class DashboardActivityCard extends StatefulWidget {
  final List<DailyAggregate> trailing30Days;
  final int programWeek;
  final MissionGoalMode missionGoalMode;
  final double stretchMultiplier;
  const DashboardActivityCard({
    super.key,
    required this.trailing30Days,
    required this.programWeek,
    this.missionGoalMode = MissionGoalMode.ndppStrict,
    this.stretchMultiplier = 1.0,
  });

  @override
  State<DashboardActivityCard> createState() => _DashboardActivityCardState();
}

class _DashboardActivityCardState extends State<DashboardActivityCard> {
  int _selectedSegment = 0; // 0 = Weekly, 1 = Monthly

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: GelatoTheme.yellow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: GelatoTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.directions_run_rounded, color: GelatoTheme.orangeDark, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Activity Summary",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ],
                ),
                _buildSegmentedToggle(const Color(0xFF1E293B), Colors.white, const Color(0xFF64748B)),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot>(
              stream: AuthService().currentUser?.uid != null 
                  ? FirebaseFirestore.instance.collection('users').doc(AuthService().currentUser!.uid).snapshots()
                  : const Stream.empty(),
              builder: (context, snapshot) {
                double? customWeeklyKcalGoal;
                double? customMonthlyKcalGoal;

                if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data != null) {
                    final double weightKg = (data['currentWeight'] as num?)?.toDouble() ??
                        (data['current_weight_kg'] as num?)?.toDouble() ??
                        (data['weight_kg'] as num?)?.toDouble() ?? 
                        (data['weight'] as num?)?.toDouble() ?? 0.0;
                    final double heightRaw = (data['height'] as num?)?.toDouble() ?? 0.0;
                    final double heightCm = heightRaw < 3.0 ? heightRaw * 100.0 : heightRaw;
                    final int age = (data['age'] as num?)?.toInt() ?? 0;
                    final String g = data['gender']?.toString() ?? (data['isMan'] == true ? 'male' : 'female');

                    // Fallback to AppState first, then static defaults
                    final double fallbackWeight = AppState.weightKg > 0 ? AppState.weightKg : 75.0;
                    final double fallbackHeight = AppState.heightCm > 0 ? AppState.heightCm : 170.0;

                    // Route through CalorieGoalCalculator.calculate as instructed
                    final double effectiveWeight = weightKg > 0 ? weightKg : fallbackWeight;
                    final double effectiveHeightCm = heightCm > 0 ? heightCm : fallbackHeight;
                    final int effectiveAge = age > 0 ? age : (AppState.age > 0 ? AppState.age : 20); // Fallback to 20 for test cases
                    final Sex sexEnum = (g == 'male' || g == 'man' || AppState.isMan) ? Sex.male : Sex.female; // Fallback to female if missing
                    final double effectiveBmi = effectiveWeight / ((effectiveHeightCm / 100) * (effectiveHeightCm / 100));
                    
                    final result = CalorieGoalCalculator.calculate(
                      weight: effectiveWeight,
                      height: effectiveHeightCm,
                      age: effectiveAge,
                      sex: sexEnum,
                      bmi: effectiveBmi,
                    );
                    
                    // Calculate active calorie burn goal based on weight
                    final int weeklyTargetMins = NdppConstants.getWeeklyTargetForWeek(widget.programWeek);
                    customWeeklyKcalGoal = CalorieGoalCalculator.calculateActiveCalorieBurnGoal(
                      weightKg: effectiveWeight,
                      weeklyTargetMins: weeklyTargetMins,
                    );

                    double monthlyTargetMins = 0;
                    if (widget.programWeek >= 8) {
                      monthlyTargetMins = 652;
                    } else {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final firstDayOfMonth = DateTime(now.year, now.month, 1);
                      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
                      final int daysInMonth = lastDayOfMonth.difference(firstDayOfMonth).inDays + 1;
                      for (int i = 0; i < daysInMonth; i++) {
                        final d = firstDayOfMonth.add(Duration(days: i));
                        final int diffDays = d.difference(today).inDays;
                        final int weekForD = max(1, widget.programWeek + (diffDays / 7).floor());
                        final int wTarget = NdppConstants.getWeeklyTargetForWeek(weekForD);
                        monthlyTargetMins += wTarget / 7.0;
                      }
                    }
                    customMonthlyKcalGoal = CalorieGoalCalculator.calculateActiveCalorieBurnGoal(
                      weightKg: effectiveWeight,
                      weeklyTargetMins: monthlyTargetMins.round(),
                    );
                  }
                }

                return _ActivitySection(
                  isWeekly: _selectedSegment == 0,
                  trailing30Days: widget.trailing30Days,
                  programWeek: widget.programWeek,
                  missionGoalMode: widget.missionGoalMode,
                  stretchMultiplier: widget.stretchMultiplier,
                  customKcalGoal: _selectedSegment == 0 ? customWeeklyKcalGoal : customMonthlyKcalGoal,
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedToggle(Color pillColor, Color selectedTextColor, Color unselectedTextColor) {
    return Container(
      width: 114,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            top: 2,
            bottom: 2,
            left: _selectedSegment == 0 ? 2 : 56,
            width: 54,
            child: Container(
              decoration: BoxDecoration(
                color: pillColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _buildSegmentButton('Weekly', 0, selectedTextColor, unselectedTextColor)),
              Expanded(child: _buildSegmentButton('Monthly', 1, selectedTextColor, unselectedTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String title, int index, Color selectedTextColor, Color unselectedTextColor) {
    final isSelected = _selectedSegment == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedSegment = index;
        });
      },
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? selectedTextColor : unselectedTextColor,
          ),
        ),
      ),
    );
  }
}


class _WeightSection extends StatelessWidget {
  const _WeightSection({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    if (user == null) {
      return _buildWeightContent(context, 75.0, 70.0);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        double currentWeight = 75.0;
        double goalWeight = 70.0;
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            double fallbackWeight = AppState.weightKg > 0 ? AppState.weightKg : 75.0;
            currentWeight = (data['currentWeight'] as num?)?.toDouble() ??
                (data['current_weight_kg'] as num?)?.toDouble() ??
                (data['weight_kg'] as num?)?.toDouble() ??
                (data['weight'] as num?)?.toDouble() ??
                fallbackWeight;
                
            double fallbackHeight = AppState.heightCm > 0 ? AppState.heightCm : 170.0;
            final double heightRaw = (data['height'] as num?)?.toDouble() ?? fallbackHeight;
            final double heightCm = heightRaw < 3.0 ? heightRaw * 100.0 : heightRaw;
            final double bmi = currentWeight / ((heightCm / 100) * (heightCm / 100));
            
            if (bmi >= 25.0) {
              goalWeight = currentWeight - (currentWeight * 0.07);
            } else {
              goalWeight = currentWeight;
            }
          }
        }
        return _buildWeightContent(context, currentWeight, goalWeight);
      },
    );
  }

  Widget _buildWeightContent(BuildContext context, double currentWeight, double goalWeight) {
    final double toGo = (currentWeight - goalWeight).clamp(0.0, 999.0);
    final double progress = (currentWeight > goalWeight)
        ? ((82.5 - currentWeight) / (82.5 - goalWeight)).clamp(0.08, 1.0)
        : 1.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: _buildMiniStat('Current', '${currentWeight.toStringAsFixed(0)} kg', const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMiniStat('Goal', '${goalWeight.toStringAsFixed(0)} kg', const Color(0xFFECFDF5), const Color(0xFF047857)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${toGo.toStringAsFixed(1)} kg to go!',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE2E8F0),
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final bool isWeekly;
  final List<DailyAggregate> trailing30Days;
  final int programWeek;
  final MissionGoalMode missionGoalMode;
  final double stretchMultiplier;
  final double? customKcalGoal;

  const _ActivitySection({
    required this.isWeekly,
    required this.trailing30Days,
    required this.programWeek,
    required this.missionGoalMode,
    required this.stretchMultiplier,
    this.customKcalGoal,
  });

  @override
  Widget build(BuildContext context) {
    final kcalRate = ActivityMissionEngine.getPersonalizedKcalRate(trailing30Days);
    final summary = isWeekly
        ? ActivityMissionEngine.getWeeklySummary(
            trailing30Days: trailing30Days,
            programWeek: programWeek,
            kcalRate: kcalRate,
            mode: missionGoalMode,
            stretchMultiplier: stretchMultiplier,
            customKcalGoal: customKcalGoal,
          )
        : ActivityMissionEngine.getMonthlySummary(
            trailing30Days: trailing30Days,
            programWeek: programWeek,
            kcalRate: kcalRate,
            mode: missionGoalMode,
            stretchMultiplier: stretchMultiplier,
            customKcalGoal: customKcalGoal,
          );

    final double ringValue = (summary.progressPercentage / 100.0).clamp(0.0, 1.0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                child: _buildMiniStat('Goal', summary.goalText, const Color(0xFFFFF7ED), const Color(0xFFC2410C)),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMiniStat('Done', summary.completedText, const Color(0xFFFEF3C7), const Color(0xFFB45309)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${summary.progressPercentage}% completed!',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF9A3412)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ringValue,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFFFEDD5),
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF9A3412)),
          ),
          const SizedBox(height: 1),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
