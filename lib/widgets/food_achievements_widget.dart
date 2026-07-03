import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/gelato_theme.dart';
import '../providers/food_notifiers.dart';

class FoodAchievementsWidget extends StatelessWidget {
  const FoodAchievementsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<FoodDiaryNotifier>();
    final completedDaysMap = notifier.completedDays;
    final ninjaDaysMap = notifier.nutritionNinjaDays;
    
    int consistencyStreak = 0;
    int ninjaStreak = 0;
    DateTime d = DateTime.now();
    for (int i = 0; i < 365; i++) {
      String dateStr = d.subtract(Duration(days: i)).toIso8601String().split('T')[0];
      if (completedDaysMap[dateStr] == true) {
        consistencyStreak++;
      } else {
        break;
      }
    }
    
    for (int i = 0; i < 365; i++) {
      String dateStr = d.subtract(Duration(days: i)).toIso8601String().split('T')[0];
      if (ninjaDaysMap[dateStr] == true) {
        ninjaStreak++;
      } else {
        break;
      }
    }
    
    DateTime now = DateTime.now();
    int daysInCurrentMonth = DateTime(now.year, now.month + 1, 0).day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Food Badges',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: GelatoTheme.textDark),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: [
              _AchievementCard(
                bgColor: const Color(0xFFA8E4A0),
                borderColor: const Color(0xFFC69C6D),
                imagePath: 'assets/images/Weekly_Consistency_Champion.png',
                title: 'CONSISTENCY\nCHAMPION',
                subtitle: 'WEEKLY',
                description: '7 days of pure focus. No excuses, just logging!',
                completedDays: consistencyStreak.clamp(0, 7),
                totalDays: 7,
                imageScale: 1.3,
              ),
              _AchievementCard(
                bgColor: const Color(0xFFFFB6C1),
                borderColor: const Color(0xFFC69C6D),
                imagePath: 'assets/images/Monthly_Consistency_Champion.png',
                title: 'CONSISTENCY\nCHAMPION',
                subtitle: 'MONTHLY',
                description: 'An entire month of perfection. You are a logging machine!',
                completedDays: consistencyStreak.clamp(0, daysInCurrentMonth),
                totalDays: daysInCurrentMonth,
                imageScale: 1.0,
              ),
              _AchievementCard(
                bgColor: const Color(0xFFFFD54F),
                borderColor: const Color(0xFFC69C6D),
                imagePath: 'assets/images/Yearly_Consistency_Champion.png',
                title: 'CONSISTENCY\nCHAMPION',
                subtitle: 'YEARLY',
                description: '12 months of flawless tracking. We should build a statue of you!',
                completedDays: (consistencyStreak ~/ 30).clamp(0, 12),
                totalDays: 12,
                imageScale: 1.3,
                imageOffsetX: 4.5,
              ),
              _AchievementCard(
                bgColor: const Color(0xFFD8BFD8),
                borderColor: const Color(0xFFC69C6D),
                imagePath: 'assets/images/Weekly_Nutrition_Ninja.png',
                title: 'NUTRITION\nNINJA',
                subtitle: 'WEEKLY',
                description: 'A full week hitting your calorie goals. Your metabolism is terrified!',
                completedDays: ninjaStreak.clamp(0, 7),
                totalDays: 7,
                imageScale: 0.85,
              ),
              _AchievementCard(
                bgColor: const Color(0xFFA0E8E8),
                borderColor: const Color(0xFFC69C6D),
                imagePath: 'assets/images/Monthly_Nutrition_Ninja.png',
                title: 'NUTRITION\nNINJA',
                subtitle: 'MONTHLY',
                description: 'A whole month in the green. You bend calories to your will!',
                completedDays: ninjaStreak.clamp(0, daysInCurrentMonth),
                totalDays: daysInCurrentMonth,
                imageScale: 0.85,
              ),
              _AchievementCard(
                bgColor: const Color(0xFFFFB347),
                borderColor: const Color(0xFFC69C6D),
                imagePath: 'assets/images/Yearly_Nutrition_Ninja.png',
                title: 'NUTRITION\nNINJA',
                subtitle: 'YEARLY',
                description: '12 straight months of ninja precision. You are a nutritional legend!',
                completedDays: (ninjaStreak ~/ 30).clamp(0, 12),
                totalDays: 12,
                imageScale: 0.85,
                imageOffsetY: -10.0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final String? imagePath;
  final String? title;
  final String? subtitle;
  final String? description;
  final int? completedDays;
  final int? totalDays;
  final double imageScale;
  final double imageOffsetX;
  final double imageOffsetY;

  const _AchievementCard({
    required this.bgColor,
    required this.borderColor,
    this.imagePath,
    this.title,
    this.subtitle,
    this.description,
    this.completedDays,
    this.totalDays,
    this.imageScale = 1.15,
    this.imageOffsetX = 0.0,
    this.imageOffsetY = 0.0,
  });

  List<Widget> _buildCornerDecorations(Color color) {
    Widget smallCircle() => Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );

    return [
      Positioned(top: 8, left: 8, child: _TeardropOrnament(color: color, corner: Alignment.topLeft, size: 10)),
      Positioned(top: 5, left: 20, child: smallCircle()),
      Positioned(top: 20, left: 5, child: smallCircle()),
      Positioned(top: 8, right: 8, child: _TeardropOrnament(color: color, corner: Alignment.topRight, size: 10)),
      Positioned(top: 5, right: 20, child: smallCircle()),
      Positioned(top: 20, right: 5, child: smallCircle()),
      Positioned(bottom: 8, left: 8, child: _TeardropOrnament(color: color, corner: Alignment.bottomLeft, size: 10)),
      Positioned(bottom: 5, left: 20, child: smallCircle()),
      Positioned(bottom: 20, left: 5, child: smallCircle()),
      Positioned(bottom: 8, right: 8, child: _TeardropOrnament(color: color, corner: Alignment.bottomRight, size: 10)),
      Positioned(bottom: 5, right: 20, child: smallCircle()),
      Positioned(bottom: 20, right: 5, child: smallCircle()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 145,
            height: 250,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.8),
                  bgColor,
                ],
                center: Alignment.topCenter,
                radius: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45),
                      border: Border.all(color: borderColor.withValues(alpha: 0.8), width: 2.0),
                    ),
                  ),
                ),
                ..._buildCornerDecorations(borderColor),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24.0, left: 10.0, right: 10.0, bottom: 12.0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 60,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.5),
                                ),
                              ),
                              if (imagePath != null)
                                Transform.translate(
                                  offset: Offset(imageOffsetX, imageOffsetY),
                                  child: Transform.scale(
                                    scale: imageScale,
                                    child: Image.asset(
                                      imagePath!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 40,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (title != null)
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    title!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF001F54),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                      shadows: [
                                        Shadow(offset: const Offset(1, 1), color: Colors.black.withValues(alpha: 0.15), blurRadius: 2),
                                      ],
                                    ),
                                  ),
                                ),
                              Transform.translate(
                                offset: const Offset(0, -1),
                                child: Text(
                                  subtitle ?? 'MONTHLY',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFC2185B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              if (completedDays != null && totalDays != null) ...[
                                const SizedBox(height: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        height: 20,
                                        child: Stack(
                                          alignment: Alignment.centerLeft,
                                          children: [
                                            Container(
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.6),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: borderColor, width: 1),
                                              ),
                                            ),
                                            FractionallySizedBox(
                                              widthFactor: (completedDays! / totalDays!).clamp(0.0, 1.0),
                                              child: Container(
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFC2185B),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$completedDays/$totalDays',
                                        style: const TextStyle(
                                          color: Color(0xFF001F54),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -24,
            child: SizedBox(
              width: 50,
              height: 38,
              child: CustomPaint(
                painter: _CrownPainter(
                  crownColor: bgColor,
                  borderColor: borderColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrownPainter extends CustomPainter {
  final Color crownColor;
  final Color borderColor;

  _CrownPainter({required this.crownColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 60, size.height / 45);

    Paint strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round;

    Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.8), crownColor],
      ).createShader(const Rect.fromLTWH(0, 0, 60, 45));

    Paint darkFillPaint = Paint()..color = crownColor.withValues(alpha: 0.6);

    Path backSpikes = Path()
      ..moveTo(10, 25)
      ..quadraticBezierTo(13, 16, 15, 12)
      ..quadraticBezierTo(18, 16, 25, 20)
      ..moveTo(35, 20)
      ..quadraticBezierTo(42, 16, 45, 12)
      ..quadraticBezierTo(47, 16, 50, 25);

    canvas.drawPath(backSpikes, darkFillPaint);
    canvas.drawPath(backSpikes, strokePaint);

    Path body = Path()
      ..moveTo(10, 35)
      ..quadraticBezierTo(5, 28, 5, 20)
      ..quadraticBezierTo(15, 27, 20, 28)
      ..quadraticBezierTo(25, 15, 30, 5)
      ..quadraticBezierTo(35, 15, 40, 28)
      ..quadraticBezierTo(45, 27, 55, 20)
      ..quadraticBezierTo(55, 28, 50, 35)
      ..quadraticBezierTo(30, 41, 10, 35)
      ..close();

    canvas.drawPath(body, fillPaint);
    canvas.drawPath(body, strokePaint);

    Path rim = Path()
      ..moveTo(6, 36)
      ..quadraticBezierTo(30, 43, 54, 36)
      ..quadraticBezierTo(55, 38, 54, 39)
      ..quadraticBezierTo(30, 46, 6, 39)
      ..quadraticBezierTo(5, 38, 6, 36)
      ..close();

    canvas.drawPath(rim, fillPaint);
    canvas.drawPath(rim, strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TeardropOrnament extends StatelessWidget {
  final Color color;
  final Alignment corner;
  final double size;

  const _TeardropOrnament({
    required this.color,
    required this.corner,
    this.size = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    BorderRadius radius;
    if (corner == Alignment.topLeft) {
      radius = BorderRadius.only(
        topLeft: const Radius.circular(0),
        topRight: Radius.circular(size),
        bottomLeft: Radius.circular(size),
        bottomRight: Radius.circular(size),
      );
    } else if (corner == Alignment.topRight) {
      radius = BorderRadius.only(
        topLeft: Radius.circular(size),
        topRight: const Radius.circular(0),
        bottomLeft: Radius.circular(size),
        bottomRight: Radius.circular(size),
      );
    } else if (corner == Alignment.bottomLeft) {
      radius = BorderRadius.only(
        topLeft: Radius.circular(size),
        topRight: Radius.circular(size),
        bottomLeft: const Radius.circular(0),
        bottomRight: Radius.circular(size),
      );
    } else {
      radius = BorderRadius.only(
        topLeft: Radius.circular(size),
        topRight: Radius.circular(size),
        bottomLeft: Radius.circular(size),
        bottomRight: const Radius.circular(0),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
      ),
    );
  }
}
