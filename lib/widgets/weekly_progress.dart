import 'package:flutter/material.dart';

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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Weekly Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              // Dropdown button style tab selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _tabs[_selectedTab],
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 12,
                      color: Color(0xFF475569),
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
              return GestureDetector(
                onTap: () => _switchTab(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : const Color(0xFF475569),
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
              return SizedBox(
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
                        height: 1.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF10B981),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tooltip display
                    if (_selectedBarIndex != null)
                      Positioned(
                        left: 10 + (_selectedBarIndex! * (MediaQuery.of(context).size.width - 64 - 20) / 7),
                        bottom: 42 + (100 * currentData[_selectedBarIndex!] * _barAnim.value) + 4,
                        child: FractionalTranslation(
                          translation: const Offset(-0.35, 0.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              currentTooltips[_selectedBarIndex!],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Bars
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: currentData.asMap().entries.map((entry) {
                          final i = entry.key;
                          final val = entry.value;
                          final isToday = i == 3; // Thursday is today
                          final double barHeight = 100.0 * val * _barAnim.value;
                          final bool isSelected = _selectedBarIndex == i;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedBarIndex = _selectedBarIndex == i ? null : i;
                                });
                              },
                              child: Container(
                                color: Colors.transparent, // expand tap area
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: barHeight,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF047857) // Deep emerald when selected
                                            : isToday
                                                ? const Color(0xFF10B981) // Bright green for today
                                                : const Color(0xFFA7F3D0), // Light green for normal
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF047857).withValues(alpha: 0.3),
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
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFF64748B),
                                        fontWeight: isToday
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
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
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 4),
              const Text(
                'Daily goal line',
                style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Best day',
                style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
