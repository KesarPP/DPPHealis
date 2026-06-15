import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/gelato_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7), // very light green
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
            _buildWeeklyTrendChart(),
            const SizedBox(height: 24),
            _buildSectionTitle('Macros Breakdown'),
            _buildMacrosBreakdown(),
            const SizedBox(height: 24),
            _buildSectionTitle('Nutrition Score'),
            _buildNutritionScoreCard(),
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

  Widget _buildWeeklyTrendChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: GelatoTheme.orange.withValues(alpha: 0.5),
            blurRadius: 0,
            offset: const Offset(4, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avg: 2,150 kcal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: GelatoTheme.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withValues(alpha: 0.15),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 1000,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(1)}k',
                          style: const TextStyle(
                            color: GelatoTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                color: GelatoTheme.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 3000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1800),
                      FlSpot(1, 2100),
                      FlSpot(2, 1950),
                      FlSpot(3, 2000),
                      FlSpot(4, 2500), 
                      FlSpot(5, 2800), 
                      FlSpot(6, 1900),
                    ],
                    isCurved: true,
                    color: GelatoTheme.orangeBright,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: GelatoTheme.orangeBright.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 2000, 
                      color: GelatoTheme.greenBright.withValues(alpha: 0.8),
                      strokeWidth: 2,
                      dashArray: [4, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 5, bottom: 5),
                        style: const TextStyle(
                          color: GelatoTheme.greenBright,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        labelResolver: (line) => 'GOAL',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosBreakdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: GelatoTheme.green.withValues(alpha: 0.5),
            blurRadius: 0,
            offset: const Offset(4, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildMacroBar('Protein', 110, 150, GelatoTheme.blueBright, '30%'),
          const SizedBox(height: 16),
          _buildMacroBar('Carbs', 220, 250, GelatoTheme.yellowBright, '45%'),
          const SizedBox(height: 16),
          _buildMacroBar('Fats', 65, 70, GelatoTheme.pinkBright, '25%'),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String name, int current, int target, Color color, String percentage) {
    double progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: GelatoTheme.textDark,
              ),
            ),
            Text(
              '${current}g / ${target}g  ($percentage)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: GelatoTheme.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: GelatoTheme.bg,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutritionScoreCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: GelatoTheme.blue.withValues(alpha: 0.5),
            blurRadius: 0,
            offset: const Offset(4, 4),
          )
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 0.85, 
                  strokeWidth: 10,
                  backgroundColor: GelatoTheme.bg,
                  color: GelatoTheme.greenBright,
                  strokeCap: StrokeCap.round,
                ),
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '85',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        '/100',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: GelatoTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Great Balance!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                _buildScoreFactor('Consistency', true),
                const SizedBox(height: 6),
                _buildScoreFactor('Macro Balance', true),
                const SizedBox(height: 6),
                _buildScoreFactor('Goal Adherence', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreFactor(String factor, bool isGood) {
    return Row(
      children: [
        Icon(
          isGood ? Icons.check_circle_rounded : Icons.info_rounded,
          size: 16,
          color: isGood ? GelatoTheme.greenBright : GelatoTheme.yellowBright,
        ),
        const SizedBox(width: 8),
        Text(
          factor,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: GelatoTheme.textLight,
          ),
        ),
      ],
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
      'iconColor': GelatoTheme.purpleBright,
    },
    {
      'title': 'Protein is Inconsistent',
      'desc': 'You hit your protein goal 4 out of 7 days this week. Try adding a shake on weekends.',
      'icon': Icons.fitness_center_rounded,
      'color': GelatoTheme.blue,
      'iconColor': GelatoTheme.blueBright,
    },
    {
      'title': 'Great Hydration!',
      'desc': 'You\'ve consistently hit your water goal all week. Keep up the excellent work!',
      'icon': Icons.water_drop_rounded,
      'color': GelatoTheme.green,
      'iconColor': GelatoTheme.greenBright,
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
                  ..translate(0.0, translateY, 0.0) // Gentle arc drop
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black87, width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color.lerp(Colors.white, color, 0.15)!, // Fully opaque blend
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.6),
            blurRadius: 0,
            offset: const Offset(4, 6),
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
                  color: color.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
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
