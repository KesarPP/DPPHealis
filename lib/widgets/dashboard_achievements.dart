import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../services/activity_metrics_engine.dart';

class DashboardAchievements extends StatefulWidget {
  final List<Achievement> achievements;

  const DashboardAchievements({
    super.key,
    required this.achievements,
  });

  @override
  State<DashboardAchievements> createState() => _DashboardAchievementsState();
}

class _DashboardAchievementsState extends State<DashboardAchievements> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'calendar_month_rounded': return Icons.calendar_month_rounded;
      case 'emoji_events_rounded': return Icons.emoji_events_rounded;
      case 'timer_rounded': return Icons.timer_rounded;
      case 'directions_walk_rounded': return Icons.directions_walk_rounded;
      case 'restaurant_rounded': return Icons.restaurant_rounded;
      case 'explore_rounded': return Icons.explore_rounded;
      case 'accessibility_new_rounded': return Icons.accessibility_new_rounded;
      case 'cleaning_services_rounded': return Icons.cleaning_services_rounded;
      case 'monitor_weight_rounded': return Icons.monitor_weight_rounded;
      case 'health_and_safety_rounded': return Icons.health_and_safety_rounded;
      default: return Icons.star_rounded;
    }
  }

  Color _getColor(String id) {
    switch (id) {
      case 'streak_7': return GelatoTheme.orangeDark;
      case 'logged_50_meals': return GelatoTheme.greenDark;
      case 'first_10k': return GelatoTheme.blueDark;
      case 'lose_5kg': return GelatoTheme.pinkDark;
      case 'low_risk_zone': return GelatoTheme.pinkDark;
      case 'week_150': return GelatoTheme.purpleDark;
      case 'streak_30': return GelatoTheme.purpleDark;
      default: return GelatoTheme.blueDark;
    }
  }

  Color _getBgColor(String id) {
    switch (id) {
      case 'streak_7': return GelatoTheme.orange;
      case 'logged_50_meals': return GelatoTheme.green;
      case 'first_10k': return GelatoTheme.blue;
      case 'lose_5kg': return GelatoTheme.pink;
      case 'low_risk_zone': return GelatoTheme.pink;
      case 'week_150': return GelatoTheme.purple;
      case 'streak_30': return GelatoTheme.purple;
      default: return GelatoTheme.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final earnedItems = widget.achievements.where((a) => a.unlocked).toList();
    earnedItems.sort((a, b) {
      final dateA = a.earnedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = b.earnedDate ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });
    
    final lockedItems = widget.achievements.where((a) => !a.unlocked).toList();
    lockedItems.sort((a, b) {
      final ratioA = a.progressTarget > 0 ? a.progressCurrent / a.progressTarget : 0.0;
      final ratioB = b.progressTarget > 0 ? b.progressCurrent / b.progressTarget : 0.0;
      return ratioB.compareTo(ratioA);
    });
    final nextUpList = lockedItems.take(3).toList();

    // Dynamic Header Text
    final now = DateTime.now();
    bool hasRecentEarned = earnedItems.any((a) => a.earnedDate != null && now.difference(a.earnedDate!).inHours < 24);
    final topLockedRatio = nextUpList.isNotEmpty && nextUpList[0].progressTarget > 0 
        ? nextUpList[0].progressCurrent / nextUpList[0].progressTarget 
        : 0.0;
    
    String headerMessage = "Keep going!";
    if (hasRecentEarned) {
      headerMessage = "Keep it up!";
    } else if (topLockedRatio >= 0.9) {
      headerMessage = "Almost there!";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: GelatoTheme.yellowDark, size: 28),
              const SizedBox(width: 12),
              const Text('Achievements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
              const SizedBox(width: 8),
              Expanded(child: Text(headerMessage, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: GelatoTheme.purpleDark))),
            ],
          ),
          const SizedBox(height: 16),
          
          if (earnedItems.isNotEmpty)
            SizedBox(
              height: 160,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: earnedItems.length,
                itemBuilder: (context, index) {
                  return _buildBadge(earnedItems[index], index, false);
                },
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Complete tasks to earn achievements!",
                style: TextStyle(color: GelatoTheme.textLight, fontWeight: FontWeight.w600),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // "Next Up" container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.lock_rounded, color: GelatoTheme.purpleBright, size: 16),
                    SizedBox(width: 8),
                    Text(
                      "Next Up",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GelatoTheme.purpleDark),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.auto_awesome, color: GelatoTheme.purpleBright, size: 14),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Keep going! More milestones await.",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GelatoTheme.textLight),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: nextUpList.length,
                    itemBuilder: (context, index) {
                      return _buildBadge(nextUpList[index], index, true);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(Achievement item, int index, bool locked) {
    final double progressRatio = item.progressTarget > 0 ? item.progressCurrent / item.progressTarget : 0.0;
    
    // Format progress string
    String progressStr = "";
    if (item.id.contains("kg") || item.id == "low_risk_zone") {
      progressStr = "${item.progressCurrent.toStringAsFixed(1)} / ${item.progressTarget.toStringAsFixed(1)}";
    } else {
      progressStr = "${item.progressCurrent.round()} / ${item.progressTarget.round()}";
    }

    final Color color = _getColor(item.id);

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final offset = locked ? 0.0 : math.sin((_animController.value * math.pi) + (index * 1.5)) * 4;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(80, 80),
                    painter: _DoubleStarPainter(
                      outerColor: locked ? const Color(0xFFFEF3C7) : const Color(0xFFFDE047),
                      innerColor: locked ? const Color(0xFFFFFBEB) : Colors.white, 
                    ),
                  ),
                  if (locked)
                    Align(
                      alignment: const Alignment(0, 0.7),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_rounded, size: 12, color: GelatoTheme.purpleBright),
                      ),
                    ),
                  Center(
                    child: Icon(_getIconData(item.icon), size: 36, color: locked ? color.withValues(alpha: 0.5) : color),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: locked ? GelatoTheme.textDark.withValues(alpha: 0.7) : GelatoTheme.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: GelatoTheme.textLight,
              ),
            ),
            const SizedBox(height: 6),
            if (!locked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text("Earned ", style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                    Icon(Icons.check_circle_rounded, color: Color(0xFF166534), size: 10),
                  ],
                ),
              ),
            if (locked) ...[
              Text(
                progressStr,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(height: 4),
              Container(
                height: 4,
                width: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              if (item.id == 'lose_5kg') ...[
                const SizedBox(height: 4),
                Text(
                  "~${math.max(1, ((5.0 - item.progressCurrent) / 0.5).ceil())} wks at 0.5kg/wk",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: GelatoTheme.textLight),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DoubleStarPainter extends CustomPainter {
  final Color outerColor;
  final Color innerColor;

  _DoubleStarPainter({
    required this.outerColor,
    required this.innerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawStar(canvas, size.width / 2, size.width / 2, size.width / 2, size.width / 4, outerColor);
    _drawStar(canvas, size.width / 2, size.width / 2, size.width / 2.8, size.width / 5, innerColor);
  }

  void _drawStar(Canvas canvas, double cx, double cy, double outerRadius, double innerRadius, Color color) {
    final Path path = Path();
    final int points = 5;
    final double degreesPerStep = (math.pi * 2) / points;
    final double halfDegreesPerStep = degreesPerStep / 2;
    
    double currentAngle = -math.pi / 2;
    
    path.moveTo(
      cx + outerRadius * math.cos(currentAngle),
      cy + outerRadius * math.sin(currentAngle)
    );

    for (int i = 0; i < points; i++) {
      currentAngle += halfDegreesPerStep;
      path.lineTo(
        cx + innerRadius * math.cos(currentAngle),
        cy + innerRadius * math.sin(currentAngle)
      );
      currentAngle += halfDegreesPerStep;
      path.lineTo(
        cx + outerRadius * math.cos(currentAngle),
        cy + outerRadius * math.sin(currentAngle)
      );
    }
    path.close();

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill..strokeJoin = StrokeJoin.round);
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 4..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant _DoubleStarPainter oldDelegate) => false;
}
