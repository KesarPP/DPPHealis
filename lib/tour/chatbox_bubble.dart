import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import 'app_tour_models.dart';

class ChatboxBubble extends StatelessWidget {
  final TourStep step;
  final int currentIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final bool isLastStep;
  final double arrowAlignmentX;

  const ChatboxBubble({
    super.key,
    required this.step,
    required this.currentIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    this.isLastStep = false,
    this.arrowAlignmentX = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (step.arrowDirection == ArrowDirection.top)
          Align(
            alignment: Alignment(arrowAlignmentX, 0.0),
            child: _buildArrow(pointingUp: true),
          ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: step.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black, width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(3.0, 3.0),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row: Section pill + Close button (NO SLIDE COUNTER)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.4),
                    ),
                    child: Text(
                      step.sectionLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onSkip,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.4),
                      ),
                      child: const Icon(Icons.close, size: 12, color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Title
              Text(
                step.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: GelatoTheme.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              // Body
              Text(
                step.body,
                style: const TextStyle(
                  fontSize: 12.8,
                  fontWeight: FontWeight.w500,
                  color: GelatoTheme.textDark,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              // Bottom Action Bar: Skip on left, Back & Next on right
              Row(
                children: [
                  GestureDetector(
                    onTap: onSkip,
                    child: const Text(
                      'Skip Tour',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (currentIndex > 0) ...[
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 1.6),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(1.8, 1.8),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: GelatoTheme.textDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  GestureDetector(
                    onTap: onNext,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 1.8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLastStep ? 'Finish 🎉' : 'Next',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                          if (!isLastStep) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward, size: 13, color: Colors.black),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (step.arrowDirection == ArrowDirection.bottom)
          Align(
            alignment: Alignment(arrowAlignmentX, 0.0),
            child: _buildArrow(pointingUp: false),
          ),
      ],
    );
  }

  Widget _buildArrow({required bool pointingUp}) {
    return CustomPaint(
      size: const Size(20, 10),
      painter: _TrianglePainter(
        color: step.cardColor,
        pointingUp: pointingUp,
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final bool pointingUp;

  _TrianglePainter({required this.color, required this.pointingUp});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (pointingUp) {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.close();
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
      path.close();
    }

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.pointingUp != pointingUp;
}
