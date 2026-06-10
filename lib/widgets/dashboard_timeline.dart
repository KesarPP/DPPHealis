import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        color: const Color(0xFFFFFBEB), // Tint amber background
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
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
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                "$doneCount of ${items.length} done",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10B981), // Jade
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
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981), // Jade
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
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
                                        color: const Color(0xFFCBD5E1), // Slate 300
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE2E8F0), // Slate 200
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
                                  ? const Color(0xFF1E293B) // Dark
                                  : const Color(0xFF64748B), // Slate 500
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
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8),
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
                    color: Color(0xFFF59E0B), // Amber warn
                  ),
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFF59E0B),
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
      ..color = const Color(0x3D0F172A) // transparent slate
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
