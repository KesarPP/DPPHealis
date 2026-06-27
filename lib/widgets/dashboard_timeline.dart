import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

import '../models/ndpp_constants.dart';

class DashboardTimeline extends StatefulWidget {
  final DailyAggregate? todayAgg;
  final int mealLogCount;
  final bool waterLogged;
  final bool weightLogged;
  final bool lessonCompleted;
  final bool journalLogged;
  final Function(int)? onToggleItem;

  const DashboardTimeline({
    super.key,
    this.todayAgg,
    this.mealLogCount = 2,
    this.waterLogged = true,
    this.weightLogged = true,
    this.lessonCompleted = true,
    this.journalLogged = false,
    this.onToggleItem,
  });

  @override
  State<DashboardTimeline> createState() => _DashboardTimelineState();
}

class _DashboardTimelineState extends State<DashboardTimeline> with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnim;

  late List<_TimelineItem> items;
  late int doneCount;

  void _buildItems() {
    final int qualifyingMins = widget.todayAgg?.qualifyingActiveMinutes ?? 0;
    final bool activityDone = qualifyingMins >= 10;

    items = [
      _TimelineItem(
        text: "Log a\nmeal",
        done: widget.mealLogCount >= 1,
        mainIcon: Icons.restaurant_rounded,
        timeText: widget.mealLogCount >= 1 ? "Logged" : "Pending",
        statusText: widget.mealLogCount >= 1 ? "${widget.mealLogCount} logged" : "Log breakfast",
      ),
      _TimelineItem(
        text: "Qualifying\nactivity",
        done: activityDone,
        mainIcon: Icons.directions_run_rounded,
        timeText: activityDone ? "Done" : "Pending",
        statusText: activityDone ? "$qualifyingMins mins logged" : "≥10m session",
      ),
      _TimelineItem(
        text: "Hydration\ncheck-in",
        done: widget.waterLogged,
        mainIcon: Icons.water_drop_rounded,
        timeText: widget.waterLogged ? "Done" : "Pending",
        statusText: widget.waterLogged ? "Great!" : "Log water",
      ),
      _TimelineItem(
        text: "Weight\ncheck-in",
        done: widget.weightLogged,
        mainIcon: Icons.monitor_weight_rounded,
        timeText: widget.weightLogged ? "Done" : "Pending",
        statusText: widget.weightLogged ? "Logged" : "Check-in",
      ),
      _TimelineItem(
        text: "Today's\nlesson",
        done: widget.lessonCompleted,
        mainIcon: Icons.menu_book_rounded,
        timeText: widget.lessonCompleted ? "Done" : "Pending",
        statusText: widget.lessonCompleted ? "Completed" : "Read lesson",
      ),
      _TimelineItem(
        text: "Reflection\nnote",
        done: widget.journalLogged,
        mainIcon: Icons.edit_note_rounded,
        timeText: widget.journalLogged ? "Done" : "Pending",
        statusText: widget.journalLogged ? "Saved" : "Add note",
      ),
    ];

    doneCount = items.where((element) => element.done).length;
  }

  @override
  void initState() {
    super.initState();
    _buildItems();
    
    // Intro animation (line filling, checks popping)
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _progressAnim = Tween<double>(begin: 0.0, end: doneCount.toDouble()).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeInOut),
    );

    // Infinite pulse for pending items
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Start intro after short delay, and repeat it periodically so it's always visible
    _introController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            _introController.forward(from: 0.0);
          }
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _introController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(DashboardTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    _buildItems();
    _progressAnim = Tween<double>(begin: 0.0, end: doneCount.toDouble()).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

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
      child: AnimatedBuilder(
        animation: Listenable.merge([_introController, _pulseController]),
        builder: (context, child) {
          final currentProgress = _progressAnim.value;
          final currentRatio = items.isEmpty ? 0.0 : currentProgress / items.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: GelatoTheme.pink,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.track_changes_rounded, color: GelatoTheme.pinkDark, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Today's Mission",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Small steps, big transformation",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: GelatoTheme.textLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${currentProgress.toInt()} ",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: GelatoTheme.textDark),
                            ),
                            const TextSpan(
                              text: "of 6 completed",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GelatoTheme.textDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value: currentRatio,
                          strokeWidth: 4,
                          backgroundColor: GelatoTheme.green.withValues(alpha: 0.3),
                          color: GelatoTheme.greenBright,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Horizontal Timeline
              SizedBox(
                height: 215, // Increased height for new layout
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    // Ensure each item has at least 75 pixels of width so it doesn't overflow
                    final itemWidth = math.max(screenWidth / items.length, 75.0);
                    final totalWidth = itemWidth * items.length;
                    
                    // Golden line progress
                    double lineProgressWidth = 0.0;
                    if (currentProgress > 1.0) {
                      lineProgressWidth = itemWidth * (currentProgress - 1.0);
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: totalWidth,
                        child: Stack(
                          children: [
                            // Dashed line background
                            Positioned(
                              top: 28, // Centered on the 56x56 circles
                              left: itemWidth / 2,
                              right: itemWidth / 2,
                              child: CustomPaint(
                                painter: _HorizontalDashedLinePainter(
                                  progressWidth: lineProgressWidth,
                                ),
                                size: Size(totalWidth - itemWidth, 2),
                              ),
                            ),
                            // Items
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(items.length, (index) {
                                final it = items[index];
                                final isItemDone = currentProgress >= (index + 0.8);
                                
                                // Intro scale for popping checkmarks
                                double introScale = 1.0;
                                if (currentProgress >= index && currentProgress < index + 1.0) {
                                  introScale = 1.0 + 0.2 * math.sin((currentProgress - index) * math.pi);
                                }

                                // Pulse glow for pending
                                final pulseValue = (!it.done) ? _pulseController.value : 0.0;
                                
                                // Colors based on status
                                final Color mainColor = it.done ? GelatoTheme.greenBright : const Color(0xFFFB923C); // Yellowish Orange
                                final Color lightBg = it.done ? const Color(0xFFE8F5E9) : const Color(0xFFFFF7ED); // Light orange bg
                                final Color darkText = it.done ? GelatoTheme.greenDark : const Color(0xFFC2410C); // Dark orange text

                                return GestureDetector(
                                  onTap: () => widget.onToggleItem?.call(index),
                                  behavior: HitTestBehavior.opaque,
                                  child: SizedBox(
                                    width: itemWidth,
                                    child: Column(
                                      children: [
                                        // Node Stack
                                        SizedBox(
                                          width: 80, // Increased size to allow glow
                                          height: 80,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Smooth circular glow background
                                              if (isItemDone)
                                                Container(
                                                  width: 80,
                                                  height: 80,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: RadialGradient(
                                                      colors: [
                                                        GelatoTheme.greenBright.withValues(alpha: 0.6),
                                                        GelatoTheme.greenBright.withValues(alpha: 0.0),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              if (!it.done)
                                                Container(
                                                  width: 64 + (16 * pulseValue),
                                                  height: 64 + (16 * pulseValue),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: RadialGradient(
                                                      colors: [
                                                        const Color(0xFFFB923C).withValues(alpha: 0.4 * pulseValue),
                                                        const Color(0xFFFB923C).withValues(alpha: 0.0),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              // Main Circle
                                              Transform.scale(
                                                scale: isItemDone ? introScale : 1.0,
                                                child: Container(
                                                  width: 56,
                                                  height: 56,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: mainColor,
                                                      width: 2.5,
                                                    ),
                                                  ),
                                                  child: Icon(it.mainIcon, color: mainColor, size: 28),
                                                ),
                                              ),
                                              // Top right checkmark badge
                                              if (isItemDone)
                                                Positioned(
                                                  top: 0,
                                                  right: 0,
                                                  child: Transform.scale(
                                                    scale: introScale,
                                                    child: Container(
                                                      width: 20,
                                                      height: 20,
                                                      decoration: const BoxDecoration(
                                                        color: GelatoTheme.greenBright,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        // Text
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            it.text,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              height: 1.2,
                                              fontWeight: FontWeight.w800,
                                              color: GelatoTheme.textDark,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Time Pill
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: lightBg,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              it.timeText,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w700,
                                                color: darkText,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Status Pill
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: lightBg,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (it.statusEmoji != null) ...[
                                                  Text(it.statusEmoji!, style: const TextStyle(fontSize: 10)),
                                                  const SizedBox(width: 4),
                                                ] else if (it.statusIcon != null) ...[
                                                  Icon(it.statusIcon, size: 10, color: darkText),
                                                  const SizedBox(width: 4),
                                                ],
                                                Text(
                                                  it.statusText,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w800,
                                                    color: darkText,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Banner
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: GelatoTheme.pink,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.auto_awesome, color: GelatoTheme.pinkDark, size: 16),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "You're on fire! Keep going!",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: GelatoTheme.pinkDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}

class _HorizontalDashedLinePainter extends CustomPainter {
  final double progressWidth;

  _HorizontalDashedLinePainter({required this.progressWidth});

  @override
  void paint(Canvas canvas, Size size) {
    // Orange dashed line for pending
    final paintMuted = Paint()
      ..color = const Color(0xFFFB923C).withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Green solid line for completed
    final paintGreen = Paint()
      ..color = GelatoTheme.greenBright
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
      
    // Green glow
    final paintGlow = Paint()
      ..color = GelatoTheme.greenBright.withValues(alpha: 0.4)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const double dashWidth = 6;
    const double dashSpace = 4;
    double startX = 0;

    // Draw full purple dashed line first
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paintMuted);
      startX += dashWidth + dashSpace;
    }

    // Overlay green solid line for completed portions
    if (progressWidth > 0) {
      double endLine = progressWidth.clamp(0.0, size.width);
      
      // Draw solid glowing line from 0 to endLine
      canvas.drawLine(Offset(0, 0), Offset(endLine, 0), paintGlow);
      canvas.drawLine(Offset(0, 0), Offset(endLine, 0), paintGreen);
    }
  }

  @override
  bool shouldRepaint(covariant _HorizontalDashedLinePainter oldDelegate) {
    return oldDelegate.progressWidth != progressWidth;
  }
}

class _TimelineItem {
  final String text;
  final bool done;
  final IconData mainIcon;
  final String timeText;
  final String statusText;
  final String? statusEmoji;
  final IconData? statusIcon;

  _TimelineItem({
    required this.text,
    required this.done,
    required this.mainIcon,
    required this.timeText,
    required this.statusText,
    this.statusEmoji,
    this.statusIcon,
  });
}
