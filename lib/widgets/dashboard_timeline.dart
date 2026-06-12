import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/gelato_theme.dart';

class DashboardTimeline extends StatelessWidget {
  const DashboardTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_TimelineItem> items = [
      _TimelineItem(text: "Breakfast logged", done: true, meta: "8:12 AM"),
      _TimelineItem(text: "Morning walk", done: true, meta: "8:45 AM"),
      _TimelineItem(text: "Water goal 75%", done: true, meta: "ongoing"),
      _TimelineItem(text: "Log lunch", done: false, meta: "Pending"),
      _TimelineItem(text: "Evening activity reminder", done: false, meta: "6:00 PM"),
      _TimelineItem(text: "Weekly weigh-in", done: false, meta: "Tomorrow"),
    ];

    final doneCount = items.where((element) => element.done).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDF5),
            Color(0xFFFEF9E6),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Journey",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textDark,
                ),
              ),
              Text(
                "$doneCount of ${items.length} done",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.greenDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Timeline List
          Stack(
            children: [
              // Vertical Dashed Line
              Positioned(
                left: 13,
                top: 15,
                bottom: 15,
                child: CustomPaint(
                  painter: _DashedLinePainter(),
                ),
              ),

              // Timeline items
              Column(
                children: List.generate(items.length, (index) {
                  final it = items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // Left Node
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Center(
                            child: it.done
                                ? Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: GelatoTheme.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black, width: 1.5),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: GelatoTheme.greenDark,
                                      size: 14,
                                    ),
                                  )
                                : Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: GelatoTheme.purple,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Middle Text
                        Expanded(
                          child: Text(
                            it.text,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: it.done ? FontWeight.bold : FontWeight.w500,
                              color: it.done
                                  ? GelatoTheme.textDark
                                  : GelatoTheme.textLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Right Meta Time
                        Text(
                          it.meta,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: it.done
                                ? GelatoTheme.greenDark
                                : GelatoTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom Button
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View full day log',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.purpleDark,
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: GelatoTheme.purpleDark,
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GelatoTheme.textMuted.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double dashHeight = 4;
    const double dashSpace = 4;
    double startY = 0;

    // Draw vertical dashed line
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _TimelineItem {
  final String text;
  final bool done;
  final String meta;

  _TimelineItem({
    required this.text,
    required this.done,
    required this.meta,
  });
}
