import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../models/activity_log.dart';
import '../services/firestore_activity_log_service.dart';

class ActivityFeed extends StatelessWidget {
  final VoidCallback? onActivityLogged;

  const ActivityFeed({super.key, this.onActivityLogged});

  @override
  Widget build(BuildContext context) {
    const activities = [
      _ActivityData(
        title: 'Walking',
        type: 'Walk',
        icon: Icons.directions_walk_rounded,
        color: GelatoTheme.green,
        borderColor: GelatoTheme.greenDark,
        iconColor: GelatoTheme.greenDark,
      ),
      _ActivityData(
        title: 'Swimming',
        type: 'Swim',
        icon: Icons.pool_rounded,
        color: GelatoTheme.blue,
        borderColor: GelatoTheme.blueDark,
        iconColor: GelatoTheme.blueDark,
      ),
      _ActivityData(
        title: 'Dancing',
        type: 'Dance',
        icon: Icons.music_note_rounded,
        color: GelatoTheme.pink,
        borderColor: GelatoTheme.pinkDark,
        iconColor: GelatoTheme.pinkDark,
      ),
      _ActivityData(
        title: 'Stretching',
        type: 'Stretch',
        icon: Icons.self_improvement_rounded,
        color: GelatoTheme.purple,
        borderColor: GelatoTheme.purpleDark,
        iconColor: GelatoTheme.purpleDark,
      ),
      _ActivityData(
        title: 'Gardening',
        type: 'Garden',
        icon: Icons.yard_rounded,
        color: GelatoTheme.yellow,
        borderColor: GelatoTheme.yellowDark,
        iconColor: GelatoTheme.yellowDark,
      ),
      _ActivityData(
        title: 'Stairs',
        type: 'Stair Climb',
        icon: Icons.stairs_rounded,
        color: GelatoTheme.orange,
        borderColor: GelatoTheme.orangeDark,
        iconColor: GelatoTheme.orangeDark,
      ),
      _ActivityData(
        title: 'Household',
        type: 'Household',
        icon: Icons.home_rounded,
        color: GelatoTheme.green,
        borderColor: GelatoTheme.greenDark,
        iconColor: GelatoTheme.greenDark,
      ),
      _ActivityData(
        title: 'Other Activity',
        type: 'Other',
        icon: Icons.add_circle_outline_rounded,
        color: GelatoTheme.blue,
        borderColor: GelatoTheme.blueDark,
        iconColor: GelatoTheme.blueDark,
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
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return _ActivityCard(
                activity: activities[index],
                onActivityLogged: onActivityLogged,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final _ActivityData activity;
  final VoidCallback? onActivityLogged;

  const _ActivityCard({required this.activity, this.onActivityLogged});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _pressed = false;

  void _showLogActivityModal(BuildContext context) {
    double duration = 30;
    String frequency = 'Once';
    final TextEditingController customNameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SingleChildScrollView(
                child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.activity.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.activity.icon,
                          color: widget.activity.iconColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Log ${widget.activity.title}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: GelatoTheme.textDark,
                              ),
                            ),
                            Text(
                              widget.activity.type,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: GelatoTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (widget.activity.type == 'Other') ...[
                    Text(
                      'Activity Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: widget.activity.iconColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: customNameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Cycling, Yoga, Tennis...',
                        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: widget.activity.iconColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    'Duration (minutes)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: widget.activity.iconColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${duration.toInt()} min',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: widget.activity.iconColor,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: duration,
                          min: 5,
                          max: 120,
                          divisions: 23,
                          activeColor: widget.activity.iconColor,
                          inactiveColor: widget.activity.color,
                          onChanged: (val) {
                            setModalState(() => duration = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Frequency',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: widget.activity.iconColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: frequency,
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: widget.activity.iconColor),
                        items: ['Once', 'Daily', 'Weekly']
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: GelatoTheme.textDark,
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => frequency = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.activity.iconColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        String activityTitle = widget.activity.title;
                        if (widget.activity.type == 'Other' && customNameController.text.trim().isNotEmpty) {
                          activityTitle = customNameController.text.trim();
                        }
                        final newLog = ActivityLog(
                          id: '',
                          activityName: activityTitle,
                          durationMinutes: duration.toInt(),
                          frequency: frequency,
                          createdAt: DateTime.now(),
                        );
                        try {
                          await FirestoreActivityLogService().saveActivityLog(newLog);
                        } catch (_) {}
                        widget.onActivityLogged?.call();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('$activityTitle logged for ${duration.toInt()} mins!'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Save Activity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        _showLogActivityModal(context);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: widget.activity.color,
            borderRadius: BorderRadius.circular(16),
            border: GelatoTheme.cardBorder,
            boxShadow: _pressed ? [] : GelatoTheme.cardShadow,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          widget.activity.icon,
                          color: widget.activity.iconColor,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.activity.type,
                      style: const TextStyle(
                        fontSize: 10,
                        color: GelatoTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.activity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityData {
  final String title;
  final String type;
  final IconData icon;
  final Color color;
  final Color borderColor;
  final Color iconColor;

  const _ActivityData({
    required this.title,
    required this.type,
    required this.icon,
    required this.color,
    required this.borderColor,
    required this.iconColor,
  });
}
