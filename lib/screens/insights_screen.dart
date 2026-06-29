import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../widgets/analytics_widgets.dart';

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
            _buildSectionTitle('AI Insights'),
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
    List<Map<String, dynamic>> insights = [];

    // 1. Dinner Analysis
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
    if (dinnerCount > 0 && (dinnerCal / dinnerCount) > notifier.calorieGoal * 0.4) {
      insights.add({
        'title': 'Heavy Dinners',
        'desc': 'Your dinner calories are quite high. Consider lighter dinners to improve digestion and rest.',
        'icon': Icons.nightlight_round,
        'color': GelatoTheme.purple,
        'iconColor': GelatoTheme.purple,
      });
    } else {
      insights.add({
        'title': 'Balanced Dinners',
        'desc': 'You are doing great at keeping your evening meals balanced! This is great for your sleep.',
        'icon': Icons.nightlight_round,
        'color': GelatoTheme.purple,
        'iconColor': GelatoTheme.purple,
      });
    }

    // 2. Protein Consistency
    int proteinHitCount = 0;
    double targetProtein = (notifier.calorieGoal * 0.3) / 4.0;
    for (var log in logs) {
      if (log.totalProtein >= targetProtein * 0.8) proteinHitCount++;
    }
    
    int daysLogged = logs.length;
    if (proteinHitCount < 4 && daysLogged > 0) {
      insights.add({
        'title': 'Protein is Inconsistent',
        'desc': 'You hit your protein goal $proteinHitCount out of ${daysLogged > 7 ? 7 : daysLogged} days recently. Try adding more lean meats.',
        'icon': Icons.fitness_center_rounded,
        'color': GelatoTheme.blue,
        'iconColor': GelatoTheme.blue,
      });
    } else {
       insights.add({
        'title': 'Protein Powerhouse',
        'desc': 'Great job! You consistently hit your protein goals. Keep feeding those muscles!',
        'icon': Icons.fitness_center_rounded,
        'color': GelatoTheme.blue,
        'iconColor': GelatoTheme.blue,
      });
    }

    // 3. Fiber Analysis
    int fiberHitCount = 0;
    for (var log in logs) {
       if (log.totalFiber >= 20.0) fiberHitCount++;
    }
    if (fiberHitCount < (daysLogged / 2) && daysLogged > 0) {
       insights.add({
        'title': 'More Fiber Needed',
        'desc': 'Fiber helps with digestion and keeping you full. Try adding more leafy greens and whole grains!',
        'icon': Icons.eco_rounded,
        'color': GelatoTheme.green,
        'iconColor': GelatoTheme.green,
      });
    } else {
      insights.add({
        'title': 'Fantastic Fiber!',
        'desc': 'You are getting plenty of fiber in your diet, which is amazing for your gut health!',
        'icon': Icons.eco_rounded,
        'color': GelatoTheme.green,
        'iconColor': GelatoTheme.green,
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
