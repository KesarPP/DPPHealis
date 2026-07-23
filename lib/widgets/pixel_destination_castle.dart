import 'dart:math' as math;
import 'package:flutter/material.dart';

class PixelDestinationCastle extends StatefulWidget {
  final VoidCallback? onTap;

  const PixelDestinationCastle({super.key, this.onTap});

  @override
  State<PixelDestinationCastle> createState() => _PixelDestinationCastleState();
}

class _PixelDestinationCastleState extends State<PixelDestinationCastle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<_ConfettiParticle> _confetti = [];
  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 25; i++) {
      _confetti.add(_ConfettiParticle.random(_rnd));
    }
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 320,
        height: 280,
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Radiating Sun Rays
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SunRaysPainter(rotation: _animController.value * math.pi * 2),
                  ),
                ),

                // Confetti & Sparkles Layer
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ConfettiPainter(
                      confetti: _confetti,
                      progress: _animController.value,
                    ),
                  ),
                ),

                // Castle Sprite & Trophy
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Floating Trophy Icon
                    Transform.translate(
                      offset: Offset(0, -6 * math.sin(_animController.value * math.pi * 4)),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700), width: 2),
                          boxShadow: const [
                            BoxShadow(color: Color(0xFFFFD700), blurRadius: 20, spreadRadius: 4),
                          ],
                        ),
                        child: const Text(
                          '🏆',
                          style: TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Procedural Castle
                    const SizedBox(
                      width: 200,
                      height: 140,
                      child: CustomPaint(
                        painter: _CastlePainter(),
                      ),
                    ),

                    // Hall of Wellness Banner
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD84315), Color(0xFFBF360C)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD700), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('✨ ', style: TextStyle(fontSize: 12)),
                          Text(
                            'HALL OF WELLNESS',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(' ✨', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SunRaysPainter extends CustomPainter {
  final double rotation;
  _SunRaysPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height * 0.55);
    final double maxRadius = math.max(size.width, size.height) * 0.8;
    final int rayCount = 12;

    final Paint paint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < rayCount; i++) {
      final double angle = rotation + (i * (math.pi * 2 / rayCount));
      final Path path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + maxRadius * math.cos(angle - 0.15),
          center.dy + maxRadius * math.sin(angle - 0.15),
        )
        ..lineTo(
          center.dx + maxRadius * math.cos(angle + 0.15),
          center.dy + maxRadius * math.sin(angle + 0.15),
        )
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SunRaysPainter oldDelegate) => oldDelegate.rotation != rotation;
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double speed;
  final Color color;
  final double size;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.color,
    required this.size,
  });

  factory _ConfettiParticle.random(math.Random rnd) {
    final List<Color> colors = [
      const Color(0xFFFFD700),
      const Color(0xFF00E676),
      const Color(0xFFFF8A80),
      const Color(0xFF40C4FF),
      const Color(0xFFEA80FC),
    ];
    return _ConfettiParticle(
      x: rnd.nextDouble(),
      y: rnd.nextDouble(),
      speed: 0.5 + rnd.nextDouble() * 1.5,
      color: colors[rnd.nextInt(colors.length)],
      size: 3 + rnd.nextDouble() * 5,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> confetti;
  final double progress;

  _ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in confetti) {
      final double currentY = ((p.y + progress * p.speed) % 1.0) * size.height;
      final double currentX = (p.x + 0.05 * math.sin((progress * p.speed + p.y) * math.pi * 4)) * size.width;

      final Paint paint = Paint()..color = p.color;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(currentX, currentY), width: p.size, height: p.size),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

class _CastlePainter extends CustomPainter {
  const _CastlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final List<String> grid = [
      "    ..YY..      ..YY..    ",
      "    .YYYY.      .YYYY.    ",
      "    .RRRR.      .RRRR.    ",
      "  ..WWWWWW..  ..WWWWWW..  ",
      "  .WWWWWWWW.  .WWWWWWWW.  ",
      "  .WW.CC.WW.  .WW.CC.WW.  ",
      "  .WWWWWWWW....WWWWWWWW.  ",
      "  .WWWWWWWWWWWWWWWWWWWW.  ",
      "  .WWWWWWWWWWWWWWWWWWWW.  ",
      "  .WWWWWWWW.YY.WWWWWWWW.  ",
      "  .WWWWWWWWYYYYWWWWWWWW.  ",
      "  .WW.CC.WWYYYYWW.CC.WW.  ",
      "  .WWWWWWWWYYYYWWWWWWWW.  ",
      "  .WWWWWWWWDDDDWWWWWWWW.  ",
      "  .WWWWWWWWDDDDWWWWWWWW.  ",
      "                          ",
    ];

    final Map<String, Color> palette = {
      'Y': const Color(0xFFFFD700), // Gold spires / accents
      'R': const Color(0xFFC62828), // Ruby red flags
      'W': const Color(0xFFCFD8DC), // Stone castle walls
      'C': const Color(0xFF80DEEA), // Cyan stained glass windows
      'D': const Color(0xFF4E342E), // Grand oak doors
    };

    final int rows = grid.length;
    final int cols = grid[0].length;
    final double pixelWidth = size.width / cols;
    final double pixelHeight = size.height / rows;

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
              x * pixelWidth,
              y * pixelHeight,
              pixelWidth + 0.5,
              pixelHeight + 0.5,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CastlePainter oldDelegate) => false;
}
