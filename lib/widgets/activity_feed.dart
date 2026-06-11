import 'package:flutter/material.dart';

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
        emoji: '🌅',
        color: Color(0xFFFEF3C7),
        borderColor: Color(0xFFFCD34D),
      ),
      _ActivityData(
        title: 'Strength Training',
        type: 'Gym',
        time: '12:00 PM',
        duration: '55m',
        calories: 340,
        emoji: '🏋️',
        color: Color(0xFFEDE9FE),
        borderColor: Color(0xFFC4B5FD),
      ),
      _ActivityData(
        title: 'Evening Cycling',
        type: 'Outdoor',
        time: '6:15 PM',
        duration: '45m',
        calories: 290,
        emoji: '🚴',
        color: Color(0xFFDCFCE7),
        borderColor: Color(0xFF86EFAC),
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    "Today's Activities",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
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
                    color: Color(0xFF10B981),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.activity.borderColor.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.activity.emoji,
                    style: const TextStyle(fontSize: 24),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 11, color: Color(0xFF6B7280)),
                        Text(
                          widget.activity.type,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
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
                      const Icon(Icons.timer_outlined,
                          size: 12, color: Color(0xFF6B7280)),
                      const SizedBox(width: 2),
                      Text(
                        widget.activity.duration,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.activity.calories} kcal',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFF97316),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.activity.time,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Color(0xFF9CA3AF)),
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
  final String emoji;
  final Color color;
  final Color borderColor;

  const _ActivityData({
    required this.title,
    required this.type,
    required this.time,
    required this.duration,
    required this.calories,
    required this.emoji,
    required this.color,
    required this.borderColor,
  });
}
