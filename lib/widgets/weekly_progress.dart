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
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: GelatoTheme.purpleDark,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
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
              const SizedBox(width: 8),
              // Dropdown button style tab selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(1.5, 1.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _tabs[_selectedTab],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 12,
                      color: GelatoTheme.textDark,
                    ),
                  ],
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
                        color: Colors.black.withOpacity(0.15),
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
          const SizedBox(height: 24),

          // Chart Area with Tooltips and Gridlines
          AnimatedBuilder(
            animation: _barAnim,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final double chartWidth = constraints.maxWidth;
                  final double leftOffset = (chartWidth - 210) / 2;

                  return MouseRegion(
                    onHover: (details) {
                      final double relativeX = details.localPosition.dx.clamp(0.0, chartWidth);
                      final double adjustedX = relativeX - leftOffset;
                      final int index = (adjustedX / 30).floor().clamp(0, 6);
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
                        final double adjustedX = relativeX - leftOffset;
                        final int index = (adjustedX / 30).floor().clamp(0, 6);
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
                        final double adjustedX = relativeX - leftOffset;
                        final int index = (adjustedX / 30).floor().clamp(0, 6);
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
                            // Gridlines
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(4, (index) => Container(
                                height: 1,
                                color: const Color(0xFFF1F5F9),
                              )),
                            ),

                            // Goal Line (drawn at 75% height)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 40 + (100 * 0.75),
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

                            // Smooth Sliding Tooltip
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              left: leftOffset + _lastActiveIndex * 30 + (30 - 56) / 2,
                              bottom: _selectedBarIndex != null
                                  ? 40 + (100 * currentData[_lastActiveIndex] * _barAnim.value) + 8
                                  : 40 + (100 * currentData[_lastActiveIndex] * _barAnim.value) + 2,
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
                                        color: Colors.black.withOpacity(0.15),
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
                            Positioned.fill(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: currentData.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final val = entry.value;
                                  final isToday = i == 3;
                                  final bool isSelected = _selectedBarIndex == i;
                                  final barColor = _getBarColor(i);
                                  final barColorDark = _getBarDarkColor(i);
                                  final double baseBarHeight = 100.0 * val;
                                  final double barHeight = isSelected
                                      ? (baseBarHeight * 1.08).clamp(10.0, 110.0)
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
                                                      color: barColor.withOpacity(0.4),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                      offset: const Offset(0, 3),
                                                    )
                                                  ]
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
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
                                                          Colors.white.withOpacity(isSelected ? 0.7 : 0.5),
                                                          Colors.white.withOpacity(0.0),
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
                                                    color: Colors.black.withOpacity(0.05),
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
                                                          Colors.white.withOpacity(isSelected ? 0.8 : 0.5),
                                                          Colors.white.withOpacity(0.0),
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
                                                      color: Colors.white.withOpacity(isSelected ? 0.25 : 0.15),
                                                      borderRadius: BorderRadius.circular(1),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            children: [
              Container(
                width: 14,
                height: 2,
                color: GelatoTheme.purpleDark,
              ),
              const SizedBox(width: 4),
              const Text(
                'Daily goal line',
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
                'Best day',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: GelatoTheme.purpleDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
