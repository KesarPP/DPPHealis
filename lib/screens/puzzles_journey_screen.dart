import 'package:flutter/material.dart';
import '../main.dart';

class PuzzlesJourneyScreen extends StatefulWidget {
  const PuzzlesJourneyScreen({super.key});

  @override
  State<PuzzlesJourneyScreen> createState() => _PuzzlesJourneyScreenState();
}

class _PuzzlesJourneyScreenState extends State<PuzzlesJourneyScreen> {
  final ScrollController _scrollController = ScrollController();

  // Define canvas size
  final double canvasWidth = 600;
  final double canvasHeight = 1600;

  @override
  void initState() {
    super.initState();
    // Scroll to bottom initially to show level 1
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3F693B),
      body: Stack(
        children: [
          // 1. Scrollable Map
          SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              // We use a FittedBox to ensure our virtual canvas scales to the screen width
              child: FittedBox(
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
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

                      // Trees & Scenery
                      Positioned(left: 350, top: 1250, child: _buildAppleTree()),
                      Positioned(left: 100, top: 750, child: _buildBigTree()),
                      Positioned(left: 450, top: 300, child: _buildPond()),
                      Positioned(left: 120, top: 180, child: _buildBigTree()),
                      Positioned(left: 350, top: 850, child: _buildHouse()),
                      Positioned(left: 140, top: 830, child: _buildBench()),

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
                      _buildNode(17, 260, 200, isCompleted: false),
                      _buildNode(18, 210, 130, isCompleted: false),
                    ],
                  ),
                ),
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
      child: isCompleted ? _WoodStumpNode(number: number) : _StoneBlockNode(number: number),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.list, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                MainShell.of(context)?.selectedIndex = 1;
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF7CB342), // Light green button
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF558B2F),
                      offset: Offset(0, 4), // Fake 3D bottom border
                    )
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Start Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudsArea() {
    return Stack(
      children: [
        // Gradient overlay for smooth transition
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 0.8, 1.0],
              ),
            ),
          ),
        ),
        // Stylized puffy cloud shapes
        Positioned(left: 50, bottom: 100, child: _CloudPuff(size: 150)),
        Positioned(left: 150, bottom: 80, child: _CloudPuff(size: 200)),
        Positioned(left: 300, bottom: 150, child: _CloudPuff(size: 180)),
        Positioned(left: -50, bottom: 200, child: _CloudPuff(size: 250)),
        Positioned(left: 400, bottom: 100, child: _CloudPuff(size: 220)),
        Positioned(left: 200, bottom: 220, child: _CloudPuff(size: 160)),
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

    // Isometric grid dimensions (width is twice the height roughly)
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

        canvas.drawPath(path, (x + y) % 2 == 0 ? paintDark : paintLight);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WoodStumpNode extends StatelessWidget {
  final int number;
  const _WoodStumpNode({required this.number});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base depth (darker wood)
          Positioned(
            bottom: 0,
            child: Container(
              width: 70,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF5D4037),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // Top cut surface (lighter wood)
          Positioned(
            top: 0,
            child: Container(
              width: 66,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFD7CCC8), // Very light wood
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF8D6E63), width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Color(0xFF5D4037),
                  fontSize: 22,
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
      width: 60,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Base depth
          Positioned(
            bottom: 0,
            child: Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF78909C), // Darker grey-blue
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Top surface
          Positioned(
            top: 0,
            child: Container(
              width: 56,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFCFD8DC), // Lighter grey
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF90A4AE), width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Color(0xFF78909C),
                  fontSize: 18,
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

class _CloudPuff extends StatelessWidget {
  final double size;
  const _CloudPuff({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.7,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.all(Radius.elliptical(size, size * 0.7)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))
        ]
      ),
    );
  }
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
