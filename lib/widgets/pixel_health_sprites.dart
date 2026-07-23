import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Represents a procedural 2D pixel sprite defined by an ASCII grid and color palette.
class PixelSprite {
  final List<String> grid;
  final Map<String, Color> palette;
  const PixelSprite(this.grid, this.palette);

  /// Paints the sprite onto the canvas at the specified offset and size.
  void paint(Canvas canvas, Offset offset, double size) {
    final int rows = grid.length;
    if (rows == 0) return;
    final int cols = grid[0].length;
    final double pixelWidth = size / cols;
    final double pixelHeight = size / rows;

    for (int y = 0; y < rows; y++) {
      final String row = grid[y];
      for (int x = 0; x < math.min(row.length, cols); x++) {
        final String char = row[x];
        if (char != ' ' && char != '.' && palette.containsKey(char)) {
          final paint = Paint()
            ..color = palette[char]!
            ..style = PaintingStyle.fill;
          canvas.drawRect(
            Rect.fromLTWH(
              offset.dx + x * pixelWidth,
              offset.dy + y * pixelHeight,
              pixelWidth + 0.5, // Prevents hair-thin seams between pixels
              pixelHeight + 0.5,
            ),
            paint,
          );
        }
      }
    }
  }
}

/// A Flutter Widget that displays a procedural PixelSprite.
class PixelSpriteWidget extends StatelessWidget {
  final PixelSprite sprite;
  final double size;
  final VoidCallback? onTap;

  const PixelSpriteWidget({
    super.key,
    required this.sprite,
    this.size = 32.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = CustomPaint(
      size: Size(size, size),
      painter: _PixelSpritePainter(sprite),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      );
    }
    return child;
  }
}

class _PixelSpritePainter extends CustomPainter {
  final PixelSprite sprite;
  _PixelSpritePainter(this.sprite);

  @override
  void paint(Canvas canvas, Size size) {
    sprite.paint(canvas, Offset.zero, math.min(size.width, size.height));
  }

  @override
  bool shouldRepaint(covariant _PixelSpritePainter oldDelegate) {
    return oldDelegate.sprite != sprite;
  }
}

/// A comprehensive library of 16-bit retro health & wellness pixel icons.
class PixelSprites {
  // ─── Fruits & Veggies ────────────────────────────────────────────────────

  static const PixelSprite apple = PixelSprite([
    "    ..G...      ",
    "    ...s..      ",
    "  .RRRRRRRR.    ",
    " .RRRRRRRRRR.   ",
    ".RRRRRRRRRRRR.  ",
    ".WRRRRRRRRRRR.  ",
    ".WWRRRRRRRRRR.  ",
    ".RRRRRRRRRRRR.  ",
    ".RRRRRRRRRRRR.  ",
    ".RRRRRRRRRRRR.  ",
    " .RRRRRRRRRR.   ",
    "  .RRRRRRRR.    ",
    "   ..RRRR..     ",
    "                ",
  ], {
    'R': Color(0xFFE53935), // Red apple
    'W': Color(0xFFFF8A80), // Highlight
    'G': Color(0xFF43A047), // Green leaf
    's': Color(0xFF6D4C41), // Brown stem
  });

  static const PixelSprite carrot = PixelSprite([
    "        ..GG    ",
    "       .GGGG.   ",
    "        ..GG    ",
    "      ..OOOO.   ",
    "     .OOOOOO.   ",
    "    .OOOOOOO.   ",
    "   .WWOOOOO.    ",
    "  .WWOOOOO.     ",
    " .OOOOOOO.      ",
    " .OOOOOO.       ",
    "  .OOOO.        ",
    "   .OO.         ",
    "    ..          ",
    "                ",
  ], {
    'O': Color(0xFFFB8C00), // Orange
    'W': Color(0xFFFFCC80), // Highlight
    'G': Color(0xFF43A047), // Green top
  });

  static const PixelSprite salad = PixelSprite([
    "    ..GG..GG..  ",
    "  .GGGGGGGGGG.  ",
    " .GGRRGGGGRRGG. ",
    " .GGGGGGGGGGGG. ",
    ".BBBBBBBBBBBBBB.",
    ".WBBBBBBBBBBBBB.",
    " .BBBBBBBBBBBB. ",
    "  .BBBBBBBBBB.  ",
    "   ..BBBBBB..   ",
    "     ......     ",
    "                ",
  ], {
    'G': Color(0xFF43A047), // Greens
    'R': Color(0xFFE53935), // Tomato dots
    'B': Color(0xFF8D6E63), // Wooden salad bowl
    'W': Color(0xFFD7CCC8), // Bowl highlight
  });

