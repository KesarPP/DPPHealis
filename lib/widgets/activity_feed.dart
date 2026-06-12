import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class ActivityFeed extends StatelessWidget {
  const ActivityFeed({super.key});

  @override
  Widget build(BuildContext context) {
    const activities = [
      _ActivityData(
        title: 'Morning Walk',
        type: 'Outdoor',
        time: '7:30 AM',
        duration: '35m',
        calories: 180,
        icon: Icons.wb_sunny_rounded,
        color: GelatoTheme.yellow,
        borderColor: GelatoTheme.yellowDark,
        iconColor: GelatoTheme.yellowDark,
      ),
      _ActivityData(
        title: 'Strength Training',
        type: 'Gym',
        time: '12:00 PM',
        duration: '55m',
        calories: 340,
        icon: Icons.fitness_center_rounded,
        color: GelatoTheme.purple,
        borderColor: GelatoTheme.purpleDark,
        iconColor: GelatoTheme.purpleDark,
      ),
      _ActivityData(
        title: 'Evening Cycling',
        type: 'Outdoor',
        time: '6:15 PM',
        duration: '45m',
        calories: 290,
        icon: Icons.directions_bike_rounded,
        color: GelatoTheme.green,
        borderColor: GelatoTheme.greenDark,
        iconColor: GelatoTheme.greenDark,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
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
                  Icon(
                    Icons.bolt_rounded,
                    color: GelatoTheme.orangeDark,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Today's Activities",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: GelatoTheme.textDark,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 24),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: GelatoTheme.pinkDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activities.map((a) => _ActivityCard(activity: a)),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final _ActivityData activity;

  const _ActivityCard({required this.activity});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.activity.color,
            borderRadius: BorderRadius.circular(16),
            border: GelatoTheme.cardBorder,
            boxShadow: GelatoTheme.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.activity.icon,
                    color: widget.activity.iconColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.activity.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.black, // crisp black text for maximum readability on pastel bg
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: GelatoTheme.textLight,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.activity.type,
                          style: const TextStyle(
                            fontSize: 11,
                            color: GelatoTheme.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: GelatoTheme.textLight,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.activity.duration,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GelatoTheme.textLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.activity.calories} kcal',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.activity.borderColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    widget.activity.time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: GelatoTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: widget.activity.borderColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityData {
  final String title;
  final String type;
  final String time;
  final String duration;
  final int calories;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final Color iconColor;

  const _ActivityData({
    required this.title,
    required this.type,
    required this.time,
    required this.duration,
    required this.calories,
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.iconColor,
  });
}
