import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../data/gelato_theme.dart';
import '../models/ndpp_constants.dart';
import '../services/activity_metrics_engine.dart';

class DashboardHeroCards extends StatefulWidget {
  final List<DailyAggregate> trailing30Days;
  final int programWeek;
  const DashboardHeroCards({
    super.key,
    required this.trailing30Days,
    required this.programWeek,
  });

  @override
  State<DashboardHeroCards> createState() => _DashboardHeroCardsState();
}

class _DashboardHeroCardsState extends State<DashboardHeroCards> {
  int _selectedSegment = 0; // 0 = Weekly, 1 = Monthly

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Swipable Journey Cards
        SizedBox(
          height: 480, // Reduced height
          child: PageView(
            controller: PageController(viewportFraction: 0.9),
            physics: const BouncingScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _WeightJourneyCard(
                  isWeekly: _selectedSegment == 0,
                  toggleWidget: _buildSegmentedToggle(const Color(0xFF1E3A8A),
                      const Color(0xFFBFDBFE), const Color(0xFF64748B)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _ActivityJourneyCard(
                  isWeekly: _selectedSegment == 0,
                  trailing30Days: widget.trailing30Days,
                  programWeek: widget.programWeek,
                  toggleWidget: _buildSegmentedToggle(const Color(0xFF064E3B),
                      const Color(0xFFA7F3D0), const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentedToggle(
      Color pillColor, Color selectedTextColor, Color unselectedTextColor) {
    return Container(
      width: 130, // Reduced from 240
      height: 32, // Reduced from 44
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            top: 2,
            bottom: 2,
            left: _selectedSegment == 0 ? 2 : 64, // 130 width -> ~62 width pill
            width: 62,
            child: Container(
              decoration: BoxDecoration(
                color: pillColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: _buildSegmentButton(
                      'Weekly', 0, selectedTextColor, unselectedTextColor)),
              Expanded(
                  child: _buildSegmentButton(
                      'Monthly', 1, selectedTextColor, unselectedTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String title, int index, Color selectedTextColor,
      Color unselectedTextColor) {
    final isSelected = _selectedSegment == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedSegment = index;
        });
      },
      child: Center(
        child: AnimatedScale(
          scale: isSelected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11, // Reduced font size
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? selectedTextColor : unselectedTextColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeightJourneyCard extends StatefulWidget {
  final bool isWeekly;
  final Widget toggleWidget;
  const _WeightJourneyCard(
      {required this.isWeekly, required this.toggleWidget});

  @override
  State<_WeightJourneyCard> createState() => _WeightJourneyCardState();
}

class _WeightJourneyCardState extends State<_WeightJourneyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isPressed = false;
  double _height = 1.77;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
    _loadHeight();
  }

  Future<void> _loadHeight() async {
    try {
      final authService = AuthService();
      if (authService.isFirebaseInitialized && authService.currentUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(authService.currentUser!.uid)
            .get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data.containsKey('height')) {
            if (mounted) {
              setState(() {
                _height = (data['height'] as num).toDouble() / 100.0; // cm to m
              });
            }
          }
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final uid = authService.isFirebaseInitialized ? authService.currentUser?.uid : null;

    if (uid == null) {
      return _buildCard(
        currentWeight: 78.4,
        goalWeight: 72.0,
        totalLost: 2.3,
        toGo: 6.4,
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('weight_history')
          .orderBy('date', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        double currentWeight = 78.4;
        double startingWeight = 82.5;
        double totalLost = 2.3;
        double goalWeight = 72.0;
        double toGo = 6.4;

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.docs.isNotEmpty) {
          final docs = snapshot.data!.docs;
          
          startingWeight = (docs.first.data() as Map<String, dynamic>)['weight']?.toDouble() ?? 82.5;
          currentWeight = (docs.last.data() as Map<String, dynamic>)['weight']?.toDouble() ?? 78.4;
          totalLost = startingWeight - currentWeight;

          // Calculate goal weight using same formula as WeighInScreen
          final baselineWeight = startingWeight;
          final baselineBMI = baselineWeight / (_height * _height);
          
          if (baselineBMI < 18.5) {
            goalWeight = 18.5 * (_height * _height);
          } else if (baselineBMI >= 18.5 && baselineBMI < 25.0) {
            goalWeight = baselineWeight;
          } else {
            goalWeight = baselineWeight * 0.95;
          }

          toGo = currentWeight > goalWeight ? currentWeight - goalWeight : 0.0;
        }

        return _buildCard(
          currentWeight: currentWeight,
          goalWeight: goalWeight,
          totalLost: totalLost,
          toGo: toGo,
        );
      },
    );
  }

  Widget _buildCard({
    required double currentWeight,
    required double goalWeight,
    required double totalLost,
    required double toGo,
  }) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: Colors.black, width: 2), // Added black border
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ]
                    : GelatoTheme.cardShadow,
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
                                  colors: [
                                    Color(0xFF60A5FA),
                                    Color(0xFF3B82F6)
                                  ], // Reverted to blue
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.monitor_weight_rounded,
                                    color: Colors.white, size: 24),
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
                            widget.toggleWidget,
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats Row with Pastel Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Current',
                                currentWeight,
                                'kg',
                                GelatoTheme.pink
                                    .withValues(alpha: 0.3), // Pastel pink
                                Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'GOAL',
                                goalWeight,
                                'kg',
                                GelatoTheme.green
                                    .withValues(alpha: 0.3), // Pastel green
                                const Color(0xFFDC2626), // Red highlight text
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Total Lost',
                                totalLost,
                                'kg',
                                GelatoTheme.yellow
                                    .withValues(alpha: 0.3), // Pastel yellow
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8), // Reduced size
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(
                              alpha: 0.8), // Transparent like the others
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white,
                              width: 2), // Keep border so it looks highlighted
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            )
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Text('${toGo.toStringAsFixed(1)} kg',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 3
                                        ..color = Colors.white)),
                              Text('${toGo.toStringAsFixed(1)} kg',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black)),
                            ],
                          ),
                          const Text('to go!',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF151414))),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFFDBEAFE), // Pastel blue for achievement rack and progress
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        border: Border(
                            top: BorderSide(
                                color: Colors.black.withValues(alpha: 0.05))),
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
                                  child: Text('Achievement Rack',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black87)),
                                ),
                                const SizedBox(height: 12),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildMedal(
                                          Icons.military_tech,
                                          const Color(0xFFEAB308),
                                          'First Month\nConsistent'),
                                      const SizedBox(width: 4),
                                      _buildMedal(
                                          Icons.military_tech,
                                          const Color(0xFFEAB308),
                                          '5kg\nMilestone'),
                                      const SizedBox(width: 4),
                                      _buildMedal(
                                          Icons.military_tech,
                                          const Color(0xFFEAB308),
                                          'Consistent\nTrack'),
                                      const SizedBox(width: 4),
                                      _buildMedal(
                                          Icons.military_tech,
                                          const Color(0xFFEAB308),
                                          'Workout\nof the Week'),
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
                                  widget.isWeekly
                                      ? 'Weekly Progress'
                                      : 'Monthly Progress',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black87),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('🏆', style: TextStyle(fontSize: 18)),
                                    Text('🏆', style: TextStyle(fontSize: 18)),
                                    Text('🏆', style: TextStyle(fontSize: 18)),
                                    Opacity(
                                        opacity: 0.3,
                                        child: Text('🏆',
                                            style: TextStyle(fontSize: 18))),
                                    Opacity(
                                        opacity: 0.3,
                                        child: Text('🏆',
                                            style: TextStyle(fontSize: 18))),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, double targetValue, String unit,
      Color bgColor, Color textColor,
      {String? subtitle}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: targetValue),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        String displayValue = (value % 1 == 0)
            ? value.toInt().toString()
            : value.toStringAsFixed(1);
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
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569))),
              const SizedBox(height: 4),
              _OutlinedRichText(
                  value: displayValue,
                  unit: unit,
                  textColor: textColor,
                  valueSize: 24,
                  unitSize: 12),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                ),
              ]
            ],
          ),
        );
      },
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
          style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569)),
        ),
      ],
    );
  }
}

