import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../main.dart';

class PuzzlesJourneyScreen extends StatefulWidget {
  const PuzzlesJourneyScreen({super.key});

  @override
  State<PuzzlesJourneyScreen> createState() => _PuzzlesJourneyScreenState();
}

class _PuzzlesJourneyScreenState extends State<PuzzlesJourneyScreen> {
  final TransformationController _transformationController = TransformationController();

  // Define canvas size
  final double canvasWidth = 600;
  final double canvasHeight = 1600;

  int _currentPawnLevel = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size screenSize = MediaQuery.of(context).size;
      final double scale = screenSize.width / canvasWidth; // Reset to fit exactly one width (same as old FittedBox)
      
      final Matrix4 matrix = Matrix4.identity()
        ..translate(
          0.0, // Aligned to left
          -(canvasHeight * scale - screenSize.height) + 120, // Pin to bottom (above bottom bar)
        )
        ..scale(scale);
        
      _transformationController.value = matrix;
    });

  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3F693B),
      body: Stack(
        children: [
          // 1. Scrollable Zoom Map
          InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            minScale: 0.5,
            maxScale: 3.0,
            boundaryMargin: const EdgeInsets.all(200),
            child: SizedBox(
              width: canvasWidth,
              height: canvasHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Isometric Checkerboard Background
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _IsometricCheckerboardPainter(),
                        ),
                      ),
                      
                      // Clouds (Obscuring future levels)
                      Positioned(
                        top: 0,
                        left: -100,
                        right: -100,
                        height: 900, // Covers upper half
                        child: _buildCloudsArea(),
                      ),

                      // Path Nodes (bottom to top)
                      _buildNode(1, 400, 1400, isCompleted: true),
                      _buildNode(2, 330, 1340, isCompleted: true),
                      _buildNode(3, 260, 1280, isCompleted: true),
                      _buildNode(4, 190, 1220, isCompleted: true),
                      _buildNode(5, 120, 1160, isCompleted: true),
                      _buildNode(6, 180, 1070, isCompleted: true),
                      _buildNode(7, 240, 980, isCompleted: true),
                      _buildNode(8, 300, 890, isCompleted: true),
                      _buildNode(9, 360, 800, isCompleted: true),
                      _buildNode(10, 310, 720, isCompleted: true),
                      _buildNode(11, 260, 640, isCompleted: true),
                      _buildNode(12, 210, 560, isCompleted: true),
                      _buildNode(13, 160, 480, isCompleted: true),
                      // Locked levels in clouds
                      _buildNode(14, 210, 410, isCompleted: false),
                      _buildNode(15, 260, 340, isCompleted: false),
                      _buildNode(16, 310, 270, isCompleted: false),

                      // Player Pawn Mascot! Travels from level 1 to 2
                      AnimatedPositioned(
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOutCubic,
                        left: (_currentPawnLevel == 1 ? 400.0 : 330.0) + 10, // Offset to center on stump
                        top: (_currentPawnLevel == 1 ? 1400.0 : 1340.0) - 45, // Shifted up so feet rest on top
                        child: _PlayerPawn(),
                      ),
                    ],
                  ),
                ),
              ),
          
          // 4. Bottom UI Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(int number, double x, double y, {required bool isCompleted}) {
    return Positioned(
      left: x,
      top: y,
      child: isCompleted ? _WoodStumpNode(number: number, isHighlighted: _currentPawnLevel == number) : _StoneBlockNode(number: number),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF355231).withValues(alpha: 0.95),
      ),
      child: Row(
        children: [
          _buildNavButton(
            context: context,
            icon: Icons.restaurant,
            label: 'Meals',
            color: const Color(0xFFE53935), // Red/Orange for meals
            onTap: () => MainShell.of(context)?.selectedIndex = 3,
          ),
          const SizedBox(width: 12),
          _buildNavButton(
            context: context,
            icon: Icons.directions_run,
            label: 'Activity',
            color: const Color(0xFF039BE5), // Blue for activity
            onTap: () => MainShell.of(context)?.selectedIndex = 4,
          ),
          const SizedBox(width: 12),
          _buildNavButton(
            context: context,
            icon: Icons.play_arrow,
            label: 'Sessions',
            color: const Color(0xFF7CB342), // Green for sessions
            onTap: () => MainShell.of(context)?.selectedIndex = 5,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCloudsArea() {
    return Stack(
      children: [
        // Subtle fog overlay for the locked area
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.6),
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Stylized puffy anime cloud shapes with floating delays
        // Positioned using 'top' to perfectly cover levels 14, 15, and 16 (Y: 270-410)
        Positioned(left: 30, top: 380, child: _CloudPuff(size: 180, delay: 0.0)),
        Positioned(left: 170, top: 250, child: _CloudPuff(size: 240, delay: 0.5)),
        Positioned(left: 280, top: 320, child: _CloudPuff(size: 200, delay: 1.2)),
        Positioned(left: -60, top: 150, child: _CloudPuff(size: 280, delay: 0.8)),
        Positioned(left: 400, top: 220, child: _CloudPuff(size: 260, delay: 1.5)),
        Positioned(left: 150, top: 100, child: _CloudPuff(size: 190, delay: 0.3)),
      ],
    );
  }

  // --- Scenery Elements ---

  Widget _buildAppleTree() {
    return SizedBox(
      width: 100,
      height: 140,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Trunk
          Container(
            width: 20,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFF795548), borderRadius: BorderRadius.circular(4)),
          ),
          // Leaves (bottom to top overlapping)
          Positioned(bottom: 30, child: _TreeLeaves(size: 80, hasApples: true)),
          Positioned(bottom: 60, child: _TreeLeaves(size: 70, hasApples: false)),
          Positioned(bottom: 90, child: _TreeLeaves(size: 60, hasApples: true)),
        ],
      ),
    );
  }

  Widget _buildBigTree() {
    return SizedBox(
      width: 120,
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Trunk
          Container(
            width: 24,
            height: 60,
            decoration: BoxDecoration(color: const Color(0xFF8D6E63), borderRadius: BorderRadius.circular(4)),
          ),
          // Leaves
          Positioned(bottom: 50, child: _TreeLeaves(size: 100)),
          Positioned(bottom: 90, child: _TreeLeaves(size: 90)),
          Positioned(bottom: 130, child: _TreeLeaves(size: 70)),
        ],
      ),
    );
  }

  Widget _buildPond() {
    return Container(
      width: 150,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF29B6F6),
        borderRadius: const BorderRadius.all(Radius.elliptical(150, 90)),
        border: Border.all(color: const Color(0xFF0288D1), width: 4),
      ),
      child: Stack(
        children: const [
          Positioned(left: 20, top: 20, child: _LilyPad()),
          Positioned(left: 80, top: 40, child: _LilyPad()),
          Positioned(left: 50, top: 60, child: _LilyPad(size: 15)),
        ],
      ),
    );
  }

  Widget _buildHouse() {
    return SizedBox(
      width: 120,
      height: 140,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Base
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFD7CCC8), // Wooden beige
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF8D6E63), width: 2),
            ),
          ),
          // Door
          Positioned(
            bottom: 0,
            left: 40,
            child: Container(
              width: 30,
              height: 45,
              decoration: const BoxDecoration(
                color: Color(0xFF5D4037),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: const Icon(Icons.shield, color: Colors.green, size: 16),
            ),
          ),
          // Roof
          Positioned(
            top: 20,
            child: CustomPaint(
              size: const Size(120, 50),
              painter: _RoofPainter(),
            ),
          ),
          // Chimney
          Positioned(
            top: 10,
            right: 25,
            child: Container(
              width: 16,
              height: 30,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBench() {
    return SizedBox(
      width: 80,
      height: 60,
      child: Stack(
        children: [
          // Wood planks
          Positioned(top: 20, left: 0, child: Container(width: 80, height: 6, color: const Color(0xFF8D6E63))),
          Positioned(top: 28, left: 0, child: Container(width: 80, height: 6, color: const Color(0xFF8D6E63))),
          Positioned(top: 36, left: 0, child: Container(width: 80, height: 20, color: const Color(0xFF795548))),
          // Chessboard on bench
          Positioned(
            top: 34,
            left: 20,
            child: Container(
              width: 24,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black87, width: 1),
              ),
              child: CustomPaint(painter: _ChessboardPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Painters & Minor Widgets ---

class _IsometricCheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = const Color(0xFF3A6133);
    final paintLight = Paint()..color = const Color(0xFF426E3A);
    final lockedDark = Paint()..color = const Color(0xFF9E9E9E); // Greyish for locked tiles
    final lockedLight = Paint()..color = const Color(0xFFBDBDBD);

    // Isometric grid dimensions
    const double tileWidth = 80.0;
    const double tileHeight = 40.0;

    // Draw tiles
    for (int y = -20; y < (size.height / tileHeight) + 20; y++) {
      for (int x = -10; x < (size.width / tileWidth) + 10; x++) {
        // Offset alternating rows
        final double offsetX = x * tileWidth + (y % 2 == 0 ? 0 : tileWidth / 2);
        final double offsetY = y * tileHeight;

        final path = Path();
        path.moveTo(offsetX, offsetY - tileHeight / 2); // Top
        path.lineTo(offsetX + tileWidth / 2, offsetY); // Right
        path.lineTo(offsetX, offsetY + tileHeight / 2); // Bottom
        path.lineTo(offsetX - tileWidth / 2, offsetY); // Left
        path.close();

        // Diagonal dividing line representing the "foggy" locked area bounds
        bool isLocked = offsetY < (0.5 * offsetX + 350);
        
        bool isEven = (x + y) % 2 == 0;
        Paint currentPaint = isLocked 
            ? (isEven ? lockedDark : lockedLight) 
            : (isEven ? paintDark : paintLight);

        canvas.drawPath(path, currentPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WoodStumpNode extends StatelessWidget {
  final int number;
  final bool isHighlighted;
  const _WoodStumpNode({required this.number, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      height: 66,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Drop shadow
          Positioned(
            bottom: -2,
            child: Container(
              width: 66,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  isHighlighted
                      ? const BoxShadow(color: Color(0xFFFFD700), blurRadius: 16, offset: Offset(0, 4))
                      : const BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 8))
                ],
              ),
            ),
          ),
          // Base depth (darker wood)
          Positioned(
            bottom: 0,
            child: Container(
              width: 76,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6D4C41), Color(0xFF3E2723)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Top cut surface (lighter wood)
          Positioned(
            top: 0,
            child: Container(
              width: 72,
              height: 52,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0xFFEFEBE9), Color(0xFFD7CCC8)],
                  radius: 0.8,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isHighlighted ? const Color(0xFFFFD700) : const Color(0xFF8D6E63),
                  width: isHighlighted ? 4 : 3,
                ),
                boxShadow: [
                  isHighlighted
                      ? BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.8), blurRadius: 8, offset: const Offset(0, -2))
                      : BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 2, offset: const Offset(0, -2))
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Color(0xFF4E342E),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoneBlockNode extends StatelessWidget {
  final int number;
  const _StoneBlockNode({required this.number});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Drop shadow
          Positioned(
            bottom: -2,
            child: Container(
              width: 56,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 6))
                ]
              ),
            ),
          ),
          // Base depth
          Positioned(
            bottom: 0,
            child: Container(
              width: 66,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF78909C), Color(0xFF455A64)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Top surface
          Positioned(
            top: 0,
            child: Container(
              width: 62,
              height: 46,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0xFFECEFF1), Color(0xFFCFD8DC)],
                  radius: 0.8,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF90A4AE), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.white.withValues(alpha: 0.7), blurRadius: 2, offset: const Offset(0, -2))
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Color(0xFF546E7A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeLeaves extends StatelessWidget {
  final double size;
  final bool hasApples;
  
  const _TreeLeaves({required this.size, this.hasApples = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF689F38), // Vibrant leaf green
              borderRadius: BorderRadius.all(Radius.elliptical(size, size * 0.8)),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))
              ]
            ),
          ),
          if (hasApples) ...[
            const Positioned(left: 10, top: 10, child: Icon(Icons.circle, color: Colors.red, size: 8)),
            const Positioned(right: 20, top: 20, child: Icon(Icons.circle, color: Colors.red, size: 8)),
            const Positioned(left: 30, bottom: 15, child: Icon(Icons.circle, color: Colors.red, size: 8)),
          ]
        ],
      ),
    );
  }
}

