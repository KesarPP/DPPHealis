import 'package:flutter/material.dart';

class DailyGoals extends StatefulWidget {
  const DailyGoals({super.key});

  @override
  State<DailyGoals> createState() => _DailyGoalsState();
}

class _DailyGoalsState extends State<DailyGoals>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  final _goals = const [
    _GoalData(
      label: 'Steps',
      current: '102K',
      target: '150K',
      emoji: '👟',
      progress: 0.68,
      color: Color(0xFF10B981),
    ),
    _GoalData(
      label: 'Calories',
      current: '2,450',
      target: '3,000 kcal',
      emoji: '🔥',
      progress: 0.82,
      color: Color(0xFFF97316),
    ),
    _GoalData(
      label: 'Active Minutes',
      current: '640',
      target: '800 mins',
      emoji: '⏱️',
      progress: 0.80,
      color: Color(0xFF8B5CF6),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🎯', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Daily Goals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Edit >',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Goals Content + Trophy side-by-side
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: Goals list
              Expanded(
                flex: 7,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (context, _) {
                    return Column(
                      children: _goals
                          .map((g) => _GoalRow(goal: g, animValue: _anim.value))
                          .toList(),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Right side: Vertical Trophy card
              Expanded(
                flex: 3,
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB), // light amber
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFEF3C7)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('🏆', style: TextStyle(fontSize: 24)),
                      SizedBox(height: 6),
                      Text(
                        'Keep it up!',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "You're amazing!",
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD97706),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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

class _GoalRow extends StatelessWidget {
  final _GoalData goal;
  final double animValue;

  const _GoalRow({required this.goal, required this.animValue});

  @override
  Widget build(BuildContext context) {
    final pct = (goal.progress * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Circular Icon Container
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                goal.emoji,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Progress Bars and details
          Expanded(
            child: Column(
                    mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${goal.label} (${goal.current} / ${goal.target})',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: goal.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: goal.progress * animValue,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation(goal.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalData {
  final String label;
  final String current;
  final String target;
  final String emoji;
  final double progress;
  final Color color;

  const _GoalData({
    required this.label,
    required this.current,
    required this.target,
    required this.emoji,
    required this.progress,
    required this.color,
  });
}
