import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/gelato_theme.dart';
import '../widgets/analytics_widgets.dart';
import '../providers/food_notifiers.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: GelatoTheme.textDark),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Insights',
          style: TextStyle(
            color: GelatoTheme.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotsPainter(color: Colors.black87.withValues(alpha: 0.04)),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSectionTitle('Recommendations'),
            const HorizontalInsightsCarousel(),
            const SizedBox(height: 30),
            _buildSectionTitle('Weekly Calories Trend'),
            const WeeklyTrendChartCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Macros Breakdown'),
            const MacrosBreakdownCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Nutrition Score'),
            const NutritionScoreCard(),
            const SizedBox(height: 40),
          ],
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: GelatoTheme.textDark,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

}

class HorizontalInsightsCarousel extends StatefulWidget {
  const HorizontalInsightsCarousel({super.key});

  @override
  State<HorizontalInsightsCarousel> createState() => _HorizontalInsightsCarouselState();
}

class _HorizontalInsightsCarouselState extends State<HorizontalInsightsCarousel> {
  List<Map<String, dynamic>> _generateInsights(BuildContext context) {
    final notifier = Provider.of<FoodDiaryNotifier>(context);
    final logs = notifier.allLogsList;
    final currentLog = notifier.dailyLog;
    List<Map<String, dynamic>> insights = [];

    // Check if user has zero meals logged anywhere
    final bool hasNoCurrentEntries = currentLog == null || currentLog.entries.isEmpty;
    if (hasNoCurrentEntries && logs.isEmpty) {
      return [
        {
          'title': 'Start Logging Meals',
          'desc': 'Log your breakfast, lunch, or dinner today to receive smart nutrition recommendations based on your actual intake.',
          'icon': Icons.restaurant_menu_rounded,
          'color': GelatoTheme.blue,
          'iconColor': GelatoTheme.blue,
        },
        {
          'title': 'Track Your Macros',
          'desc': 'Adding food items allows us to track your live protein, carbs, fats, and fiber balance.',
          'icon': Icons.pie_chart_rounded,
          'color': GelatoTheme.purple,
          'iconColor': GelatoTheme.purple,
        },
      ];
    }

    // 1. Current Day Calorie Status
    if (currentLog != null && currentLog.totalCalories > 0) {
      final cal = currentLog.totalCalories;
      final goal = notifier.calorieGoal;
      if (cal > goal * 1.1) {
        insights.add({
          'title': 'Calorie Goal Exceeded',
          'desc': 'You logged ${cal.toInt()} kcal today, exceeding your target goal of ${goal.toInt()} kcal.',
          'icon': Icons.local_fire_department_rounded,
          'color': GelatoTheme.pink,
          'iconColor': GelatoTheme.pink,
        });
      } else if (cal >= goal * 0.85) {
        insights.add({
          'title': 'Spot On Calorie Intake!',
          'desc': 'You logged ${cal.toInt()} kcal today, right on track for your ${goal.toInt()} kcal target.',
          'icon': Icons.check_circle_rounded,
          'color': GelatoTheme.green,
          'iconColor': GelatoTheme.green,
        });
      } else {
        final remaining = (goal - cal).toInt().clamp(0, 9999);
        insights.add({
          'title': 'Calories Remaining Today',
          'desc': 'You logged ${cal.toInt()} kcal today. You still have $remaining kcal remaining to hit your target.',
          'icon': Icons.bolt_rounded,
          'color': GelatoTheme.blue,
          'iconColor': GelatoTheme.blue,
        });
      }
    }

    // 2. Highest Calorie Item Logged Today
    if (currentLog != null && currentLog.entries.isNotEmpty) {
      var topEntry = currentLog.entries.first;
      double maxCal = topEntry.food.calories * topEntry.quantity;
      for (var e in currentLog.entries) {
        double c = e.food.calories * e.quantity;
        if (c > maxCal) {
          maxCal = c;
          topEntry = e;
        }
      }
      insights.add({
        'title': 'Top Calorie Contributor',
        'desc': '${topEntry.food.name} provided ${maxCal.toInt()} kcal in your ${topEntry.mealType} today.',
        'icon': Icons.star_rounded,
        'color': GelatoTheme.yellow,
        'iconColor': GelatoTheme.yellow,
      });
    }

    // 3. Meal Timing & Dinner Analysis across logs
    double dinnerCal = 0;
    int dinnerCount = 0;
    for (var log in logs) {
      for (var entry in log.entries) {
        if (entry.mealType == 'Dinner') {
          dinnerCal += entry.food.calories * entry.quantity;
          dinnerCount++;
        }
      }
    }
    if (dinnerCount > 0) {
      double avgDinner = dinnerCal / dinnerCount;
      if (avgDinner > notifier.calorieGoal * 0.4) {
        insights.add({
          'title': 'Heavy Dinners Detected',
          'desc': 'Your logged dinners average ${avgDinner.toInt()} kcal. Keeping evening meals lighter can aid restful sleep.',
          'icon': Icons.nightlight_round,
          'color': GelatoTheme.purple,
          'iconColor': GelatoTheme.purple,
        });
      } else {
        insights.add({
          'title': 'Balanced Evening Meals',
          'desc': 'Your logged dinners average ${avgDinner.toInt()} kcal, keeping your evening nutrition well-proportioned.',
          'icon': Icons.nightlight_round,
          'color': GelatoTheme.purple,
          'iconColor': GelatoTheme.purple,
        });
      }
    } else if (currentLog != null && currentLog.entries.any((e) => e.mealType == 'Breakfast')) {
      insights.add({
        'title': 'Breakfast Logged!',
        'desc': 'Starting your day by logging breakfast sets a healthy routine for steady metabolism.',
        'icon': Icons.wb_sunny_rounded,
        'color': GelatoTheme.purple,
        'iconColor': GelatoTheme.purple,
      });
    }

    // 4. Protein Trend
    if (logs.isNotEmpty) {
      double totalProteinAll = logs.fold(0.0, (sum, l) => sum + l.totalProtein);
      double avgProtein = totalProteinAll / logs.length;
      double targetProtein = (notifier.calorieGoal * 0.3) / 4.0;
      if (avgProtein >= targetProtein * 0.8) {
        insights.add({
          'title': 'Strong Protein Trend',
          'desc': 'You are averaging ${avgProtein.toInt()}g of protein per logged day (Target: ~${targetProtein.toInt()}g).',
          'icon': Icons.fitness_center_rounded,
          'color': GelatoTheme.blue,
          'iconColor': GelatoTheme.blue,
        });
      } else {
        insights.add({
          'title': 'Boost Protein Intake',
          'desc': 'You average ${avgProtein.toInt()}g of protein per logged day. Aim closer to ${targetProtein.toInt()}g for optimal recovery.',
          'icon': Icons.fitness_center_rounded,
          'color': GelatoTheme.blue,
          'iconColor': GelatoTheme.blue,
        });
      }
    }

    // 5. Fiber Trend
    if (logs.isNotEmpty) {
      double totalFiberAll = logs.fold(0.0, (sum, l) => sum + l.totalFiber);
      double avgFiber = totalFiberAll / logs.length;
      if (avgFiber >= 20.0) {
        insights.add({
          'title': 'Excellent Fiber Intake',
          'desc': 'You average ${avgFiber.toStringAsFixed(1)}g of fiber per logged day, promoting great digestion.',
          'icon': Icons.eco_rounded,
          'color': GelatoTheme.green,
          'iconColor': GelatoTheme.green,
        });
      } else {
        insights.add({
          'title': 'Increase Fiber Intake',
          'desc': 'Your logged fiber averages ${avgFiber.toStringAsFixed(1)}g per day. Try adding vegetables or legumes to hit 25g.',
          'icon': Icons.eco_rounded,
          'color': GelatoTheme.green,
          'iconColor': GelatoTheme.green,
        });
      }
    }

    if (insights.isEmpty) {
      insights.add({
        'title': 'Keep Logging Meals',
        'desc': 'Log more meals throughout the week to generate personalized nutritional recommendations.',
        'icon': Icons.insights_rounded,
        'color': GelatoTheme.blue,
        'iconColor': GelatoTheme.blue,
      });
    }

    return insights;
  }

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Start at a high number so we can loop infinitely to the right
    _pageController = PageController(viewportFraction: 0.8, initialPage: 1000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insightsList = _generateInsights(context);
    
    return SizedBox(
      height: 220, // Increased height so text doesn't cut off
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disables drag, rely entirely on taps
        itemBuilder: (context, index) {
          int dataIndex = index % insightsList.length;
          final insight = insightsList[dataIndex];

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double pageOffset = 0;
              if (_pageController.hasClients && _pageController.position.haveDimensions) {
                pageOffset = index - (_pageController.page ?? 1000.0);
              } else {
                pageOffset = index - 1000.0;
              }
              
              // Smoothly calculate scale and opacity based on distance from center
              double scale = (1 - (pageOffset.abs() * 0.15)).clamp(0.85, 1.0);
              double opacity = (1 - (pageOffset.abs() * 0.5)).clamp(0.4, 1.0);

              // 3D Arc Coverflow Math
              // Rotate cards inward: left card (offset < 0) rotates right, right card rotates left
              double rotationY = pageOffset * -0.5; 
              // Gentle arc: side cards drop down slightly
              double translateY = (pageOffset.abs() * 25.0);

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015) // Perspective
                  ..setTranslationRaw(0.0, translateY, 0.0) // Gentle arc drop
                  ..rotateY(rotationY), // Inward rotation
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                ),
              );
            },
            child: GestureDetector(
              onTap: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutSine, // Smooth carousel transition
                );
              },
              child: _buildInsightCard(
                title: insight['title'],
                description: insight['desc'],
                icon: insight['icon'],
                color: insight['color'],
                iconColor: insight['iconColor'],
                isCenter: true, // Styling logic is handled mostly by the parent Transform
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required bool isCenter,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color, // Filled with color
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black87, width: 2.0),
        boxShadow: [
          // Glow
          BoxShadow(
            color: color,
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
          // Hard shadow
          const BoxShadow(
            color: Colors.black87,
            blurRadius: 0,
            offset: Offset(4, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black87, width: 1.5),
                ),
                child: Icon(icon, color: Colors.black87, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15, // Slightly scaled down to fit better
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 2, // Allow wrapping
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GelatoTheme.textLight,
              height: 1.4,
            ),
            maxLines: 4, // Increased from 2 to prevent cutoff
            overflow: TextOverflow.ellipsis,
          ),
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
