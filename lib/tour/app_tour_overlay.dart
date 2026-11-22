import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
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

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.03).animate(
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final spotlightRect = widget.step.spotlightFraction != null
        ? Rect.fromLTWH(
            widget.step.spotlightFraction!.left * size.width,
            widget.step.spotlightFraction!.top * size.height,
            widget.step.spotlightFraction!.width * size.width,
            widget.step.spotlightFraction!.height * size.height,
          )
        : null;

    final isBottomAnchored = widget.step.topFraction >= 0.65;
    final bubbleTop = (widget.step.topFraction * size.height).clamp(
      topPadding + 10,
      size.height - 220,
    );

    double arrowAlignmentX = 0.0;
    if (spotlightRect != null) {
      final fractionX = spotlightRect.center.dx / size.width;
      arrowAlignmentX = ((fractionX * 2.0) - 1.0).clamp(-0.75, 0.75);
    }

    final isDrawerShowcase = widget.step.id == 'menu_drawer_showcase';

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Feather-light transparent barrier so the entire screen is 100% visible
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {}, // absorbs outside clicks without darkening screen
              child: Container(
                color: isDrawerShowcase
                    ? Colors.transparent
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Transparent highlight frame around spotlight target (if any, not a blackout cutout)
          if (spotlightRect != null && !isDrawerShowcase)
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
                        color: widget.step.cardColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.step.cardColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Render: Drawer Showcase minimal pill vs Floaty Chatbox Bubble
          if (isDrawerShowcase)
            Positioned(
              bottom: bottomPadding + 24,
              left: 20,
              right: 20,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: GelatoTheme.green,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 2.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(3.5, 3.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: widget.onSkip,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      GestureDetector(
                        onTap: widget.onNext,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Next: Leaderboard',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: GelatoTheme.textDark,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward, size: 15, color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (isBottomAnchored)
            Positioned(
              bottom: bottomPadding + 16,
              left: 0,
              right: 0,
              child: ChatboxBubble(
                step: widget.step,
                currentIndex: widget.currentIndex,
                totalSteps: widget.totalSteps,
                onNext: widget.onNext,
                onBack: widget.onBack,
                onSkip: widget.onSkip,
                isLastStep: widget.isLastStep,
                arrowAlignmentX: arrowAlignmentX,
              ),
            )
          else
            Positioned(
              top: bubbleTop,
              left: 0,
              right: 0,
              child: ChatboxBubble(
                step: widget.step,
                currentIndex: widget.currentIndex,
                totalSteps: widget.totalSteps,
                onNext: widget.onNext,
                onBack: widget.onBack,
                onSkip: widget.onSkip,
                isLastStep: widget.isLastStep,
                arrowAlignmentX: arrowAlignmentX,
              ),
            ),
        ],
      ),
    );
  }
}
