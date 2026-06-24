import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/gelato_theme.dart';

class WeeklyProgress extends StatefulWidget {
  const WeeklyProgress({super.key});

  @override
  State<WeeklyProgress> createState() => _WeeklyProgressState();
}

class _WeeklyProgressState extends State<WeeklyProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnim;
  int _selectedTab = 0;
  int? _selectedBarIndex = 3; // Thursday (Today) highlighted by default
  int _lastActiveIndex = 3; // For tracking smooth tooltip transitions

  final List<String> _tabs = ['Steps', 'Calories', 'Distance'];

  // Exact values to display in the tooltips
  final List<List<String>> _tooltipValues = [
    ['62K', '78K', '89K', '102K', '91K', '67K', '75K'], // Steps
    ['1.8K', '2.2K', '2.5K', '2.4K', '2.8K', '2.0K', '2.3K'], // Calories
    ['5.2 km', '6.8 km', '7.2 km', '8.5 km', '7.9 km', '4.8 km', '6.1 km'], // Distance
  ];

  // Normalized data [0..1] per tab for bar heights
  final List<List<double>> _data = [
    [0.55, 0.70, 0.80, 0.95, 0.85, 0.60, 0.68], // Steps
    [0.60, 0.73, 0.83, 0.80, 0.93, 0.66, 0.76], // Calories
    [0.58, 0.75, 0.80, 0.95, 0.88, 0.53, 0.68], // Distance
  ];

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  Color _getBarColor(int i) {
    final colors = [
      const Color(0xFFFFE082), // Mon: Bright Yellow/Amber
      const Color(0xFFE1BEE7), // Tue: Bright Lavender
      const Color(0xFF80DEEA), // Wed: Bright Cyan
      const Color(0xFF90CAF9), // Thu: Bright Sky Blue
      const Color(0xFFF48FB1), // Fri: Bright Soft Pink
      const Color(0xFFFFCC80), // Sat: Bright Peach/Orange
      const Color(0xFFC5E1A5), // Sun: Bright Lime/Green
    ];
    return colors[i % colors.length];
  }

  Color _getBarDarkColor(int i) {
    final darkColors = [
      const Color(0xFFFF8F00), // Amber Dark
      const Color(0xFF8E24AA), // Purple Dark
      const Color(0xFF00ACC1), // Cyan Dark
      const Color(0xFF1565C0), // Blue Dark
      const Color(0xFFD81B60), // Pink Dark
      const Color(0xFFEF6C00), // Orange Dark
      const Color(0xFF558B2F), // Green Dark
    ];
    return darkColors[i % darkColors.length];
  }

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _barAnim =
        CurvedAnimation(parent: _barController, curve: Curves.easeOutQuart);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _barController.forward();
    });
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (index == _selectedTab) return;
    setState(() {
      _selectedTab = index;
      _selectedBarIndex = null; // reset selected bar
    });
    _barController.reset();
    _barController.forward();
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
          colors: [
            Colors.white,
            Color(0xFFF2F7EC), // Light green tint
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                color: GelatoTheme.purpleDark,
                size: 20,
              ),
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
          Row(
            children: _tabs.asMap().entries.map((e) {
              final selected = e.key == _selectedTab;
              Color activeBg;
              Color activeText;
              
              switch (e.key) {
                case 0: // Steps
                  activeBg = GelatoTheme.green;
                  activeText = GelatoTheme.greenDark;
                  break;
                case 1: // Calories
                  activeBg = GelatoTheme.orange;
                  activeText = GelatoTheme.orangeDark;
                  break;
                case 2: // Distance
                  activeBg = GelatoTheme.blue;
                  activeText = GelatoTheme.blueDark;
                  break;
                default:
                  activeBg = GelatoTheme.purple;
                  activeText = GelatoTheme.purpleDark;
              }

              return GestureDetector(
                onTap: () => _switchTab(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          const SizedBox(height: 16),
          // Context Section matching the attached image
          Container(
            height: 70,
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
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: const Color(0xFFFDE4A1), // Yellowish
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Average', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF8B4513))),
                          Text('7,800', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2C5282))),
                          Text('steps/day', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B4513))),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1.5, color: Colors.black.withValues(alpha: 0.8)),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFCDE3BB), // Greenish
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Best Day', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF8B4513))),
                          Text('Thursday', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF388E3C))),
                          Text('102K steps', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B4513))),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1.5, color: Colors.black.withValues(alpha: 0.8)),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFFFD4AA), // Orangish
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Goal achieved', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF8B4513))),
                          Text('5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF8B4513))),
                          Text('of 7 days', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B4513))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Chart Area with Tooltips and Gridlines
          AnimatedBuilder(
            animation: _barAnim,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final double chartWidth = constraints.maxWidth;
                  final double availableWidth = chartWidth - 28; // Space after Y-axis
                  final double spacing = (availableWidth - 210) / 8; // 7 bars = 210px, 8 spaces
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
                        height: 160,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Y-axis labels dynamically based on tab
                            Builder(
                              builder: (context) {
                                List<String> yLabels;
                                if (_selectedTab == 0) yLabels = ['15k', '10k', '5k', '0'];
                                else if (_selectedTab == 1) yLabels = ['3k', '2k', '1k', '0'];
                                else yLabels = ['15km', '10km', '5km', '0'];

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
                                  // Gridlines
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(4, (index) => Container(
                                      height: 1,
                                      color: const Color(0xFFF1F5F9),
                                    )),
                                  ),
                                  // Y-axis Line
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(width: 1.5, color: Colors.black.withValues(alpha: 0.1)),
                                  ),
                                  // X-axis Line
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(height: 1.5, color: Colors.black.withValues(alpha: 0.1)),
                                  ),
                                ],
                              ),
                            ),

                            // Goal Line (drawn at 75% height of the 120px chart area)
                            Positioned(
                              left: 28,
                              right: 0,
                              bottom: 40 + (120 * 0.75),
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
                            // Daily Goal Line Text
                            Positioned(
                              left: 34,
                              bottom: 40 + (120 * 0.75) + 4,
                              child: const Text(
                                'Daily goal line',
                                style: TextStyle(
                                  color: GelatoTheme.purpleDark,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: currentData.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final val = entry.value;
                                  final isToday = i == 3;
                                  final bool isSelected = _selectedBarIndex == i;
                                  final barColor = _getBarColor(i);
                                  final barColorDark = _getBarDarkColor(i);
                                  final double baseBarHeight = 120.0 * val;
                                  final double barHeight = isSelected
                                      ? (baseBarHeight * 1.08).clamp(10.0, 120.0)
                                      : baseBarHeight;

                                  return SizedBox(
                                    width: 30,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        AnimatedContainer(
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
                                                // 1. Base Gradient (Bright & Popping)
                                                Positioned.fill(
                                                  child: Opacity(
                                                    opacity: (isSelected || _selectedBarIndex == null) ? 1.0 : 0.6,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          begin: Alignment.bottomCenter,
                                                          end: Alignment.topCenter,
                                                          colors: [
                                                            barColorDark,
                                                            barColor,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // 2. Glossy Highlight - Left Sheen (vertical white highlight)
                                                Positioned(
                                                  left: 0,
                                                  top: 0,
                                                  bottom: 0,
                                                  width: 6,
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
                                                // 3. Glossy Highlight - Right edge reflection (subtle dark border inside)
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  bottom: 0,
                                                  width: 3,
                                                  child: Container(
                                                    color: Colors.black.withValues(alpha: 0.05),
                                                  ),
                                                ),
                                                // 4. Glossy Highlight - Top Cap Reflection (3D rounded cylinder shine)
                                                Positioned(
                                                  left: 1,
                                                  top: 1,
                                                  right: 1,
                                                  height: 10,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(5),
                                                        topRight: Radius.circular(5),
                                                      ),
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topCenter,
                                                        end: Alignment.bottomCenter,
                                                        colors: [
                                                          Colors.white.withValues(alpha: isSelected ? 0.8 : 0.5),
                                                          Colors.white.withValues(alpha: 0.0),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // 5. Glossy Highlight - Center-left soft glare
                                                Positioned(
                                                  left: 4,
                                                  top: 4,
                                                  bottom: 4,
                                                  width: 3,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withValues(alpha: isSelected ? 0.25 : 0.15),
                                                      borderRadius: BorderRadius.circular(1),
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
