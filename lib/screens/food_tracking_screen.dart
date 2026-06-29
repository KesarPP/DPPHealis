import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/gelato_theme.dart';
import '../data/handouts_data.dart';
import 'insights_screen.dart';
import 'handouts_screen.dart';
import 'food_search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/food_notifiers.dart';
import '../models/food_log.dart';
import '../models/food_item.dart';
import '../services/ai_food_service.dart';
import '../services/auth_service.dart';
import 'nutritional_scanner_screen.dart';

class FoodTrackingScreen extends StatefulWidget {
  const FoodTrackingScreen({super.key});

  @override
  State<FoodTrackingScreen> createState() => _FoodTrackingScreenState();
}

class _FoodTrackingScreenState extends State<FoodTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = context.read<FoodDiaryNotifier>();
      notifier.loadLogForDate(notifier.selectedDate);
      notifier.loadAllLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.green.withValues(alpha: 0.4),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DotsPainter(color: Colors.black87.withValues(alpha: 0.04)),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildBanner(context),
                  const SizedBox(height: 24),
                  _buildQuickActionsRow(context),
                  const SizedBox(height: 24),
                  const _WeeklyCalendar(),
                  const SizedBox(height: 24),
                  _buildCalorieGoalCard(context),
                  const SizedBox(height: 24),
                  _buildMealCards(context),
                  const SizedBox(height: 32),
                  _buildAchievementBox(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black87, width: 1.5),
          boxShadow: [
            BoxShadow(color: GelatoTheme.green.withValues(alpha: 0.2), blurRadius: 0, offset: const Offset(4, 4)),
          ],
          image: const DecorationImage(
            image: AssetImage('assets/images/meals_banner.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionCard(context, 'Insight', Icons.show_chart_rounded, GelatoTheme.purple),
          const SizedBox(width: 8),
          _buildQuickActionCard(context, 'Label Scanner', Icons.document_scanner, GelatoTheme.yellow),
          const SizedBox(width: 8),
          _buildQuickActionCard(context, 'Resources', Icons.menu_book_rounded, GelatoTheme.blue),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (title == 'Insight') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsScreen()));
          } else if (title == 'Label Scanner') {
            _openLabelScanner(context);
          } else if (title == 'Resources') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HandoutsScreen(title: 'Food Resources', handouts: foodHandouts)));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black87, width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(3, 3)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: GelatoTheme.textDark),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GelatoTheme.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLabelScanner(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NutritionalScannerScreen(imageFile: File(pickedFile.path)),
        ),
      );
    }
  }

  Widget _buildCalorieGoalCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer<FoodDiaryNotifier>(
        builder: (context, notifier, child) {
          final totalCalories = notifier.dailyLog?.totalCalories ?? 0.0;
          final goal = notifier.calorieGoal;
          final left = goal - totalCalories;
          final progress = totalCalories / goal;
          
          String motivationText = 'Keep it up! You are doing great.';
          if (progress > 1.0) {
            motivationText = "You've exceeded your goal!";
          } else if (progress > 0.8) {
            motivationText = "Almost there!";
          }
          
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black87, width: 1.5),
              boxShadow: [
                BoxShadow(color: GelatoTheme.yellow.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(4, 4)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Today\'s Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
                      const SizedBox(height: 8),
                      Text('${totalCalories.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} kcal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GelatoTheme.textDark.withValues(alpha: 0.7))),
                      const SizedBox(height: 12),
                      Text(motivationText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GelatoTheme.textDark)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress > 1 ? 1.0 : progress,
                        strokeWidth: 8,
                        backgroundColor: GelatoTheme.green.withValues(alpha: 0.2),
                        color: GelatoTheme.green,
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(left > 0 ? left.toStringAsFixed(0) : '0', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
                            Text('left', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GelatoTheme.textDark.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer<FoodDiaryNotifier>(
        builder: (context, notifier, child) {
          final log = notifier.dailyLog;
          final String todayStr = DateTime.now().toIso8601String().split('T')[0];
          final bool isEditable = notifier.selectedDate == todayStr;
          
          List<LoggedFood> getItems(String mealType) {
            return log?.entries.where((e) => e.mealType == mealType).toList() ?? [];
          }

          return Column(
            children: [
              _ExpandableMealCard(
                title: 'Breakfast',
                color: GelatoTheme.yellow,
                items: getItems('Breakfast'),
                isEditable: isEditable,
              ),
              const SizedBox(height: 16),
              _ExpandableMealCard(
                title: 'Snack 1',
                color: GelatoTheme.orange,
                items: getItems('Snack 1')..addAll(getItems('Snack')),
                isEditable: isEditable,
              ),
              const SizedBox(height: 16),
              _ExpandableMealCard(
                title: 'Lunch',
                color: GelatoTheme.green,
                items: getItems('Lunch'),
                isEditable: isEditable,
              ),
              const SizedBox(height: 16),
              _ExpandableMealCard(
                title: 'Snack 2',
                color: GelatoTheme.pink,
                items: getItems('Snack 2'),
                isEditable: isEditable,
              ),
              const SizedBox(height: 16),
              _ExpandableMealCard(
                title: 'Dinner',
                color: GelatoTheme.blue,
                items: getItems('Dinner'),
                isEditable: isEditable,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAchievementBox(BuildContext context) {
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
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text('Your Achievements!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                imageScale: 1.4, // Keep fractionally sized
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
                imageScale: 1.4,
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
                imageScale: 1.5,
                imageOffsetX: 5.0,
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
      // Top Left
      Positioned(top: 8, left: 8, child: _TeardropOrnament(color: color, corner: Alignment.topLeft, size: 10)),
      Positioned(top: 5, left: 20, child: smallCircle()),
      Positioned(top: 20, left: 5, child: smallCircle()),

      // Top Right
      Positioned(top: 8, right: 8, child: _TeardropOrnament(color: color, corner: Alignment.topRight, size: 10)),
      Positioned(top: 5, right: 20, child: smallCircle()),
      Positioned(top: 20, right: 5, child: smallCircle()),

      // Bottom Left
      Positioned(bottom: 8, left: 8, child: _TeardropOrnament(color: color, corner: Alignment.bottomLeft, size: 10)),
      Positioned(bottom: 5, left: 20, child: smallCircle()),
      Positioned(bottom: 20, left: 5, child: smallCircle()),

      // Bottom Right
      Positioned(bottom: 8, right: 8, child: _TeardropOrnament(color: color, corner: Alignment.bottomRight, size: 10)),
      Positioned(bottom: 5, right: 20, child: smallCircle()),
      Positioned(bottom: 20, right: 5, child: smallCircle()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 32),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 155,
            height: 280,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.8),
                  bgColor,
                ],
                center: Alignment.topCenter,
                radius: 1.5,
              ),
              borderRadius: BorderRadius.circular(12), // Slightly rounded outer corner
              border: Border.all(color: borderColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.8),
                  blurRadius: 15,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Inner Border
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(2), // Edges join/run very close to the outer border
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(45), // Extremely rounded inner corner
                      border: Border.all(color: borderColor.withValues(alpha: 0.8), width: 2.0), // Slightly thicker
                    ),
                  ),
                ),
                ..._buildCornerDecorations(borderColor),
                // Inner Content Layout
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32.0, left: 12.0, right: 12.0, bottom: 16.0),
                    child: Column(
                      children: [
                        // Icon Area (65%)
                        Expanded(
                          flex: 85,
                          child: Transform.translate(
                            offset: Offset(imageOffsetX, -25 + imageOffsetY),
                            child: Center(
                              child: imagePath != null
                                  ? FractionallySizedBox(
                                      widthFactor: imageScale,
                                      heightFactor: imageScale,
                                      child: Image.asset(
                                        imagePath!,
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) => Icon(Icons.shield_outlined, size: 145, color: borderColor),
                                      ),
                                    )
                                  : Icon(Icons.shield_outlined, size: 145, color: borderColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Text Area (35%)
                        Expanded(
                          flex: 35,
                          child: Transform.translate(
                            offset: const Offset(0, -25), // Moved up by 15 pixels
                            child: OverflowBox(
                              maxHeight: double.infinity,
                              child: title != null
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.translate(
                                          offset: const Offset(0, 0), // Adjust title position
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              title!,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: const Color(0xFF001F54), // Deep Dark Blue
                                                fontSize: 20, // Slightly reduced
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.8, // Slightly tighter for title
                                                height: 1.15, // Better line spacing
                                                shadows: [
                                                  Shadow(offset: const Offset(1, 2), color: Colors.black.withValues(alpha: 0.15), blurRadius: 4), // Softer shadow
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Transform.translate(
                                          offset: const Offset(0, -1), // Adjust subtitle position
                                          child: Text(
                                            subtitle ?? 'MONTHLY',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: const Color(0xFFC2185B), // Dark Pink
                                              fontSize: 14, // Better hierarchy relative to title
                                              fontWeight: FontWeight.w800, // A bit softer than 900
                                              letterSpacing: 1.5, // Wider for caps gives a cute modern feel
                                              shadows: [
                                                Shadow(offset: const Offset(1, 1), color: Colors.black.withValues(alpha: 0.1), blurRadius: 2), // Very subtle shadow
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (completedDays != null && totalDays != null) ...[
                                          const SizedBox(height: 6),
                                          Transform.translate(
                                            offset: const Offset(0, -10), // Adjust slider position
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Slider bar
                                                  SizedBox(
                                                    width: 55,
                                                    height: 24,
                                                    child: Stack(
                                                      alignment: Alignment.centerLeft,
                                                      children: [
                                                        // Background Track
                                                        Container(
                                                          height: 12,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white.withValues(alpha: 0.6),
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(color: const Color(0xFFC2185B), width: 1.5), // Pink Outline
                                                          ),
                                                        ),
                                                        // Filled Track (Golden)
                                                        FractionallySizedBox(
                                                          widthFactor: completedDays! / totalDays!,
                                                          child: Container(
                                                            height: 12,
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFFFFD700), // Gold
                                                              borderRadius: BorderRadius.circular(6),
                                                              border: Border.all(color: const Color(0xFFC2185B), width: 1.5), // Pink Outline
                                                              boxShadow: [
                                                                BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.4), blurRadius: 4),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        // Thumb (Pink with white outline)
                                                        Positioned(
                                                          left: (55 - 20) * (completedDays! / totalDays!),
                                                          child: Container(
                                                            width: 20,
                                                            height: 20,
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFFC2185B), // Dark Pink
                                                              shape: BoxShape.circle,
                                                              border: Border.all(color: Colors.white, width: 2.5),
                                                              boxShadow: [
                                                                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 2, offset: const Offset(1, 1)),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Text X/7
                                                  Text(
                                                    '$completedDays/$totalDays',
                                                    style: const TextStyle(
                                                      color: Color(0xFF001F54), // Deep Dark Blue
                                                      fontSize: 14, // More readable
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (description != null) ...[
                                          const SizedBox(height: 8),
                                          Transform.translate(
                                            offset: const Offset(0, -14), // Adjust description position
                                            child: Text(
                                              description!,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: const Color(0xFF001F54).withValues(alpha: 0.75), // Deep Dark Blue faded
                                                fontSize: 11, // Larger and readable
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.3,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    )
                                : const SizedBox.shrink(),
                            ),
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
            top: -28,
            child: SizedBox(
              width: 60,
              height: 45,
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

    Paint darkFillPaint = Paint()
      ..color = crownColor.withValues(alpha: 0.6); // Darker for back spikes

    Paint jewelRed = Paint()..color = const Color(0xFFE91E63);
    Paint jewelBlue = Paint()..color = const Color(0xFF2196F3);

    // 1. Back Spikes
    Path backSpikes = Path()
      ..moveTo(10, 25)
      ..quadraticBezierTo(13, 16, 15, 12)
      ..quadraticBezierTo(18, 16, 25, 20)
      ..moveTo(35, 20)
      ..quadraticBezierTo(42, 16, 45, 12)
      ..quadraticBezierTo(47, 16, 50, 25);
    
    canvas.drawPath(backSpikes, darkFillPaint);
    canvas.drawPath(backSpikes, strokePaint);

    // 2. Main Crown Body
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

    // 3. Base Rim
    Path rim = Path()
      ..moveTo(6, 36)
      ..quadraticBezierTo(30, 43, 54, 36)
      ..quadraticBezierTo(55, 38, 54, 39)
      ..quadraticBezierTo(30, 46, 6, 39)
      ..quadraticBezierTo(5, 38, 6, 36)
      ..close();
      
    canvas.drawPath(rim, fillPaint);
    canvas.drawPath(rim, strokePaint);

    // 4. Pearls
    void drawPearl(double x, double y, double r) {
      canvas.drawCircle(Offset(x, y), r, fillPaint);
      canvas.drawCircle(Offset(x, y), r, strokePaint);
      canvas.drawCircle(Offset(x - r*0.3, y - r*0.3), r*0.3, Paint()..color = Colors.white.withValues(alpha: 0.6));
    }

    drawPearl(15, 12, 2.5);
    drawPearl(45, 12, 2.5);
    drawPearl(5, 20, 3.5);
    drawPearl(55, 20, 3.5);
    drawPearl(30, 5, 4.5);

    // 5. Jewels
    Path diamond = Path()
      ..moveTo(30, 20)
      ..lineTo(34, 26)
      ..lineTo(30, 32)
      ..lineTo(26, 26)
      ..close();
    canvas.drawPath(diamond, jewelRed);
    canvas.drawPath(diamond, strokePaint..strokeWidth = 1.0);

    Path diamondHighlight = Path()
      ..moveTo(30, 22)
      ..lineTo(32, 26)
      ..lineTo(30, 26)
      ..close();
    canvas.drawPath(diamondHighlight, Paint()..color = Colors.white.withValues(alpha: 0.5));

    canvas.drawCircle(const Offset(18, 31), 2, jewelBlue);
    canvas.drawCircle(const Offset(18, 31), 2, strokePaint..strokeWidth = 1.0);
    
    canvas.drawCircle(const Offset(42, 31), 2, jewelBlue);
    canvas.drawCircle(const Offset(42, 31), 2, strokePaint..strokeWidth = 1.0);

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

class _WeeklyCalendar extends StatefulWidget {
  const _WeeklyCalendar();

  @override
  State<_WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<_WeeklyCalendar> {
  late PageController _pageController;
  late DateTime _currentWeekStart;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _today.subtract(Duration(days: _today.weekday % 7));
    _pageController = PageController(initialPage: 1000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(int pageIndex) {
    int offsetWeeks = pageIndex - 1000;
    return _currentWeekStart.add(Duration(days: offsetWeeks * 7));
  }

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final foodNotifier = context.watch<FoodDiaryNotifier>();
    final completedDays = foodNotifier.completedDays;
    final selectedDate = foodNotifier.selectedDate;
    
    // Check if the selected date specifically is completed
    bool todayHasAllMeals = completedDays[selectedDate] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.5),
            builder: (context) => const _MonthlyCalendarOverlay(),
          );
        },
        child: Container(
          decoration: BoxDecoration(
          color: GelatoTheme.pink,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black87, width: 1.5),
          boxShadow: [
            BoxShadow(color: GelatoTheme.green.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(4, 4)),
          ],
        ),
        child: Column(
          children: [
            // Month Year Header
            Container(
              decoration: const BoxDecoration(
                color: GelatoTheme.green,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                border: Border(bottom: BorderSide(color: Colors.black87, width: 1.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    child: const Icon(Icons.chevron_left, color: GelatoTheme.textDark),
                  ),
                  AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      int currentPage = _pageController.hasClients ? _pageController.page?.round() ?? 1000 : 1000;
                      DateTime weekStart = _getWeekStart(currentPage);
                      DateTime midWeek = weekStart.add(const Duration(days: 3));
                      String monthName = _months[midWeek.month - 1];
                      return Text(
                        '$monthName ${midWeek.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    child: const Icon(Icons.chevron_right, color: GelatoTheme.textDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Static Days of the week
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
                Container(
                  width: 44,
                  alignment: Alignment.center,
                  child: Text(
                    day, 
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: GelatoTheme.textDark.withValues(alpha: 0.7)),
                  ),
                )
              ).toList(),
            ),
            const SizedBox(height: 12),
            // PageView for weeks
            SizedBox(
              height: 40,
              child: PageView.builder(
                controller: _pageController,
                itemBuilder: (context, index) {
                  DateTime weekStart = _getWeekStart(index);
                  return _buildWeekRow(weekStart, completedDays);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildWeekRow(DateTime weekStart, Map<String, bool> completedDays) {
    DateTime? signUpTime;
    final authService = AuthService();
    if (authService.isFirebaseInitialized) {
      signUpTime = authService.currentUser?.metadata.creationTime;
    }
    DateTime? signUpDate;
    if (signUpTime != null) {
      signUpDate = DateTime(signUpTime.year, signUpTime.month, signUpTime.day);
    }
    DateTime todayDate = DateTime(_today.year, _today.month, _today.day);
    final selectedDate = context.read<FoodDiaryNotifier>().selectedDate;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        DateTime date = weekStart.add(Duration(days: i));
        String dateString = date.toIso8601String().split('T')[0];
        DateTime currentDay = DateTime(date.year, date.month, date.day);
        
        bool isToday = currentDay.isAtSameMomentAs(todayDate);
        bool isSelected = dateString == selectedDate;
        bool isFuture = currentDay.isAfter(todayDate);
        bool isBeforeSignUp = signUpDate != null && currentDay.isBefore(signUpDate);
        
        bool isComplete = completedDays[dateString] == true;
        // Incomplete is any day after (or on) sign up that is not future and not complete
        bool isIncomplete = !isFuture && !isBeforeSignUp && !isComplete; 

        return GestureDetector(
          onTap: () {
            if (!isFuture) {
              context.read<FoodDiaryNotifier>().setSelectedDate(dateString);
            }
          },
          child: Container(
            width: 44,
            alignment: Alignment.center,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isSelected ? GelatoTheme.green : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                            color: isSelected ? Colors.black87 : (isBeforeSignUp ? GelatoTheme.textDark.withValues(alpha: 0.3) : GelatoTheme.textDark),
                          ),
                        ),
                      ),
                    ),
                  if (isIncomplete && !isToday)
                    Positioned(
                      bottom: -2,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  if (isComplete && !isToday)
                    Positioned(
                      bottom: -2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: GelatoTheme.greenDark,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ExpandableMealCard extends StatefulWidget {
  final String title;
  final Color color;
  final List<LoggedFood> items;
  final bool isEditable;

  const _ExpandableMealCard({
    required this.title,
    required this.color,
    required this.items,
    this.isEditable = true,
  });

  @override
  State<_ExpandableMealCard> createState() => _ExpandableMealCardState();
}

class _ExpandableMealCardState extends State<_ExpandableMealCard> {
  bool _isExpanded = false;
  bool _isScanning = false;

  Future<void> _scanFood() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _isScanning = true);
      
      try {
        final result = await AiFoodService().identifyFood(File(pickedFile.path));
        
        if (!mounted) return;
        setState(() => _isScanning = false);

        if (result != null && result.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodSearchScreen(
                mealType: widget.title,
                initialSearchQuery: result,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not identify food. Please try again or search manually.')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double _carbs = 0;
    double _protein = 0;
    double _fat = 0;
    double _fiber = 0;

    for (var item in widget.items) {
      _carbs += item.food.carbs * item.quantity;
      _protein += item.food.protein * item.quantity;
      _fat += item.food.fat * item.quantity;
      _fiber += item.food.fiber * item.quantity;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black87, width: 1.5),
          boxShadow: [
            BoxShadow(color: widget.color.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(4, 4)),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: GelatoTheme.textDark),
                  ),
                  if (widget.isEditable) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isScanning ? null : _scanFood,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black87, width: 1.2),
                        ),
                        child: _isScanning 
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: GelatoTheme.textDark)
                              )
                            : const Icon(Icons.camera_alt_outlined, size: 20, color: GelatoTheme.textDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FoodSearchScreen(mealType: widget.title),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black87, width: 1.2),
                        ),
                        child: const Icon(Icons.add, size: 20, color: GelatoTheme.textDark),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(color: Colors.black12, height: 1),
            
            // Empty State
            if (widget.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No food added yet.', style: TextStyle(color: GelatoTheme.textDark.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
              )
            else
              // Items
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: widget.items.map((item) => _buildFoodItemRow(context, item)).toList(),
                ),
              ),
              
            // Expandable Macros
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                heightFactor: _isExpanded ? 1.0 : 0.0,
                child: _buildMacros(_carbs, _protein, _fat, _fiber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemRow(BuildContext context, LoggedFood item) {
    final food = item.food;
    final qty = item.quantity;
    final totalCals = food.calories * qty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(qty > 1 ? '${food.name} (x$qty)' : food.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                const SizedBox(height: 2),
                Text('C:${(food.carbs * qty).toStringAsFixed(1)}g, P:${(food.protein * qty).toStringAsFixed(1)}g, F:${(food.fat * qty).toStringAsFixed(1)}g', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GelatoTheme.textDark.withValues(alpha: 0.6))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${totalCals.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  final date = context.read<FoodDiaryNotifier>().selectedDate;
                  context.read<FoodDiaryNotifier>().removeFood(item, date);
                },
                child: const Icon(Icons.remove_circle_outline, color: GelatoTheme.pinkDark, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacros(double carbs, double protein, double fat, double fiber) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 12),
          _buildProgressBar('Carbs', carbs, 60, GelatoTheme.orange),
          _buildProgressBar('Protein', protein, 40, GelatoTheme.purple),
          _buildProgressBar('Fat', fat, 20, GelatoTheme.yellow),
          _buildProgressBar('Fiber', fiber, 15, GelatoTheme.green),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double current, double limit, Color color) {
    double progress = limit > 0 ? current / limit : 0;
    if (progress > 1.0) progress = 1.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 65, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GelatoTheme.textDark))),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.2),
                color: color,
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 65, child: Text('${current.toStringAsFixed(1)}g / ${limit.toStringAsFixed(0)}g', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: GelatoTheme.textDark), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color color;
  _DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 20.0;
    const radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MonthlyCalendarOverlay extends StatefulWidget {
  const _MonthlyCalendarOverlay();

  @override
  State<_MonthlyCalendarOverlay> createState() => _MonthlyCalendarOverlayState();
}

class _MonthlyCalendarOverlayState extends State<_MonthlyCalendarOverlay> {
  late DateTime _currentMonth;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_today.year, _today.month, 1);
  }

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: GelatoTheme.pink,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black87, width: 1.5),
            boxShadow: [
              BoxShadow(color: GelatoTheme.green.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(4, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  color: GelatoTheme.green,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                  border: Border(bottom: BorderSide(color: Colors.black87, width: 1.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                        });
                      },
                      child: const Icon(Icons.chevron_left, color: GelatoTheme.textDark),
                    ),
                    Text(
                      '${_months[_currentMonth.month - 1]} ${_currentMonth.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                        });
                      },
                      child: const Icon(Icons.chevron_right, color: GelatoTheme.textDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Days Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      day, 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: GelatoTheme.textDark.withValues(alpha: 0.7)),
                    ),
                  )
                ).toList(),
              ),
              const SizedBox(height: 12),
              // Grid
              _buildMonthGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final foodNotifier = context.watch<FoodDiaryNotifier>();
    final completedDays = foodNotifier.completedDays;

    int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    int firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    // Dart DateTime.weekday: 1=Mon, 7=Sun. We want Sun=0, Mon=1.
    int emptyPrefixDays = firstWeekday == 7 ? 0 : firstWeekday;

    List<Widget> dayWidgets = [];
    for (int i = 0; i < emptyPrefixDays; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    DateTime? signUpTime;
    final authService = AuthService();
    if (authService.isFirebaseInitialized) {
      signUpTime = authService.currentUser?.metadata.creationTime;
    }
    DateTime? signUpDate;
    if (signUpTime != null) {
      signUpDate = DateTime(signUpTime.year, signUpTime.month, signUpTime.day);
    }
    DateTime todayDate = DateTime(_today.year, _today.month, _today.day);
    final selectedDate = foodNotifier.selectedDate;

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(_currentMonth.year, _currentMonth.month, i);
      String dateString = date.toIso8601String().split('T')[0];
      
      bool isToday = date.isAtSameMomentAs(todayDate);
      bool isSelected = dateString == selectedDate;
      bool isFuture = date.isAfter(todayDate);
      bool isBeforeSignUp = signUpDate != null && date.isBefore(signUpDate);
      
      bool isComplete = completedDays[dateString] == true;
      bool isIncomplete = !isFuture && !isBeforeSignUp && !isComplete;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            if (!isFuture) {
              context.read<FoodDiaryNotifier>().setSelectedDate(dateString);
              Navigator.pop(context);
            }
          },
          child: Container(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? GelatoTheme.green : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$i',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected ? Colors.black87 : (isBeforeSignUp ? GelatoTheme.textDark.withValues(alpha: 0.3) : GelatoTheme.textDark),
                      ),
                    ),
                  ),
                ),
              if (isIncomplete && !isToday)
                Positioned(
                  bottom: -2,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (isComplete && !isToday)
                Positioned(
                  bottom: -2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: GelatoTheme.greenDark,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: dayWidgets,
      ),
    );
  }
}