class _ActivityJourneyCard extends StatefulWidget {
  final bool isWeekly;
  final Widget toggleWidget;
  final List<DailyAggregate> trailing30Days;
  final int programWeek;
  const _ActivityJourneyCard({
    required this.isWeekly,
    required this.toggleWidget,
    required this.trailing30Days,
    required this.programWeek,
  });

  @override
  State<_ActivityJourneyCard> createState() => _ActivityJourneyCardState();
}

class _ActivityJourneyCardState extends State<_ActivityJourneyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kcalRate = ActivityMissionEngine.getPersonalizedKcalRate(widget.trailing30Days);
    final summary = widget.isWeekly
        ? ActivityMissionEngine.getWeeklySummary(
            trailing30Days: widget.trailing30Days,
            programWeek: widget.programWeek,
            kcalRate: kcalRate,
          )
        : ActivityMissionEngine.getMonthlySummary(
            trailing30Days: widget.trailing30Days,
            programWeek: widget.programWeek,
            kcalRate: kcalRate,
          );

    final todayAgg = widget.trailing30Days.isNotEmpty
        ? widget.trailing30Days.last
        : DailyAggregate.empty(DateTime.now());
    final int todayScore = ActivityMetricsEngine.calculateActivityScore(todayAgg, widget.programWeek);
    final double todayRingValue = todayScore / 100.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ]
                    : GelatoTheme.cardShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/activity_park.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
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
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                child: Icon(Icons.directions_run_rounded,
                                    color: Colors.white, size: 24),
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
                            widget.toggleWidget,
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
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
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0.0, end: todayRingValue),
                                duration: const Duration(milliseconds: 1500),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  int percentage = (value * 100).toInt();
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CircularProgressIndicator(
                                        value: value,
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
                                              Text('$percentage%',
                                                  style: TextStyle(
                                                      fontSize: 42,
                                                      fontWeight: FontWeight.w900,
                                                      height: 1.0,
                                                      foreground: Paint()
                                                        ..style = PaintingStyle.stroke
                                                        ..strokeWidth = 4
                                                        ..color = Colors.white)),
                                              Text('$percentage%',
                                                  style: const TextStyle(
                                                      fontSize: 42,
                                                      fontWeight: FontWeight.w900,
                                                      color: Color(0xFF1E293B),
                                                      height: 1.0)),
                                            ],
                                          ),
                                          const Text(
                                            "of today's\nmission completed",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF475569)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7).withValues(alpha: 0.95),
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
                            widget.isWeekly ? 'Weekly Summary' : 'Monthly Summary',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          _buildDataRow('Mission Goal', summary.goalText),
                          _buildDivider(),
                          _buildDataRow('Completed', summary.completedText),
                          _buildDivider(),
                          _buildDataRow('Progress', '${summary.progressPercentage}%', isLast: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569))),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B))),
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

  const _OutlinedRichText(
      {required this.value,
      required this.unit,
      required this.textColor,
      required this.valueSize,
      required this.unitSize});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                  text: value,
                  style: TextStyle(
                      fontSize: valueSize,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 4
                        ..color = Colors.white)),
              TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                      fontSize: unitSize,
                      fontWeight: FontWeight.w800,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3
                        ..color = Colors.white)),
            ],
          ),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                  text: value,
                  style: TextStyle(
                      fontSize: valueSize,
                      fontWeight: FontWeight.w900,
                      color: textColor)),
              TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                      fontSize: unitSize,
                      fontWeight: FontWeight.w800,
                      color: textColor)),
            ],
          ),
        ),
      ],
    );
  }
}
