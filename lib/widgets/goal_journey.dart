import 'package:flutter/material.dart';

class GoalJourney extends StatefulWidget {
  final int currentSteps;
  final int goalSteps;

  const GoalJourney({
    super.key,
    this.currentSteps = 102450,
    this.goalSteps = 150000,
  });

  @override
  State<GoalJourney> createState() => _GoalJourneyState();
}

class _GoalJourneyState extends State<GoalJourney>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnim;

  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  final List<_MilestoneData> milestones = const [
    _MilestoneData(steps: 25000, label: 'First Step', icon: '👣', isCompleted: true, isToday: false),
    _MilestoneData(steps: 50000, label: 'On Track', icon: '👟', isCompleted: true, isToday: false),
    _MilestoneData(steps: 75000, label: 'On Track', icon: '👟', isCompleted: true, isToday: false),
    _MilestoneData(steps: 102450, label: 'Today', icon: '👣', isCompleted: false, isToday: true),
    _MilestoneData(steps: 125000, label: 'Almost There', icon: '🌿', isCompleted: false, isToday: false),
    _MilestoneData(steps: 150000, label: 'Goal', icon: '🏔️', isCompleted: false, isToday: false),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutQuart,
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Journey to Your Goal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "You're doing great! Keep going!",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'GOAL: 150,000 STEPS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Milestones + Trophy Card Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Milestones Path (Left)
              Expanded(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_progressAnim, _glowAnim]),
                  builder: (context, _) {
                    return SizedBox(
                      height: 110,
                      child: Stack(
                        children: [
                          // Path Line
                          Positioned(
                            top: 24,
                            left: 20,
                            right: 20,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final totalWidth = constraints.maxWidth;
                                final progress = (widget.currentSteps / widget.goalSteps).clamp(0.0, 1.0) * _progressAnim.value;
                                return Stack(
                                  children: [
                                    // Soft gold/yellow background line
                                    Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    // Glowing gold progress line
                                    Container(
                                      height: 4,
                                      width: totalWidth * progress,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFCD34D), // Light gold
                                            Color(0xFFF59E0B), // Gold
                                            Color(0xFFD97706), // Deep gold
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          // Milestone Nodes
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final totalWidth = constraints.maxWidth - 40;
                                return Stack(
                                  children: milestones.asMap().entries.map((entry) {
                                    final m = entry.value;
                                    final stepRatio = (m.steps / widget.goalSteps).clamp(0.0, 1.0);
                                    final double posX = 20 + totalWidth * stepRatio;
                                    final isCompleted = widget.currentSteps >= m.steps;

                                    return Positioned(
                                      left: posX - 25,
                                      top: 0,
                                      width: 50,
                                      child: Column(
                                        children: [
                                          _buildMilestoneNode(m, isCompleted),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${(m.steps / 1000).toStringAsFixed(0)}K',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: m.isToday || isCompleted
                                                  ? const Color(0xFFD97706)
                                                  : const Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            m.label,
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: m.isToday || isCompleted
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color: m.isToday
                                                  ? const Color(0xFFD97706)
                                                  : isCompleted
                                                      ? const Color(0xFFB45309)
                                                      : const Color(0xFFCBD5E1),
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          // Checkmark indicator row
                                          _buildStatusCheckIndicator(m, isCompleted),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 8),

              // Trophy Card (Right)
              Container(
                width: 80,
                height: 105,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFEF3C7), // Light amber/gold
                      Color(0xFFFDE68A), // Darker gold
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 22)),
                    const SizedBox(height: 6),
                    const Text(
                      'You Did It!',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(widget.goalSteps / 1000).toStringAsFixed(0)}K',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF78350F),
                      ),
                    ),
                    const Text(
                      'Steps',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneNode(_MilestoneData m, bool isCompleted) {
    if (m.isToday) {
      // Glow and Gold Highlight on current node
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFFBEB),
          border: Border.all(
            color: const Color(0xFFF59E0B), // Gold border
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.8 * _glowAnim.value),
              blurRadius: 12,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: Text(
            m.icon,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC),
        border: Border.all(
          color: isCompleted ? const Color(0xFFF59E0B) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: const Color(0xFFFCD34D).withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 0.5,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          m.icon,
          style: TextStyle(
            fontSize: 13,
            color: isCompleted ? null : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCheckIndicator(_MilestoneData m, bool isCompleted) {
    if (m.isToday) {
      return Container(
        height: 10,
        width: 10,
        decoration: const BoxDecoration(
          color: Color(0xFFF59E0B), // Gold dot for today
          shape: BoxShape.circle,
        ),
      );
    }

    if (isCompleted) {
      return const Icon(
        Icons.check_circle_rounded,
        color: Color(0xFFF59E0B), // Gold checkmark for completed
        size: 11,
      );
    }

    return const Text(
      '-',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: Color(0xFFCBD5E1),
      ),
    );
  }
}

class _MilestoneData {
  final int steps;
  final String label;
  final String icon;
  final bool isCompleted;
  final bool isToday;

  const _MilestoneData({
    required this.steps,
    required this.label,
    required this.icon,
    required this.isCompleted,
    required this.isToday,
  });
}