  static const PixelSprite broccoli = PixelSprite([
    "   ..GGGGGG..   ",
    " .GGGGGGGGGGGG. ",
    ".GGGGGGGGGGGGGG.",
    ".GGGGGGGGGGGGGG.",
    " .GGGGGGGGGGGG. ",
    "   ..GG..GG..   ",
    "     .L..L.     ",
    "     .LLLL.     ",
    "    .LLLLLL.    ",
    "    .LL..LL.    ",
    "                ",
  ], {
    'G': Color(0xFF2E7D32), // Dark green florets
    'L': Color(0xFF81C784), // Light green stalk
  });

  static const PixelSprite banana = PixelSprite([
    "            ..  ",
    "           .s.  ",
    "          .YY.  ",
    "         .YYY.  ",
    "        .YYYY.  ",
    "       .WYYYY.  ",
    "      .WYYYY.   ",
    "     .YYYYYY.   ",
    "    .YYYYYY.    ",
    "  ..YYYYYY.     ",
    " .YYYYYYY.      ",
    "  .......       ",
    "                ",
  ], {
    'Y': Color(0xFFFDD835), // Yellow
    'W': Color(0xFFFFF59D), // Highlight
    's': Color(0xFF5D4037), // Stem
  });

  static const PixelSprite berries = PixelSprite([
    "   ..gg..GG..   ",
    "  .BBBB..RRRR.  ",
    " .BBBBBB.RRRRR. ",
    " .BBBBBB.RRRRR. ",
    "  .BBBB..RRRR.  ",
    "   ....  ....   ",
    "                ",
  ], {
    'B': Color(0xFF3949AB), // Blueberry
    'R': Color(0xFFD32F2F), // Raspberry
    'g': Color(0xFF66BB6A), // Leaf 1
    'G': Color(0xFF43A047), // Leaf 2
  });

  static const PixelSprite healthyBowl = PixelSprite([
    "    ..SS..SS..  ",
    "   .SSSS..SSSS. ",
    "  .GGYYRRGGYYRR.",
    " .GGGGYYYYRRRRGG.",
    ".WWWWWWWWWWWWWW.",
    ".CCCCWCCCCCCCCCC.",
    " .CCCCCCCCCCCC. ",
    "  .CCCCCCCCCC.  ",
    "   ..CCCCCC..   ",
    "                ",
  ], {
    'S': Color(0xFFE0E0E0), // Steam
    'G': Color(0xFF43A047), // Veggie greens
    'Y': Color(0xFFFDD835), // Corn/grain
    'R': Color(0xFFE53935), // Tomato/bean
    'C': Color(0xFF00ACC1), // Cyan bowl
    'W': Color(0xFF80DEEA), // Bowl rim/highlight
  });

  // ─── Fitness & Medical ───────────────────────────────────────────────────

  static const PixelSprite waterBottle = PixelSprite([
    "     ..CC..     ",
    "     .CCCC.     ",
    "    ..BBBB..    ",
    "   .BBBBBBBB.   ",
    "   .WBBBBBBB.   ",
    "   .WWBBBBBB.   ",
    "   .WWBBBBBB.   ",
    "   .WWBBBBBB.   ",
    "   .WWBBBBBB.   ",
    "   .WBBBBBBB.   ",
    "   .BBBBBBBB.   ",
    "    ........    ",
    "                ",
  ], {
    'C': Color(0xFFECEFF1), // White/silver cap
    'B': Color(0xFF1E88E5), // Blue water
    'W': Color(0xFF90CAF9), // Water highlight
  });

  static const PixelSprite heart = PixelSprite([
    "  ..RR..  ..RR..",
    " .RRRRRR..RRRRRR.",
    ".WRRRRRRRRRRRRRR.",
    ".WWRRRRRRRRRRRRR.",
    ".RRRRRRRRRRRRRRR.",
    " .RRRRRRRRRRRRR.",
    "  .RRRRRRRRRRR. ",
    "   .RRRRRRRRR.  ",
    "    .RRRRRRR.   ",
    "     .RRRRR.    ",
    "      .RRR.     ",
    "       .R.      ",
    "                ",
  ], {
    'R': Color(0xFFE53935), // Red heart
    'W': Color(0xFFFF8A80), // Shine highlight
  });

  static const PixelSprite stethoscope = PixelSprite([
    "   .SS....SS.   ",
    "   .SS.  .SS.   ",
    "   .SS.  .SS.   ",
    "   .SS.  .SS.   ",
    "    .SSSSSS.    ",
    "      .SS.      ",
    "      .SS.      ",
    "     .SSSS.     ",
    "    .SS..SS.    ",
    "   .SS.  .SS.   ",
    "   .SS.  .MM.   ",
    "          ..    ",
    "                ",
  ], {
    'S': Color(0xFF78909C), // Silver tubes
    'M': Color(0xFF37474F), // Chest piece
  });

