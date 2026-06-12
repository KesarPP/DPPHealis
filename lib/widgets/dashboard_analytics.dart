import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/gelato_theme.dart';

class DashboardAnalytics extends StatelessWidget {
  const DashboardAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: GelatoTheme.purpleDark,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Sessions & Meals Analytics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Two Rows of Analytics
          Row(
            children: [
              // Sessions Completed Block
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: GelatoTheme.blue,
                    borderRadius: BorderRadius.circular(20),
                    border: GelatoTheme.cardBorder,
                    boxShadow: GelatoTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.school_rounded,
                            color: GelatoTheme.blueDark,
                            size: 20,
                          ),
                          Text(
                            '31%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.blueDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Program Progress',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: GelatoTheme.blueDark.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Session 5 of 16',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.blueDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Mini Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 5 / 16,
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.45),
                          color: GelatoTheme.blueDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Meals Logged Block
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: GelatoTheme.green,
                    borderRadius: BorderRadius.circular(20),
                    border: GelatoTheme.cardBorder,
                    boxShadow: GelatoTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.restaurant_rounded,
                            color: GelatoTheme.greenDark,
                            size: 20,
                          ),
                          Text(
                            '75%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.greenDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Meals Logged Today',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: GelatoTheme.greenDark.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '3 of 4 Meals',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.greenDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Mini Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.75,
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.45),
                          color: GelatoTheme.greenDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekly Calorie Bar Chart Card (Fully Interactive)
          const _DashboardCalorieChart(),
        ],
      ),
    );
  }
}

class _DashboardCalorieChart extends StatefulWidget {
  const _DashboardCalorieChart();

  @override
  State<_DashboardCalorieChart> createState() => _DashboardCalorieChartState();
}

class _DashboardCalorieChartState extends State<_DashboardCalorieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnim;
  int? _selectedBarIndex = 3; // Thursday (Today) highlighted by default

  final List<double> _data = [0.60, 0.73, 0.83, 0.80, 0.93, 0.66, 0.76]; // Matches Calories tab in weekly_progress
  final List<String> _tooltips = ['1.8K', '2.2K', '2.5K', '2.4K', '2.8K', '2.0K', '2.3K'];
  final List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _barAnim = CurvedAnimation(parent: _barController, curve: Curves.easeOutQuart);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _barController.forward();
    });
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFFFF2E6), // Light orange/peach tint
          ],
        ),
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
                    Icons.bar_chart_rounded,
                    color: GelatoTheme.purpleDark,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Weekly Calorie Overview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: GelatoTheme.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                'Avg: 2,015 kcal',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart area supporting swipe gestures
          AnimatedBuilder(
            animation: _barAnim,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final double chartWidth = constraints.maxWidth;
                  final double segmentWidth = chartWidth / 7;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      final double relativeX = details.localPosition.dx.clamp(0.0, chartWidth);
                      final int index = ((relativeX / chartWidth) * 7).floor().clamp(0, 6);
                      if (index != _selectedBarIndex) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedBarIndex = index;
                        });
                      }
                    },
                    onTapDown: (details) {
                      final double relativeX = details.localPosition.dx.clamp(0.0, chartWidth);
                      final int index = ((relativeX / chartWidth) * 7).floor().clamp(0, 6);
                      setState(() {
                        _selectedBarIndex = _selectedBarIndex == index ? null : index;
                      });
                    },
                    child: SizedBox(
                      height: 160,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Gridlines
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(4, (index) => Container(
                              height: 1,
                              color: const Color(0xFFF1F5F9),
                            )),
                          ),

                          // Target Line (drawn at 67% height for 2,000 kcal targets)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 40 + (100 * 0.67),
                            child: Container(
                              height: 1.8,
                              decoration: const BoxDecoration(
                                color: GelatoTheme.purpleDark,
                                boxShadow: [
                                  BoxShadow(
                                    color: GelatoTheme.purple,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Tooltip display
                          if (_selectedBarIndex != null)
                            Positioned(
                              left: _selectedBarIndex! * segmentWidth + (segmentWidth - 56) / 2,
                              bottom: 40 + (100 * _data[_selectedBarIndex!] * _barAnim.value) + 6,
                              child: Container(
                                width: 56,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                decoration: BoxDecoration(
                                  color: GelatoTheme.textDark,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.black, width: 1.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(1.5, 1.5),
                                      blurRadius: 0,
                                    )
                                  ],
                                ),
                                child: Text(
                                  _tooltips[_selectedBarIndex!],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                          // Bars
                          Positioned.fill(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: _data.asMap().entries.map((entry) {
                                final i = entry.key;
                                final val = entry.value;
                                final isToday = i == 3;
                                final double barHeight = 100.0 * val * _barAnim.value;
                                final bool isSelected = _selectedBarIndex == i;
                                final barColor = isSelected
                                    ? GelatoTheme.orangeDark
                                    : isToday
                                        ? GelatoTheme.orangeBright
                                        : GelatoTheme.orangeBright.withOpacity(0.25);

                                return Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: barHeight,
                                        decoration: BoxDecoration(
                                          color: barColor,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: Colors.black, width: 1.5),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: barColor.withOpacity(0.35),
                                                    blurRadius: 6,
                                                    spreadRadius: 1,
                                                  )
                                                ]
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _days[i],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isToday
                                              ? GelatoTheme.purpleDark
                                              : GelatoTheme.textLight,
                                          fontWeight: isToday
                                              ? FontWeight.w900
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          // Legend (Matching WeeklyProgress style)
          Row(
            children: [
              Container(
                width: 14,
                height: 2,
                color: GelatoTheme.purpleDark,
              ),
              const SizedBox(width: 4),
              const Text(
                'Daily target line',
                style: TextStyle(fontSize: 10, color: GelatoTheme.textLight, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: GelatoTheme.orangeBright,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Today',
                style: TextStyle(fontSize: 10, color: GelatoTheme.textLight, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Text(
                '75% Met',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: GelatoTheme.greenDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
