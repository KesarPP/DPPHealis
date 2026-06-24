import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../models/activity_stats.dart';

class OverviewCards extends StatefulWidget {
  final ActivityStats stats;

  const OverviewCards({
    super.key,
    required this.stats,
  });

  @override
  State<OverviewCards> createState() => _OverviewCardsState();
}

class _OverviewCardsState extends State<OverviewCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  context,
                  index: 0,
                  icon: Icons.directions_walk_rounded,
                  label: 'Steps',
                  value: widget.stats.steps.toString(),
                  unit: '',
                  subtext: '68% of Goal',
                  progress: 0.68,
                  color: GelatoTheme.green,
                  bgColor: const Color(0xFFF2F7EC),
                  darkColor: GelatoTheme.greenDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCard(
                  context,
                  index: 1,
                  icon: Icons.location_on_rounded,
                  label: 'Distance',
                  value: widget.stats.distance.toStringAsFixed(1),
                  unit: 'km',
                  subtext: '↑ Better than yesterday',
                  progress: 0.72,
                  color: GelatoTheme.blue,
                  bgColor: const Color(0xFFF2F6FA),
                  darkColor: GelatoTheme.blueDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  context,
                  index: 2,
                  icon: Icons.local_fire_department_rounded,
                  label: 'Calories',
                  value: widget.stats.calories.toStringAsFixed(0),
                  unit: 'kcal',
                  subtext: '↑ Better than yesterday',
                  progress: 0.82,
                  color: GelatoTheme.orange,
                  bgColor: const Color(0xFFFFF6ED),
                  darkColor: GelatoTheme.orangeDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCard(
                  context,
                  index: 3,
                  icon: Icons.access_time_filled_rounded,
                  label: 'Active Minutes',
                  value: widget.stats.activeMinutes.toString(),
                  unit: 'mins',
                  subtext: '↑ Better than yesterday',
                  progress: 0.80,
                  color: GelatoTheme.purple,
                  bgColor: const Color(0xFFF6F2FA),
                  darkColor: GelatoTheme.purpleDark,
                ),
              ),
            ],
          ),
        ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required String subtext,
    required double progress,
    required Color color,
    required Color bgColor,
    required Color darkColor,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delay = index * 0.12;
        final t = (((_controller.value - delay) / (1 - delay)).clamp(0.0, 1.0));
        final anim = Curves.easeOutCubic.transform(t);

        return Transform.translate(
          offset: Offset(0, 30 * (1.0 - anim)),
          child: Opacity(
            opacity: t,
            child: child,
          ),
        );
      },
      child: _MetricCard(
        icon: icon,
        label: label,
        value: value,
        unit: unit,
        subtext: subtext,
        progress: progress,
        color: color,
        bgColor: bgColor,
        darkColor: darkColor,
        progressAnim: _controller,
      ),
    );
  }
}

class _MetricCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String subtext;
  final double progress;
  final Color color;
  final Color bgColor;
  final Color darkColor;
  final AnimationController progressAnim;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.subtext,
    required this.progress,
    required this.color,
    required this.bgColor,
    required this.darkColor,
    required this.progressAnim,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    final int delayMs = widget.label.hashCode % 500;
    _floatController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1400 + delayMs),
    );
    _floatAnim = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _floatController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(20),
            border: GelatoTheme.cardBorder,
            boxShadow: GelatoTheme.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Floating Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedBuilder(
                    animation: _floatAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.2),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.darkColor,
                        size: 20,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.trending_up_rounded,
                    size: 14,
                    color: widget.darkColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Value & Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: GelatoTheme.textDark,
                      height: 1,
                    ),
                  ),
                  if (widget.unit.isNotEmpty) ...[
                    const SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(
                        widget.unit,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.darkColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: GelatoTheme.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Progress indicator & subtitle
              AnimatedBuilder(
                animation: widget.progressAnim,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: widget.progress * widget.progressAnim.value,
                          minHeight: 5,
                          backgroundColor: Colors.white.withValues(alpha: 0.45),
                          valueColor: AlwaysStoppedAnimation(widget.darkColor),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtext,
                        style: TextStyle(
                          fontSize: 10,
                          color: widget.darkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
