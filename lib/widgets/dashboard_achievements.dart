import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class DashboardAchievements extends StatefulWidget {
  const DashboardAchievements({super.key});

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

  @override
  Widget build(BuildContext context) {
    // Data matching the image exactly
    final earnedItems = [
      _AchievementData(title: "7 Day Streak", sub: "Kept the streak alive!", icon: Icons.local_fire_department_rounded, color: GelatoTheme.orangeDark, bgColor: GelatoTheme.orange, progress: ""),
      _AchievementData(title: "Logged 50 Meals", sub: "Fueling your body right!", icon: Icons.restaurant_menu_rounded, color: GelatoTheme.greenDark, bgColor: GelatoTheme.green, progress: ""),
      _AchievementData(title: "First 10K Step Day", sub: "Big steps, big progress!", icon: Icons.directions_run_rounded, color: GelatoTheme.blueDark, bgColor: GelatoTheme.blue, progress: ""),
      _AchievementData(title: "Lost First 2 kg", sub: "You're getting lighter!", icon: Icons.monitor_weight_rounded, color: GelatoTheme.pinkDark, bgColor: GelatoTheme.pink, progress: ""),
      _AchievementData(title: "Risk Score Reduced", sub: "Healthier every day!", icon: Icons.favorite_rounded, color: GelatoTheme.pinkDark, bgColor: GelatoTheme.pink, progress: ""),
      _AchievementData(title: "Session Milestone", sub: "Learning. Growing. Winning!", icon: Icons.school_rounded, color: GelatoTheme.purpleDark, bgColor: GelatoTheme.purple, progress: ""),
    ];

    final lockedItems = [
      _AchievementData(title: "Lose 5 kg", sub: "You're on your way!", icon: Icons.monitor_weight_rounded, color: GelatoTheme.pinkDark, bgColor: GelatoTheme.pink, progress: "2.6 / 5 kg", progressRatio: 2.6/5, locked: true),
      _AchievementData(title: "Reach Low Risk Zone", sub: "Unlock a healthier you!", icon: Icons.health_and_safety_rounded, color: GelatoTheme.greenDark, bgColor: GelatoTheme.green, progress: "42 / 100", progressRatio: 42/100, locked: true),
      _AchievementData(title: "30 Day Streak", sub: "Consistency is power!", icon: Icons.calendar_month_rounded, color: GelatoTheme.purpleDark, bgColor: GelatoTheme.purple, progress: "14 / 30 days", progressRatio: 14/30, locked: true),
      _AchievementData(title: "Complete Program", sub: "Finish strong!", icon: Icons.emoji_events_rounded, color: GelatoTheme.yellowDark, bgColor: GelatoTheme.yellow, progress: "5 / 16 sessions", progressRatio: 5/16, locked: true),
      _AchievementData(title: "Wellness Champion", sub: "The ultimate achievement!", icon: Icons.workspace_premium_rounded, color: GelatoTheme.blueDark, bgColor: GelatoTheme.blue, progress: "0 / 1", progressRatio: 0.0, locked: true),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE), // Stronger pastel blue (blue-100) to highlight the golden stars
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder, // Add black border
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.emoji_events_rounded, color: GelatoTheme.yellowDark, size: 28),
              SizedBox(width: 12),
              Text('Achievements', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
              SizedBox(width: 8),
              Expanded(child: Text('Keep it up!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: GelatoTheme.purpleDark))),
            ],
          ),
          const SizedBox(height: 16),
          
          // Horizontal list of earned items
          SizedBox(
            height: 160,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: earnedItems.length,
              itemBuilder: (context, index) {
                return _buildBadge(earnedItems[index], index, false);
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // "Next Up" container
          Container(
            padding: const EdgeInsets.all(16),
            clipBehavior: Clip.antiAlias, // ADDED THIS TO PREVENT SCROLL BLEED
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
                    itemCount: lockedItems.length,
                    itemBuilder: (context, index) {
                      return _buildBadge(lockedItems[index], index, true);
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

  Widget _buildBadge(_AchievementData item, int index, bool locked) {
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
            // Pop-out Badge shape as a Star inside Star
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer golden star
                  CustomPaint(
                    size: const Size(80, 80),
                    painter: _DoubleStarPainter(
                      outerColor: locked ? const Color(0xFFFEF3C7) : const Color(0xFFFDE047),
                      innerColor: locked ? const Color(0xFFFFFBEB) : Colors.white, // Inner color white
                    ),
                  ),
                  // Lock icon or Main Icon
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
                  if (!locked || item.icon != null)
                    Center(
                      child: Icon(item.icon, size: 36, color: locked ? item.color.withValues(alpha: 0.5) : item.color),
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
              item.sub,
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
            if (locked && item.progress.isNotEmpty) ...[
              Text(
                item.progress,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: item.color),
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
                  widthFactor: item.progressRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
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
    // Draw inner star slightly smaller
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

class _AchievementData {
  final String title;
  final String sub;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String progress;
  final double progressRatio;
  final bool locked;

  _AchievementData({
    required this.title,
    required this.sub,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.progress,
    this.progressRatio = 0.0,
    this.locked = false,
  });
}
