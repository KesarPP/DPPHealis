import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/gelato_theme.dart';
import '../models/ndpp_constants.dart';
import '../services/activity_metrics_engine.dart';

class WeeklyProgress extends StatefulWidget {
  final List<DailyAggregate> pastDays;
  final int programWeek;

  const WeeklyProgress({
    super.key,
    required this.pastDays,
    required this.programWeek,
  });

  @override
  State<WeeklyProgress> createState() => _WeeklyProgressState();
}

class _WeeklyProgressState extends State<WeeklyProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnim;
  int _selectedTab = 0;
  int? _selectedBarIndex = 6; // Default to last day (today)
  int _lastActiveIndex = 6;

  final List<String> _tabs = ['Steps', 'Calories', 'Distance', 'Active Min'];

  late List<List<String>> _tooltipValues;
  late List<List<double>> _data;
  late List<String> _days;

  // Context line values for each tab
  late List<String> _avgPerDay;
  late List<String> _bestDay;
  late List<String> _goalAchieved;

  // NDPP Goal block
  late int _weeklyTarget;
  late int _weeklyQualifyingMinutes;
  late int _activeDaysThisWeek;
  late int _remainingMinutes;

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _barAnim = CurvedAnimation(parent: _barController, curve: Curves.easeOutQuart);
    
    _computeData();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _barController.forward();
    });
  }

  @override
  void didUpdateWidget(WeeklyProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pastDays != widget.pastDays || oldWidget.programWeek != widget.programWeek) {
      _computeData();
    }
  }

  void _computeData() {
    _days = [];
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Ensure we have exactly 7 days, padded if necessary
    final last7 = widget.pastDays.length > 7 ? widget.pastDays.sublist(widget.pastDays.length - 7) : widget.pastDays;
    List<DailyAggregate> processingDays = List.from(last7);
    while (processingDays.length < 7) {
      processingDays.insert(0, DailyAggregate.empty(DateTime.now().subtract(Duration(days: 7 - processingDays.length))));
    }

    // Prepare arrays
    List<double> rawSteps = [];
    List<double> rawCals = [];
    List<double> rawDist = [];
    List<double> rawMins = [];
    
    _tooltipValues = [[], [], [], []];
    
    _weeklyQualifyingMinutes = 0;
    _activeDaysThisWeek = 0;

    for (var day in processingDays) {
      _days.add(daysOfWeek[day.date.weekday - 1]);
      
      final int effectiveMins = math.max(day.qualifyingActiveMinutes, day.totalActiveMinutes);
      rawSteps.add(day.totalSteps.toDouble());
      rawCals.add(day.totalCalories);
      rawDist.add(day.totalDistance);
      rawMins.add(effectiveMins.toDouble());

      _tooltipValues[0].add('${(day.totalSteps / 1000).toStringAsFixed(1)}K');
      _tooltipValues[1].add('${day.totalCalories.round()}');
      _tooltipValues[2].add('${day.totalDistance.toStringAsFixed(1)} km');
      _tooltipValues[3].add('$effectiveMins min');

      _weeklyQualifyingMinutes += effectiveMins;
      if (day.isActiveDay || effectiveMins >= 10 || day.totalSteps >= 3000) _activeDaysThisWeek++;
    }

    _weeklyTarget = NdppConstants.getWeeklyTargetForWeek(widget.programWeek);
    _remainingMinutes = math.max(0, _weeklyTarget - _weeklyQualifyingMinutes);

    // Normalize
    _data = [
      _normalize(rawSteps),
      _normalize(rawCals),
      _normalize(rawDist),
      _normalize(rawMins),
    ];

    // Compute Context Box Stats
    _avgPerDay = [];
    _bestDay = [];
    _goalAchieved = [];

    for (int t = 0; t < 4; t++) {
      double avg = ActivityMetricsEngine.getAverage(processingDays, t);
      DailyAggregate? best = ActivityMetricsEngine.getBestDay(processingDays, t);
      int achieved = ActivityMetricsEngine.getGoalAchievedCount(processingDays, t, stepGoal: 5000, calGoal: 200, distGoal: 3.0);

      _avgPerDay.add(_formatStat(avg, t));
      
      if (best != null && _getRaw(best, t) > 0) {
        _bestDay.add('${daysOfWeek[best.date.weekday - 1]}\n${_formatStat(_getRaw(best, t), t)}');
      } else {
        _bestDay.add('--\n0');
      }

      _goalAchieved.add(achieved.toString());
    }
  }

  double _getRaw(DailyAggregate day, int tabIndex) {
    if (tabIndex == 0) return day.totalSteps.toDouble();
    if (tabIndex == 1) return day.totalCalories;
    if (tabIndex == 2) return day.totalDistance;
    return day.qualifyingActiveMinutes.toDouble();
  }

  String _formatStat(double val, int tabIndex) {
    if (tabIndex == 0) return '${val.round()} steps';
    if (tabIndex == 1) return '${val.round()} cals';
    if (tabIndex == 2) return '${val.toStringAsFixed(1)} km';
    return '${val.round()} min';
  }

  List<double> _normalize(List<double> values) {
    if (values.isEmpty) return [];
    double maxVal = values.reduce(math.max);
    if (maxVal == 0) return List.filled(values.length, 0.0);
    // Add 10% headroom
    maxVal = maxVal * 1.1;
    return values.map((v) => (v / maxVal).clamp(0.0, 1.0)).toList();
  }

  Color _getBarColor(int i) {
    final colors = [
      const Color(0xFFFFE082), const Color(0xFFE1BEE7), const Color(0xFF80DEEA),
      const Color(0xFF90CAF9), const Color(0xFFF48FB1), const Color(0xFFFFCC80),
      const Color(0xFFC5E1A5),
    ];
    return colors[i % colors.length];
  }

  Color _getBarDarkColor(int i) {
    final darkColors = [
      const Color(0xFFFF8F00), const Color(0xFF8E24AA), const Color(0xFF00ACC1),
      const Color(0xFF1565C0), const Color(0xFFD81B60), const Color(0xFFEF6C00),
      const Color(0xFF558B2F),
    ];
    return darkColors[i % darkColors.length];
  }

  void _switchTab(int index) {
    if (index == _selectedTab) return;
    setState(() {
      _selectedTab = index;
      _selectedBarIndex = null;
    });
    _barController.reset();
    _barController.forward();
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _data[_selectedTab];
    final currentTooltips = _tooltipValues[_selectedTab];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF2F7EC)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: GelatoTheme.purpleDark, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Weekly Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: GelatoTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Tab bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _tabs.asMap().entries.map((e) {
                final selected = e.key == _selectedTab;
                Color activeBg = GelatoTheme.purple;
                Color activeText = GelatoTheme.purpleDark;
                
                switch (e.key) {
                  case 0: activeBg = GelatoTheme.green; activeText = GelatoTheme.greenDark; break;
                  case 1: activeBg = GelatoTheme.orange; activeText = GelatoTheme.orangeDark; break;
                  case 2: activeBg = GelatoTheme.blue; activeText = GelatoTheme.blueDark; break;
                  case 3: activeBg = const Color(0xFFEF9A9A); activeText = const Color(0xFFB71C1C); break;
                }

                return GestureDetector(
                  onTap: () => _switchTab(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? activeBg : const Color(0xFFFAF8FA),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? Colors.black : const Color(0xFFEFEAEA),
                        width: selected ? 2.0 : 1.2,
                      ),
                      boxShadow: selected ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          offset: const Offset(2.0, 2.0),
                          blurRadius: 0,
                        )
                      ] : null,
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: selected ? activeText : GelatoTheme.textLight,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // NDPP Weekly Goal Block
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: GelatoTheme.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GelatoTheme.purpleDark, width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week ${widget.programWeek} Goal: $_weeklyTarget min',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: GelatoTheme.purpleDark),
                      ),
                      Text(
                        '$_weeklyQualifyingMinutes min logged • $_activeDaysThisWeek active days',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: GelatoTheme.textDark),
                      ),
                    ],
                  ),
                ),
                if (_remainingMinutes > 0)
                  Text(
                    '$_remainingMinutes min left',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.deepOrange),
                  )
                else
                  const Icon(Icons.check_circle_rounded, color: Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Context Section matching the attached image
          Container(
            constraints: const BoxConstraints(minHeight: 75),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black.withValues(alpha: 0.8), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: const Offset(2, 3),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.5),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        color: const Color(0xFFFDE4A1),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Average', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF8B4513))),
                            const SizedBox(height: 2),
                            Text(_avgPerDay[_selectedTab], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF2C5282)), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1.5, color: Colors.black.withValues(alpha: 0.8)),
                    Expanded(
                      child: Container(
                        color: const Color(0xFFCDE3BB),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Best Day', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF8B4513))),
                            const SizedBox(height: 2),
                            Text(_bestDay[_selectedTab], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF388E3C)), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 1.5, color: Colors.black.withValues(alpha: 0.8)),
                    Expanded(
                      child: Container(
                        color: const Color(0xFFFFD4AA),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Goal achieved', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF8B4513)), textAlign: TextAlign.center),
                            Text(_goalAchieved[_selectedTab], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF8B4513))),
                            const Text('of 7 days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B4513))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Chart Area with Tooltips and Gridlines
          if (currentData.every((val) => val == 0))
            const SizedBox(
              height: 160,
              child: Center(
                child: Text(
                  "No activity logged yet this week",
                  style: TextStyle(color: GelatoTheme.textLight, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            )
          else
            AnimatedBuilder(
            animation: _barAnim,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final double chartWidth = constraints.maxWidth;
                  final double availableWidth = chartWidth - 28; 
                  final double spacing = (availableWidth - 210) / 8;
                  final double startX = 28 + spacing;

                  int _getIndexFromX(double dx) {
                    final double adjustedX = dx - startX + (spacing / 2);
                    return (adjustedX / (30 + spacing)).floor().clamp(0, 6);
                  }

                  return MouseRegion(
                    onHover: (details) {
                      final double relativeX = details.localPosition.dx.clamp(0.0, chartWidth);
                      final int index = _getIndexFromX(relativeX);
                      if (index != _selectedBarIndex) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedBarIndex = index;
                          _lastActiveIndex = index;
                        });
                      }
                    },
                    onExit: (event) {
                      setState(() {
                        _selectedBarIndex = null;
                      });
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragUpdate: (details) {
                        final double relativeX = details.localPosition.dx.clamp(0.0, chartWidth);
                        final int index = _getIndexFromX(relativeX);
                        if (index != _selectedBarIndex) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedBarIndex = index;
                            _lastActiveIndex = index;
                          });
                        }
                      },
                      onTapDown: (details) {
                        final double relativeX = details.localPosition.dx.clamp(0.0, chartWidth);
                        final int index = _getIndexFromX(relativeX);
                        setState(() {
                          _selectedBarIndex = _selectedBarIndex == index ? null : index;
                          if (_selectedBarIndex != null) {
                            _lastActiveIndex = index;
                          }
                        });
                      },
                      child: SizedBox(
                        height: 185,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Y-axis labels dynamically based on max value
                            Builder(
                              builder: (context) {
                                List<String> yLabels;
                                if (_selectedTab == 0) yLabels = ['Max', 'Med', 'Low', '0'];
                                else if (_selectedTab == 1) yLabels = ['Max', 'Med', 'Low', '0'];
                                else if (_selectedTab == 2) yLabels = ['Max', 'Med', 'Low', '0'];
                                else yLabels = ['Max', 'Med', 'Low', '0'];

                                return Positioned(
                                  left: 0,
                                  top: -4,
                                  bottom: 36,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: yLabels.map((lbl) => Text(
                                      lbl,
                                      style: const TextStyle(
                                        fontSize: 9,
                                        color: GelatoTheme.textLight,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )).toList(),
                                  ),
                                );
                              }
                            ),

                            // Gridlines and Axes
                            Positioned(
                              left: 28,
                              right: 0,
                              top: 0,
                              bottom: 40,
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(4, (index) => Container(
                                      height: 1,
                                      color: const Color(0xFFF1F5F9),
                                    )),
                                  ),
                                  Positioned(
                                    left: 0, top: 0, bottom: 0,
                                    child: Container(width: 1.5, color: Colors.black.withValues(alpha: 0.1)),
                                  ),
                                  Positioned(
                                    left: 0, right: 0, bottom: 0,
                                    child: Container(height: 1.5, color: Colors.black.withValues(alpha: 0.1)),
                                  ),
                                ],
                              ),
                            ),

                            // Smooth Sliding Tooltip
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              left: startX + _lastActiveIndex * (30 + spacing) + (30 - 56) / 2,
                              bottom: _selectedBarIndex != null
                                  ? 40 + (120 * currentData[_lastActiveIndex] * _barAnim.value) + 8
                                  : 40 + (120 * currentData[_lastActiveIndex] * _barAnim.value) + 2,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity: _selectedBarIndex != null ? 1.0 : 0.0,
                                child: Container(
                                  width: 56,
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: GelatoTheme.textDark,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.black, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        offset: const Offset(1.5, 1.5),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    currentTooltips[_lastActiveIndex],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),

                            // Bars
                            Positioned(
                              left: 28,
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _ChartLinePainter(
                                        data: currentData,
                                        animation: _barAnim,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: currentData.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final val = entry.value;
                                  final isToday = i == 6; // Last element is today
                                  final bool isSelected = _selectedBarIndex == i;
                                  final barColor = _getBarColor(i);
                                  final barColorDark = _getBarDarkColor(i);
                                  final double baseBarHeight = 120.0 * val;
                                  final double barHeight = isSelected
                                      ? (baseBarHeight * 1.08).clamp(0.0, 120.0)
                                      : baseBarHeight;

                                  return SizedBox(
                                    width: 30,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        val == 0
                                            ? const SizedBox(height: 0)
                                            : AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          curve: Curves.easeOutBack,
                                          width: isSelected ? 22 : 18,
                                          height: barHeight * _barAnim.value,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.black, width: 2.0),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: barColor.withValues(alpha: 0.4),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                      offset: const Offset(0, 3),
                                                    )
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.1),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    )
                                                  ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(6),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: Opacity(
                                                    opacity: (isSelected || _selectedBarIndex == null) ? 1.0 : 0.6,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin: Alignment.bottomCenter,
                                                          end: Alignment.topCenter,
                                                          colors: [barColorDark, barColor],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: 0, top: 0, bottom: 0, width: 6,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment.centerLeft,
                                                        end: Alignment.centerRight,
                                                        colors: [
                                                          Colors.white.withValues(alpha: isSelected ? 0.7 : 0.5),
                                                          Colors.white.withValues(alpha: 0.0),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 40,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 8),
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
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
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ChartLinePainter extends CustomPainter {
  final List<double> data;
  final Animation<double> animation;

  _ChartLinePainter({required this.data, required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = GelatoTheme.purpleDark.withValues(alpha: 0.3)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final int n = data.length;
    final double itemWidth = 30.0;
    final double space = (size.width - (n * itemWidth)) / (n + 1);

    for (int i = 0; i < n; i++) {
      final double x = (i + 1) * space + (i * itemWidth) + (itemWidth / 2);
      final double val = data[i] * animation.value;
      final double baseBarHeight = 120.0 * val;
      // top of bar: total height - 40 (text at bottom) - barHeight
      final double y = size.height - 40 - baseBarHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChartLinePainter oldDelegate) => true;
}
