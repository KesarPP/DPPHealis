import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class DashboardMomentum extends StatefulWidget {
  const DashboardMomentum({super.key});

  @override
  State<DashboardMomentum> createState() => _DashboardMomentumState();
}

class _DashboardMomentumState extends State<DashboardMomentum> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<_MomentumCardData> items = [
      _MomentumCardData(
        title: "14",
        subtitle: "Day Streak",
        meta: "Keep it up!",
        iconData: Icons.local_fire_department_rounded,
        color: GelatoTheme.orangeBright,
        bgColor: GelatoTheme.orange,
        progress: 1.0,
      ),
      _MomentumCardData(
        title: "75%",
        subtitle: "Meal Adherence",
        meta: "Great choices!",
        iconData: Icons.restaurant_menu_rounded,
        color: GelatoTheme.greenBright,
        bgColor: GelatoTheme.green,
        progress: 0.75,
      ),
      _MomentumCardData(
        title: "Session",
        subtitle: "5 of 16",
        meta: "On track!",
        iconData: Icons.school_rounded,
        color: GelatoTheme.purpleBright,
        bgColor: GelatoTheme.purple,
        progress: 5 / 16,
      ),
      _MomentumCardData(
        title: "75%",
        subtitle: "Water Goal",
        meta: "Hydrated!",
        iconData: Icons.water_drop_rounded,
        color: GelatoTheme.blueBright,
        bgColor: GelatoTheme.blue,
        progress: 0.75,
      ),
      _MomentumCardData(
        title: "88%",
        subtitle: "Consistency",
        meta: "You rock!",
        iconData: Icons.trending_up_rounded,
        color: GelatoTheme.pinkBright,
        bgColor: GelatoTheme.pink,
        progress: 0.88,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8F5), // Light warm background
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder, // Black border
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: GelatoTheme.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Your Momentum',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),
                      ),
                      Text(
                        'Consistency today, results tomorrow',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GelatoTheme.textLight),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140, // Increased height for bouncing space
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                
                return AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    // Create a wave effect based on index
                    final offset = math.sin((_animController.value * 2 * math.pi) + (index * 0.8)) * 4;
                    return Transform.translate(
                      offset: Offset(0, offset),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.only(right: index == items.length - 1 ? 0 : 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.bgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 2), // Strict Gelato black border
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          offset: const Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Popping Icon Badge
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 0),
                            ],
                          ),
                          child: Icon(item.iconData, color: item.color, size: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, height: 1.1),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.meta,
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        if (item.title == "14")
                          // Draw dots for streak with black borders
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              7,
                              (i) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black, width: 0.5),
                                ),
                              ),
                            ),
                          )
                        else
                          // Draw progress bar with black borders
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: item.progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(2),
                                  border: const Border(right: BorderSide(color: Colors.black, width: 1)),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MomentumCardData {
  final String title;
  final String subtitle;
  final String meta;
  final IconData iconData;
  final Color color;
  final Color bgColor;
  final double progress;

  _MomentumCardData({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.iconData,
    required this.color,
    required this.bgColor,
    required this.progress,
  });
}