  static const PixelSprite dumbbell = PixelSprite([
    "                ",
    " .DD........DD. ",
    ".DDDD.SSSS.DDDD.",
    ".DDDD.SSSS.DDDD.",
    ".DDDD.SSSS.DDDD.",
    " .DD........DD. ",
    "                ",
  ], {
    'D': Color(0xFF263238), // Dark iron weights
    'S': Color(0xFFB0BEC5), // Silver bar
  });

  static const PixelSprite bicycle = PixelSprite([
    "      ..RR..    ",
    "      .RR.RR.   ",
    "  .KK.RR...RR.  ",
    " .K..KRRR.RRRR. ",
    ".K...K.RR..RR.K.",
    ".K...K..RRRR..K.",
    " .K..K...RR..K. ",
    "  .KK.....RRKK. ",
    "                ",
  ], {
    'R': Color(0xFFE53935), // Red frame
    'K': Color(0xFF37474F), // Black wheels
  });

  static const PixelSprite runningShoe = PixelSprite([
    "                ",
    "      ...BB.    ",
    "     .BBBBB.    ",
    "   ..BBBBBB.    ",
    "  .WWBBBRRRB.   ",
    " .WWWWBRRRRBB.  ",
    ".WWWWWWWWWWWWW. ",
    ".BBBBBBBBBBBBB. ",
    "                ",
  ], {
    'B': Color(0xFF1E88E5), // Blue shoe body
    'R': Color(0xFFE53935), // Red stripe
    'W': Color(0xFFFFFFFF), // White laces/sole
  });

  static const PixelSprite energyOrb = PixelSprite([
    "     ..YY..     ",
    "   ..YYYYYY..   ",
    "  .YYWWYYYYYY.  ",
    " .YYWWWWYYYYYY. ",
    ".YYWWWWWWYYYYYY.",
    ".YYYYWWWWYYYYYY.",
    " .YYYYWWYYYYYY. ",
    "  .YYYYYYYYYY.  ",
    "   ..YYYYYY..   ",
    "     ..YY..     ",
    "                ",
  ], {
    'Y': Color(0xFFFFD54F), // Golden orb
    'W': Color(0xFFE0F7FA), // Glowing center
  });

  // ─── Nature & Environment ────────────────────────────────────────────────

  static const PixelSprite tree = PixelSprite([
    "     ..GG..     ",
    "   ..GGGGGG..   ",
    "  .GGGGGGGGGG.  ",
    " .WGGGGGGGGGGG. ",
    ".WWGGGGGGGGGGGG.",
    ".WGGGGGGGGGGGGG.",
    " .GGGGGGGGGGGG. ",
    "  ..GGGGGGGG..  ",
    "    ...TT...    ",
    "      .TT.      ",
    "      .TT.      ",
    "      .TT.      ",
    "                ",
  ], {
    'G': Color(0xFF388E3C), // Green canopy
    'W': Color(0xFF66BB6A), // Highlight
    'T': Color(0xFF5D4037), // Brown trunk
  });

  static const PixelSprite pineTree = PixelSprite([
    "      ..        ",
    "     .GG.       ",
    "    .GGGG.      ",
    "   .WGGGGG.     ",
    "    .GGGG.      ",
    "   .WGGGGG.     ",
    "  .WWGGGGGG.    ",
    " .WWGGGGGGGG.   ",
    "   ...TT...     ",
    "     .TT.       ",
    "     .TT.       ",
    "                ",
  ], {
    'G': Color(0xFF1B5E20), // Dark green pine
    'W': Color(0xFF43A047), // Pine highlight
    'T': Color(0xFF4E342E), // Dark brown trunk
  });

  static const PixelSprite sun = PixelSprite([
    "   .Y..  ..Y.   ",
    "    .Y.  .Y.    ",
    "  .. .YYYY. ..  ",
    " .YY.YYYYYY.YY. ",
    "    .WWYYYY.    ",
    "    .WWYYYY.    ",
    " .YY.YYYYYY.YY. ",
    "  .. .YYYY. ..  ",
    "    .Y.  .Y.    ",
    "   .Y..  ..Y.   ",
    "                ",
  ], {
    'Y': Color(0xFFFDD835), // Golden yellow
    'W': Color(0xFFFFF59D), // Sun shine
  });