class _LilyPad extends StatelessWidget {
  final double size;
  const _LilyPad({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF7CB342),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CloudPuff extends StatefulWidget {
  final double size;
  final double delay;

  const _CloudPuff({required this.size, this.delay = 0});

  @override
  State<_CloudPuff> createState() => _CloudPuffState();
}

class _CloudPuffState extends State<_CloudPuff> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _animation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: SizedBox(
            width: widget.size,
            height: widget.size * 0.7,
            child: CustomPaint(
              painter: _AnimeCloudPainter(),
            ),
          ),
        );
      },
    );
  }
}

class _AnimeCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path cloudPath = Path();
    // Left puff
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.05, size.height * 0.4, size.width * 0.35, size.height * 0.5));
    // Top-center puff
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.3, size.height * 0.1, size.width * 0.4, size.height * 0.6));
    // Right puff
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.6, size.height * 0.3, size.width * 0.35, size.height * 0.55));
    // Bottom filler
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.15, size.height * 0.5, size.width * 0.7, size.height * 0.45));

    // Inner smaller puffs for extra anime volume
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.4, size.height * 0.3, size.width * 0.3, size.height * 0.4));
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.25, size.height * 0.45, size.width * 0.25, size.height * 0.35));

    final paintStroke = Paint()
      ..color = const Color(0xFFB2EBF2) // Light cyan/blue outline matching the screenshot
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeJoin = StrokeJoin.round;

    final paintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw the thick cyan border. Because the stroke is centered on the path, 
    // the inner intersections will be drawn here but completely painted over by the white fill!
    canvas.drawPath(cloudPath, paintStroke);
    
    // Fill the cloud with white, perfectly covering the inner intersecting strokes and 
    // leaving only the crisp outer cyan border visible.
    canvas.drawPath(cloudPath, paintFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawPath(path, paint);
    
    // Draw tiles pattern
    final tilePaint = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (double y = 10; y < size.height; y += 10) {
      canvas.drawLine(Offset(size.width / 2 - y, y), Offset(size.width / 2 + y, y), tilePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChessboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBlack = Paint()..color = Colors.black87;
    final double tileW = size.width / 4;
    final double tileH = size.height / 2;

    for (int y = 0; y < 2; y++) {
      for (int x = 0; x < 4; x++) {
        if ((x + y) % 2 == 1) {
          canvas.drawRect(Rect.fromLTWH(x * tileW, y * tileH, tileW, tileH), paintBlack);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayerPawn extends StatefulWidget {
  @override
  State<_PlayerPawn> createState() => _PlayerPawnState();
}

class _PlayerPawnState extends State<_PlayerPawn> with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 * _floatController.value), // Subtle gentle float up and down
          child: child,
        );
      },
      child: Image.asset(
        'assets/images/heart_mascot_red.png',
        width: 70, // Slightly taller as requested
        height: 70,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _MovingClouds extends StatefulWidget {
  const _MovingClouds({super.key});

  @override
  State<_MovingClouds> createState() => _MovingCloudsState();
}

class _MovingCloudsState extends State<_MovingClouds> with SingleTickerProviderStateMixin {
  late final AnimationController _cloudController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(40 * math.sin(_cloudController.value * math.pi * 2), 15 * math.cos(_cloudController.value * math.pi * 2)),
          child: child,
        );
      },
      // Using the same CustomPaint clouds but animated
      child: CustomPaint(
        painter: _AnimeCloudPainter(),
      ),
    );
  }
}
