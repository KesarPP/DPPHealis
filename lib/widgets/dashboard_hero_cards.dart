import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class DashboardHeroCards extends StatefulWidget {
  const DashboardHeroCards({super.key});

  @override
  State<DashboardHeroCards> createState() => _DashboardHeroCardsState();
}

class _DashboardHeroCardsState extends State<DashboardHeroCards> {
  int _selectedSegment = 0; // 0 = Weekly, 1 = Monthly

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Floating Toggle (Weekly | Monthly)
        _buildSegmentedToggle(),
        const SizedBox(height: 16),
        
        // 2. Swipable Journey Cards
        SizedBox(
          height: 520, // Tall enough to fit the new card structures
          child: PageView(
            controller: PageController(viewportFraction: 0.9),
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _WeightJourneyCard(isWeekly: _selectedSegment == 0),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _ActivityJourneyCard(isWeekly: _selectedSegment == 0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegmentButton('Weekly', 0),
          _buildSegmentButton('Monthly', 1),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String title, int index) {
    final isSelected = _selectedSegment == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSegment = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFCBE1) : Colors.transparent, // Pastel pink
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.black87 : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _WeightJourneyCard extends StatelessWidget {
  final bool isWeekly;
  const _WeightJourneyCard({required this.isWeekly});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        boxShadow: GelatoTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/weight_mountain.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // 2. White Fade Overlay (for text readability at top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 1.0),
                    Colors.white.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // 3. Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)], // Reverted to blue
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.monitor_weight_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Weight Journey',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'Climb towards your goal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.black87),
                  ],
                ),
                const SizedBox(height: 20),
                // Stats Row with Pastel Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Current',
                        '78.4',
                        'kg',
                        GelatoTheme.pink.withValues(alpha: 0.3), // Pastel pink
                        Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Goal',
                        '72',
                        'kg',
                        GelatoTheme.green.withValues(alpha: 0.3), // Pastel green
                        const Color(0xFFDC2626), // Red highlight text
                        subtitle: 'Target Date:\nDec 1, 2024',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatCard(
                        'Total Lost',
                        '2.3',
                        'kg',
                        GelatoTheme.yellow.withValues(alpha: 0.3), // Pastel yellow
                        Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 4. Custom overlaid badges (Simulating the mountain path markers)
          Positioned(
            left: 20,
            bottom: 140,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Reduced size
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8), // Transparent like the others
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2), // Keep border so it looks highlighted
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  )
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Text('6.4 kg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, foreground: Paint()..style=PaintingStyle.stroke..strokeWidth=3..color=Colors.white)),
                      const Text('6.4 kg', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
                    ],
                  ),
                  const Text('to go!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                ],
              ),
            ),
          ),

          // 5. Bottom Solid White Panel
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE), // Pastel blue for achievement rack and progress
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
              ),
              child: Row(
                children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Achievement Rack', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black87)),
                          ),
                          const SizedBox(height: 12),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildMedal(Icons.military_tech, const Color(0xFFEAB308), 'First Month\nConsistent'),
                                const SizedBox(width: 4),
                                _buildMedal(Icons.military_tech, const Color(0xFFEAB308), '5kg\nMilestone'),
                                const SizedBox(width: 4),
                                _buildMedal(Icons.military_tech, const Color(0xFFEAB308), 'Consistent\nTrack'),
                                const SizedBox(width: 4),
                                _buildMedal(Icons.military_tech, const Color(0xFFEAB308), 'Workout\nof the Week'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.black.withValues(alpha: 0.1),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  // Weekly/Monthly Progress
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWeekly ? 'Weekly Progress' : 'Monthly Progress',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('🏆', style: TextStyle(fontSize: 18)),
                            Text('🏆', style: TextStyle(fontSize: 18)),
                            Text('🏆', style: TextStyle(fontSize: 18)),
                            Opacity(opacity: 0.3, child: Text('🏆', style: TextStyle(fontSize: 18))),
                            Opacity(opacity: 0.3, child: Text('🏆', style: TextStyle(fontSize: 18))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Small progress bar
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: 0.6, // 60%
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit, Color bgColor, Color textColor, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
          const SizedBox(height: 4),
          _OutlinedRichText(value: value, unit: unit, textColor: textColor, valueSize: 24, unitSize: 12),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMedal(IconData icon, Color iconColor, String title) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
        ),
      ],
    );
  }
}

class _ActivityJourneyCard extends StatelessWidget {
  final bool isWeekly;
  const _ActivityJourneyCard({required this.isWeekly});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        boxShadow: GelatoTheme.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/activity_park.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // 2. Warm Fade Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFF7ED).withValues(alpha: 0.95),
                    const Color(0xFFFFF7ED).withValues(alpha: 0.8),
                    const Color(0xFFFFF7ED).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // 3. Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEA580C).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.directions_run_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Activity Journey',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'Stay active, stay strong',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.black87),
                  ],
                ),
                const SizedBox(height: 24),
                // Large Circular Progress with orange highlight
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Orange highlight glow behind the ring
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                              blurRadius: 24,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      CircularProgressIndicator(
                        value: 0.93,
                        strokeWidth: 14,
                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                        color: const Color(0xFFF59E0B),
                        strokeCap: StrokeCap.round,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Text('93%', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, height: 1.0, foreground: Paint()..style=PaintingStyle.stroke..strokeWidth=4..color=Colors.white)),
                              const Text('93%', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), height: 1.0)),
                            ],
                          ),
                          const Text(
                            "of today's\nmission completed",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Bottom Solid White Panel (Data Table)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7).withValues(alpha: 0.95), // Pastel green for summary tab
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    isWeekly ? 'Weekly Summary' : 'Monthly Summary',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  _buildDataRow('Mission Goal', isWeekly ? '500 Active Mins / 1,500 kcal' : '2,000 Active Mins / 6,000 kcal'),
                  _buildDivider(),
                  _buildDataRow('Completed', isWeekly ? '465 Active Mins / 1,395 kcal' : '1,800 Active Mins / 5,200 kcal'),
                  _buildDivider(),
                  _buildDataRow('Progress', isWeekly ? '93%' : '90%', isLast: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(height: 1, color: Colors.black.withValues(alpha: 0.05)),
    );
  }
}

class _OutlinedRichText extends StatelessWidget {
  final String value;
  final String unit;
  final Color textColor;
  final double valueSize;
  final double unitSize;

  const _OutlinedRichText({required this.value, required this.unit, required this.textColor, required this.valueSize, required this.unitSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(text: value, style: TextStyle(fontSize: valueSize, fontWeight: FontWeight.w900, foreground: Paint()..style=PaintingStyle.stroke..strokeWidth=4..color=Colors.white)),
              TextSpan(text: ' $unit', style: TextStyle(fontSize: unitSize, fontWeight: FontWeight.w800, foreground: Paint()..style=PaintingStyle.stroke..strokeWidth=3..color=Colors.white)),
            ],
          ),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(text: value, style: TextStyle(fontSize: valueSize, fontWeight: FontWeight.w900, color: textColor)),
              TextSpan(text: ' $unit', style: TextStyle(fontSize: unitSize, fontWeight: FontWeight.w800, color: textColor)),
            ],
          ),
        ),
      ],
    );
  }
}
