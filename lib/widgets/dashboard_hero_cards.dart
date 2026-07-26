import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../data/gelato_theme.dart';
import '../models/ndpp_constants.dart';
import '../services/activity_metrics_engine.dart';
import '../services/health_sync_service.dart';

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
            _ActivitySection(
              isWeekly: _selectedSegment == 0,
              trailing30Days: widget.trailing30Days,
              programWeek: widget.programWeek,
              missionGoalMode: widget.missionGoalMode,
              stretchMultiplier: widget.stretchMultiplier,
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
            currentWeight = (data['current_weight_kg'] as num?)?.toDouble() ??
                (data['weight_kg'] as num?)?.toDouble() ??
                75.0;
            goalWeight = (data['goal_weight_kg'] as num?)?.toDouble() ?? 70.0;
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

  const _ActivitySection({
    required this.isWeekly,
    required this.trailing30Days,
    required this.programWeek,
    required this.missionGoalMode,
    required this.stretchMultiplier,
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
          )
        : ActivityMissionEngine.getMonthlySummary(
            trailing30Days: trailing30Days,
            programWeek: programWeek,
            kcalRate: kcalRate,
            mode: missionGoalMode,
            stretchMultiplier: stretchMultiplier,
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
