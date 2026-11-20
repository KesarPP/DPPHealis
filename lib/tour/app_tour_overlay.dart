import 'package:flutter/material.dart';
import 'app_tour_models.dart';
import 'chatbox_bubble.dart';

class AppTourOverlay extends StatefulWidget {
  final TourStep step;
  final int currentIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final bool isLastStep;

  const AppTourOverlay({
    super.key,
    required this.step,
    required this.currentIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    this.isLastStep = false,
  });

  @override
  State<AppTourOverlay> createState() => _AppTourOverlayState();
}

class _AppTourOverlayState extends State<AppTourOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final spotlightRect = widget.step.spotlightFraction != null
        ? Rect.fromLTWH(
            widget.step.spotlightFraction!.left * size.width,
            widget.step.spotlightFraction!.top * size.height,
            widget.step.spotlightFraction!.width * size.width,
            widget.step.spotlightFraction!.height * size.height,
          )
        : null;

    final bubbleTop = (widget.step.topFraction * size.height).clamp(
      topPadding + 20,
      size.height - 320,
    );

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent backdrop with cutout hole
          if (spotlightRect != null)
            ClipPath(
              clipper: _SpotlightClipper(spotlightRect),
              child: Container(
                width: size.width,
                height: size.height,
                color: Colors.black.withValues(alpha: 0.65),
              ),
            )
          else
            Container(
              width: size.width,
              height: size.height,
              color: Colors.black.withValues(alpha: 0.65),
            ),

          // Animated pulse border around the spotlight
          if (spotlightRect != null)
            Positioned(
              left: spotlightRect.left,
              top: spotlightRect.top,
              width: spotlightRect.width,
              height: spotlightRect.height,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.step.cardColor.withValues(alpha: 0.9),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.step.cardColor.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Positioned Chatbox Bubble
          Positioned(
            top: bubbleTop,
            left: 0,
            right: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: size.height - bubbleTop - 16,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ChatboxBubble(
                  step: widget.step,
                  currentIndex: widget.currentIndex,
                  totalSteps: widget.totalSteps,
                  onNext: widget.onNext,
                  onBack: widget.onBack,
                  onSkip: widget.onSkip,
                  isLastStep: widget.isLastStep,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightClipper extends CustomClipper<Path> {
  final Rect targetRect;

  _SpotlightClipper(this.targetRect);

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final rrect = RRect.fromRectAndRadius(targetRect, const Radius.circular(16));
    path.addRRect(rrect);
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant _SpotlightClipper oldClipper) =>
      oldClipper.targetRect != targetRect;
}
