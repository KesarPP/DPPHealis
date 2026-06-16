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
  final List<Map<String, dynamic>> _insights = [
    {
      'title': 'Evening Calorie Spikes',
      'desc': 'Your calorie intake tends to spike after 8 PM. Consider lighter dinners to improve your rest.',
      'icon': Icons.nightlight_round,
      'color': GelatoTheme.purple,
      'iconColor': GelatoTheme.purple,
    },
    {
      'title': 'Protein is Inconsistent',
      'desc': 'You hit your protein goal 4 out of 7 days this week. Try adding a shake on weekends.',
      'icon': Icons.fitness_center_rounded,
      'color': GelatoTheme.blue,
      'iconColor': GelatoTheme.blue,
    },
    {
      'title': 'Great Hydration!',
      'desc': 'You\'ve consistently hit your water goal all week. Keep up the excellent work!',
      'icon': Icons.water_drop_rounded,
      'color': GelatoTheme.green,
      'iconColor': GelatoTheme.green,
    },
  ];

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
    return SizedBox(
      height: 220, // Increased height so text doesn't cut off
      child: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disables drag, rely entirely on taps
        itemBuilder: (context, index) {
          int dataIndex = index % _insights.length;
          final insight = _insights[dataIndex];

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