  static const PixelSprite egg = PixelSprite([
    "     ..WW..     ",
    "   ..WWWWWW..   ",
    "  .WWWWWWWWWW.  ",
    " .WWWWYYYYWWWW. ",
    ".WWWWYYYYYYWWWW.",
    ".WWWWYYYYYYWWWW.",
    " .WWWWYYYYWWWW. ",
    "  .WWWWWWWWWW.  ",
    "   ..WWWWWW..   ",
    "     ..WW..     ",
    "                ",
  ], {
    'W': Color(0xFFFFFFFF), // White egg
    'Y': Color(0xFFFFB300), // Golden yolk
  });

  static const PixelSprite leaf = PixelSprite([
    "               .",
    "             .G.",
    "           .GGG.",
    "         .WGGGG.",
    "       .WWGGGGG.",
    "     .WWGGGGGG. ",
    "   .WWGGGGGG..  ",
    " .WWGGGGGG..    ",
    ".WGGGGGG..      ",
    " .GGGG..        ",
    "  ..s.          ",
    "   ..           ",
    "                ",
  ], {
    'G': Color(0xFF43A047), // Leaf green
    'W': Color(0xFF81C784), // Leaf highlight
    's': Color(0xFF33691E), // Stem
  });

  static const PixelSprite mushroom = PixelSprite([
    "    ..RRRR..    ",
    "  .RRRRRRRRRR.  ",
    " .RRWRRRRRRWRR. ",
    ".RRWWWRRRRRWWWR.",
    ".RRRWRRRRRRRWRR.",
    " .RRRRRRRRRRRR. ",
    "   ...TTTT...   ",
    "     .TTTT.     ",
    "     .TTTT.     ",
    "     .TTTT.     ",
    "                ",
  ], {
    'R': Color(0xFFE53935), // Red cap
    'W': Color(0xFFFFFFFF), // White spots
    'T': Color(0xFFFFE082), // Tan stalk
  });

  static const PixelSprite pond = PixelSprite([
    "    ..BBBBBB..  ",
    "  .BBBBBBBBBBBB.",
    " .BBWWBBBBBBGGGB.",
    ".BBWWWWBBBBGGGGG.",
    ".BBBBBBBBBBGGGGG.",
    " .BBBBBBBBBBGGGB.",
    "  .BBBBBBBBBBBB.",
    "    ..BBBBBB..  ",
    "                ",
  ], {
    'B': Color(0xFF29B6F6), // Blue water
    'W': Color(0xFFB3E5FC), // Water ripple
    'G': Color(0xFF66BB6A), // Lily pad
  });

  static const PixelSprite cabin = PixelSprite([
    "       ..RR     ",
    "     ..RRRR..   ",
    "   ..RRRRRRRR.. ",
    " ..RRRRRRRRRRRR.",
    " .WWWWWWWWWWWW. ",
    " .WW..WWWW..WW. ",
    " .WWCWWWWWWCWW. ",
    " .WW..WWWW..WW. ",
    " .WWWWWWDDWWWW. ",
    " .WWWWWWDDWWWW. ",
    "                ",
  ], {
    'R': Color(0xFFC62828), // Red roof
    'W': Color(0xFF8D6E63), // Log walls
    'C': Color(0xFF80DEEA), // Cyan window
    'D': Color(0xFF4E342E), // Brown door
  });

  static const PixelSprite fence = PixelSprite([
    " .W.  .W.  .W.  ",
    " .W.  .W.  .W.  ",
    ".WWWWWWWWWWWWWW.",
    " .W.  .W.  .W.  ",
    ".WWWWWWWWWWWWWW.",
    " .W.  .W.  .W.  ",
    "                ",
  ], {
    'W': Color(0xFF8D6E63), // Wooden fence
  });

  static const PixelSprite cloud = PixelSprite([
    "     ..WW..     ",
    "   ..WWWWWW..   ",
    "  .WWWWWWWWWW.  ",
    " .WWWWWWWWWWWW. ",
    ".WWWWWWWWWWWWWW.",
    ".SSSSSSSSSSSSSS.",
    " .SSSSSSSSSSSS. ",
    "   ..........   ",
    "                ",
  ], {
    'W': Color(0xFFFFFFFF), // White cloud
    'S': Color(0xFFE0F7FA), // Soft blue shadow
  });

  /// Returns a list of all health objects for easy scattering across the map.
  static List<PixelSprite> get allHealthObjects => [
        apple,
        carrot,
        salad,
        broccoli,
        banana,
        berries,
        healthyBowl,
        waterBottle,
        heart,
        stethoscope,
        dumbbell,
        bicycle,
        runningShoe,
        energyOrb,
        egg,
        leaf,
        mushroom,
      ];
}
