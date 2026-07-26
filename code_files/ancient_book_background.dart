import 'package:flutter/material.dart';
import '../theme/manuscript_theme.dart';

/// Backdrop for the Session Timeline: parchment texture placeholder plus a
/// subtle vignette. Drop a real parchment/manuscript PNG into
/// [backgroundAsset] and it will render in place of the gradient
/// placeholder automatically — no other code needs to change.
class AncientBookBackground extends StatelessWidget {
  final Widget child;
  final String? backgroundAsset;

  const AncientBookBackground({
    super.key,
    required this.child,
    this.backgroundAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base parchment gradient — visible whenever no asset is supplied,
        // or while the asset image is loading/missing.
        const DecoratedBox(
          decoration: BoxDecoration(gradient: ManuscriptColors.parchmentBackground),
        ),
        if (backgroundAsset != null)
          Image.asset(
            backgroundAsset!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
        // Soft vignette to draw focus toward the center of the page.
        const DecoratedBox(
          decoration: BoxDecoration(gradient: ManuscriptColors.vignette),
        ),
        child,
      ],
    );
  }
}
