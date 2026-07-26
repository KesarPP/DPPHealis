import 'package:flutter/material.dart';
import '../models/week_model.dart';
import '../theme/manuscript_theme.dart';

/// Which side of the timeline this card sits on, for the alternating
/// left/right "treasure map" layout.
enum CardAlignment { left, right }

/// A single collectible "chapter" card in the Session Timeline. Styling
/// adapts to [WeekModel.state]:
/// - locked: faded, no glow, taps disabled
/// - current: pulsing gold border glow
/// - completed: golden shine gradient
/// - perfect: shine gradient plus animated sparkle glow
class SessionWeekCard extends StatefulWidget {
  final WeekModel week;
  final CardAlignment alignment;
  final VoidCallback? onTap;

  const SessionWeekCard({
    super.key,
    required this.week,
    required this.alignment,
    this.onTap,
  });

  @override
  State<SessionWeekCard> createState() => _SessionWeekCardState();
}

class _SessionWeekCardState extends State<SessionWeekCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowController;
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: ManuscriptMotion.glowPulse,
    );
    _floatController = AnimationController(
      vsync: this,
      duration: ManuscriptMotion.floatCycle,
    )..repeat(reverse: true);

    if (_shouldGlow(widget.week.state)) {
      _glowController.repeat(reverse: true);
    }
  }

  bool _shouldGlow(WeekCardState state) =>
      state == WeekCardState.current || state == WeekCardState.perfect;

  @override
  void didUpdateWidget(covariant SessionWeekCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldGlow = _shouldGlow(widget.week.state);
    if (shouldGlow && !_glowController.isAnimating) {
      _glowController.repeat(reverse: true);
    } else if (!shouldGlow) {
      _glowController.stop();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.week.state;
    final isLocked = state == WeekCardState.locked;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowController, _floatController]),
        builder: (context, _) {
          final floatOffset = isLocked ? 0.0 : (_floatController.value - 0.5) * 6;

          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: Opacity(
              opacity: isLocked ? 0.55 : 1.0,
              child: _buildCard(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, WeekCardState state) {
    final glowStrength = _glowController.value;

    return GestureDetector(
      onTap: state == WeekCardState.locked ? null : widget.onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(16),
        decoration: _decorationForState(state, glowStrength),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.alignment == CardAlignment.left) _illustration(state),
            if (widget.alignment == CardAlignment.left) const SizedBox(width: 12),
            Expanded(child: _cardBody(state)),
            if (widget.alignment == CardAlignment.right) const SizedBox(width: 12),
            if (widget.alignment == CardAlignment.right) _illustration(state),
          ],
        ),
      ),
    );
  }

  BoxDecoration _decorationForState(WeekCardState state, double glowStrength) {
    switch (state) {
      case WeekCardState.locked:
        return BoxDecoration(
          color: ManuscriptColors.parchmentDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ManuscriptColors.lockedFade, width: 1),
        );
      case WeekCardState.current:
        return BoxDecoration(
          color: ManuscriptColors.parchment,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Color.lerp(
              ManuscriptColors.gold,
              ManuscriptColors.goldLight,
              glowStrength,
            )!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: ManuscriptColors.gold.withOpacity(0.25 + glowStrength * 0.25),
              blurRadius: 14 + glowStrength * 10,
              spreadRadius: 1,
            ),
          ],
        );
      case WeekCardState.completed:
        return BoxDecoration(
          gradient: ManuscriptColors.goldShine,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ManuscriptColors.goldDeep, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33A8862B),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        );
      case WeekCardState.perfect:
        return BoxDecoration(
          gradient: ManuscriptColors.goldShine,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Color.lerp(
              ManuscriptColors.goldDeep,
              Colors.white,
              glowStrength * 0.6,
            )!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: ManuscriptColors.gold.withOpacity(0.4 + glowStrength * 0.3),
              blurRadius: 18 + glowStrength * 12,
              spreadRadius: 2,
            ),
          ],
        );
    }
  }

  Widget _illustration(WeekCardState state) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 52,
            height: 52,
            color: ManuscriptColors.darkBrown.withOpacity(0.08),
            child: Image.asset(
              widget.week.iconAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.menu_book_rounded,
                color: ManuscriptColors.bronzeDark,
              ),
            ),
          ),
        ),
        if (state == WeekCardState.perfect)
          const Positioned(
            top: -4,
            right: -4,
            child: Icon(Icons.auto_awesome, size: 16, color: ManuscriptColors.gold),
          ),
      ],
    );
  }

  Widget _cardBody(WeekCardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Ch. ${widget.week.id}', style: ManuscriptTextStyles.chapterNumber),
            const Spacer(),
            _statusIndicator(state),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.week.title,
          style: ManuscriptTextStyles.cardTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          widget.week.subtitle,
          style: ManuscriptTextStyles.cardSubtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: widget.week.progress,
            minHeight: 5,
            backgroundColor: ManuscriptColors.darkBrown.withOpacity(0.08),
            valueColor: const AlwaysStoppedAnimation(ManuscriptColors.gold),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${(widget.week.progress * 100).round()}%',
              style: ManuscriptTextStyles.cardSubtitle,
            ),
            const Spacer(),
            const Icon(Icons.bolt, size: 14, color: ManuscriptColors.goldDeep),
            const SizedBox(width: 2),
            Text('${widget.week.xp} XP', style: ManuscriptTextStyles.xpLabel),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: state == WeekCardState.locked
                  ? ManuscriptColors.lockedFade
                  : ManuscriptColors.bronzeDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusIndicator(WeekCardState state) {
    switch (state) {
      case WeekCardState.locked:
        return const Icon(Icons.lock_rounded, size: 18, color: ManuscriptColors.lockedFade);
      case WeekCardState.current:
        return const Icon(Icons.play_circle_fill_rounded, size: 18, color: ManuscriptColors.gold);
      case WeekCardState.completed:
        return const Icon(Icons.check_circle_rounded, size: 18, color: ManuscriptColors.goldDeep);
      case WeekCardState.perfect:
        return const Icon(Icons.workspace_premium_rounded, size: 18, color: ManuscriptColors.gold);
    }
  }
}
