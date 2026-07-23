import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'pixel_health_sprites.dart';
import 'pixel_checkpoint_node.dart';
import 'pixel_explorer_avatar.dart';
import 'pixel_destination_castle.dart';

class RetroOverworldMap extends StatefulWidget {
  final Function(int addedXp)? onXpEarned;
  final Function(MissionNodeData mission)? onMissionTap;
  final VoidCallback? onCastleTap;
  final ValueNotifier<ExplorerOutfit>? outfitNotifier;

  const RetroOverworldMap({
    super.key,
    this.onXpEarned,
    this.onMissionTap,
    this.onCastleTap,
    this.outfitNotifier,
  });

  @override
  State<RetroOverworldMap> createState() => _RetroOverworldMapState();
}

class _RetroOverworldMapState extends State<RetroOverworldMap>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _envController;
  final Set<int> _collectedItemIndices = {};
  String? _popupMessage;
  Timer? _popupTimer;

  // Map dimensions
  static const double _mapWidth = 400.0;
  static const double _mapHeight = 2400.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _envController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Auto-scroll to current progress (around Y = 1300, which is roughly the middle/lower section)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          1100.0, // PositionsCheckpoint 4 & avatar nicely in view
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _envController.dispose();
    _popupTimer?.cancel();
    super.dispose();
  }

  void _onCollectibleTap(int index, String name, int xp, PixelSprite sprite) {
    if (_collectedItemIndices.contains(index)) return;

    setState(() {
      _collectedItemIndices.add(index);
      _popupMessage = '+${xp}XP! Collected $name!';
    });

    widget.onXpEarned?.call(xp);

    _popupTimer?.cancel();
    _popupTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _popupMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Scrollable Overworld Map
        InteractiveViewer(
          constrained: false,
          scaleEnabled: false,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: _mapWidth,
                height: _mapHeight,
                child: AnimatedBuilder(
                  animation: _envController,
                  builder: (context, child) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1. Background Landscape & Stone Trail Layer
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _RetroOverworldBackgroundPainter(
                              time: _envController.value,
                            ),
                          ),
                        ),

                        // 2. Animated Environmental Decorations (Clouds, Butterflies, Water Ripples)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _AnimatedDecorationsPainter(
                              time: _envController.value,
                            ),
                          ),
                        ),

                        // 3. Scattered Health Collectibles
                        ..._buildCollectibles(),

                        // 4. Milestone Checkpoints (8 Missions)
                        ..._buildCheckpoints(),

                        // 5. Explorer Avatar at Current Progress Node (Node 4)
                        Positioned(
                          left: 110,
                          top: 1330,
                          child: PixelExplorerAvatar(
                            size: 68,
                            outfitNotifier: widget.outfitNotifier,
                          ),
                        ),

                        // 6. Destination Golden Castle at Top
                        Positioned(
                          left: 40,
                          top: 40,
                          child: PixelDestinationCastle(
                            onTap: widget.onCastleTap,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Floating Toast Banner for Collected Items
        if (_popupMessage != null)
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder: (context, val, child) {
                return Transform.scale(
                  scale: val,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF00C853)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('✨ ', style: TextStyle(fontSize: 18)),
                        Text(
                          _popupMessage!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Text(' ✨', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  List<Widget> _buildCheckpoints() {
    final missions = MissionNodeData.allMissions;
    // Coordinates along the winding stone trail from bottom (Session 1) to top (Session 8)
    final List<Offset> positions = [
      const Offset(200, 2050),  // Session 1 (Bottom Right)
      const Offset(40, 1800),   // Session 2 (Left Curve)
      const Offset(200, 1550),  // Session 3 (Right Curve)
      const Offset(40, 1300),   // Session 4 (Left Curve - CURRENT!)
      const Offset(200, 1050),  // Session 5 (Right Curve)
      const Offset(40, 800),    // Session 6 (Left Curve)
      const Offset(200, 550),   // Session 7 (Right Curve)
      const Offset(115, 330),   // Session 8 (Just below Castle!)
    ];

    return List.generate(missions.length, (i) {
      final pos = positions[i];
      final mission = missions[i];
      return Positioned(
        left: pos.dx,
        top: pos.dy,
        child: PixelCheckpointNode(
          mission: mission,
          onTap: () => widget.onMissionTap?.call(mission),
        ),
      );
    });
  }

  List<Widget> _buildCollectibles() {
    final List<_CollectibleData> items = [
      _CollectibleData(index: 0, x: 80, y: 2150, name: 'Crisp Red Apple 🍎', xp: 15, sprite: PixelSprites.apple),
      _CollectibleData(index: 1, x: 310, y: 1950, name: 'Hydration Water 💧', xp: 20, sprite: PixelSprites.waterBottle),
      _CollectibleData(index: 2, x: 60, y: 1700, name: 'Crunchy Carrot 🥕', xp: 15, sprite: PixelSprites.carrot),
      _CollectibleData(index: 3, x: 320, y: 1450, name: 'Heart Boost ❤️', xp: 25, sprite: PixelSprites.heart),
      _CollectibleData(index: 4, x: 50, y: 1180, name: 'Strength Dumbbell 🏋', xp: 20, sprite: PixelSprites.dumbbell),
      _CollectibleData(index: 5, x: 310, y: 920, name: 'Fresh Berries 🫐', xp: 15, sprite: PixelSprites.berries),
      _CollectibleData(index: 6, x: 70, y: 680, name: 'Energy Orb ⚡', xp: 30, sprite: PixelSprites.energyOrb),
      _CollectibleData(index: 7, x: 300, y: 480, name: 'Super Salad Bowl 🥗', xp: 25, sprite: PixelSprites.salad),
      // Nature objects (non-collectible decor along trail)
      _CollectibleData(index: -1, x: 30, y: 2200, name: '', xp: 0, sprite: PixelSprites.tree),
      _CollectibleData(index: -1, x: 330, y: 2250, name: '', xp: 0, sprite: PixelSprites.pineTree),
      _CollectibleData(index: -1, x: 340, y: 1750, name: '', xp: 0, sprite: PixelSprites.cabin),
      _CollectibleData(index: -1, x: 20, y: 1500, name: '', xp: 0, sprite: PixelSprites.pond),
      _CollectibleData(index: -1, x: 330, y: 1250, name: '', xp: 0, sprite: PixelSprites.tree),
      _CollectibleData(index: -1, x: 20, y: 1000, name: '', xp: 0, sprite: PixelSprites.pineTree),
      _CollectibleData(index: -1, x: 320, y: 750, name: '', xp: 0, sprite: PixelSprites.cabin),
      _CollectibleData(index: -1, x: 30, y: 500, name: '', xp: 0, sprite: PixelSprites.pond),
      _CollectibleData(index: -1, x: 330, y: 250, name: '', xp: 0, sprite: PixelSprites.pineTree),
    ];

    return items.map((item) {
      if (item.index != -1 && _collectedItemIndices.contains(item.index)) {
        return const SizedBox.shrink(); // Hide collected item
      }

      final bool isCollectible = item.index != -1;
      return Positioned(
        left: item.x,
        top: item.y,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          builder: (context, val, child) {
            final double floatY = isCollectible ? -4.0 * math.sin(val * math.pi * 2 + item.y) : 0.0;
            return Transform.translate(
              offset: Offset(0, floatY),
              child: PixelSpriteWidget(
                sprite: item.sprite,
                size: isCollectible ? 36 : 48,
                onTap: isCollectible
                    ? () => _onCollectibleTap(item.index, item.name, item.xp, item.sprite)
                    : null,
              ),
            );
          },
        ),
      );
    }).toList();
  }
}

class _CollectibleData {
  final int index;
  final double x;
  final double y;
  final String name;
  final int xp;
  final PixelSprite sprite;

  _CollectibleData({
    required this.index,
    required this.x,
    required this.y,
    required this.name,
    required this.xp,
    required this.sprite,
  });
}

class _RetroOverworldBackgroundPainter extends CustomPainter {
  final double time;
  _RetroOverworldBackgroundPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    const int cols = 40;
    final double pixelSize = size.width / cols;
    final int rows = (size.height / pixelSize).ceil();

    // Vibrant Gelato / Retro Palettes
    final Paint paintGrass1 = Paint()..color = const Color(0xFF7BCA5C); // Bright green
    final Paint paintGrass2 = Paint()..color = const Color(0xFF6AB44F); // Slightly darker green
    final Paint paintGrass3 = Paint()..color = const Color(0xFF8CE06D); // Fresh mint highlight
    final Paint paintFlowerYellow = Paint()..color = const Color(0xFFFDD835);
    final Paint paintFlowerRed = Paint()..color = const Color(0xFFE53935);
    final Paint paintFlowerWhite = Paint()..color = const Color(0xFFFFFFFF);

    // Stone Pathway Palettes
    final Paint paintStoneNormal = Paint()..color = const Color(0xFF90A4AE); // Rustic gray stone
    final Paint paintStoneBorder = Paint()..color = const Color(0xFF607D8B); // Dark stone edge
    final Paint paintStoneGold = Paint()..color = const Color(0xFFFFD700); // Completed golden stone
    final Paint paintStoneGoldBorder = Paint()..color = const Color(0xFFFFA000);
    final Paint paintStoneDark = Paint()..color = const Color(0xFF455A64); // Locked darkened stone

    // Mountain Horizon at top (rows 0 to 15)
    final Paint paintMountain = Paint()..color = const Color(0xFF5C6BC0);
    final Paint paintMountainPeak = Paint()..color = const Color(0xFFE8EAF6);

    for (int y = 0; y < rows; y++) {
      final double progress = y / rows; // 0 at top (Castle), 1 at bottom (Start)
      
      // Calculate winding trail center
      final double wave = math.sin(progress * math.pi * 7);
      final int pathCenter = (cols * 0.5 + wave * (cols * 0.28)).round();
      const int pathWidth = 3; // 7 blocks wide total

      for (int x = 0; x < cols; x++) {
        final Rect rect = Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize + 0.5, pixelSize + 0.5);

        // Draw Distant Mountains at very top
        if (y < 16) {
          final int mHeight = 16 - ((math.sin(x * 0.3) + 1) * 6).round();
          if (y > mHeight) {
            if (y < mHeight + 3) {
              canvas.drawRect(rect, paintMountainPeak); // Snow cap
            } else {
              canvas.drawRect(rect, paintMountain);
            }
            continue;
          }
        }

        // Check if point is on the winding stone trail
        if (x >= pathCenter - pathWidth && x <= pathCenter + pathWidth) {
          final bool isBorder = (x == pathCenter - pathWidth || x == pathCenter + pathWidth);
          final bool isCobbleGap = (x + y) % 2 == 0;

          // Determine trail state based on Y coordinate:
          // Bottom to Y=1300 is Completed (Golden). Y=1300 to Y=1100 is Current (Normal). Above Y=1100 is Locked (Dark/Mist).
          final double yCoord = y * pixelSize;
          if (yCoord > 1300) {
            // Completed Golden Trail!
            if (isBorder) {
              canvas.drawRect(rect, paintStoneGoldBorder);
            } else {
              canvas.drawRect(rect, isCobbleGap ? paintStoneGold : paintStoneGoldBorder);
            }
          } else if (yCoord > 800) {
            // Normal Stone Trail
            if (isBorder) {
              canvas.drawRect(rect, paintStoneBorder);
            } else {
              canvas.drawRect(rect, isCobbleGap ? paintStoneNormal : paintStoneBorder);
            }
          } else {
            // Locked Darkened Trail
            canvas.drawRect(rect, isBorder ? paintStoneDark : (isCobbleGap ? paintStoneDark : paintStoneBorder));
          }
        } else {
          // Draw Rich Grass & Flowers
          if ((x * 13 + y * 17) % 19 == 0) {
            canvas.drawRect(rect, paintGrass2);
          } else if ((x * 23 + y * 29) % 37 == 0) {
            canvas.drawRect(rect, paintGrass3);
          } else if ((x * 7 + y * 11) % 43 == 0) {
            // Small flower dot!
            final int fType = (x + y) % 3;
            canvas.drawRect(rect, fType == 0 ? paintFlowerYellow : (fType == 1 ? paintFlowerRed : paintFlowerWhite));
          } else {
            canvas.drawRect(rect, paintGrass1);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RetroOverworldBackgroundPainter oldDelegate) => false;
}

class _AnimatedDecorationsPainter extends CustomPainter {
  final double time;
  _AnimatedDecorationsPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Drifting Clouds across the screen
    final Paint cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final List<Offset> cloudBases = [
      const Offset(20, 200),
      const Offset(250, 450),
      const Offset(80, 800),
      const Offset(200, 1200),
      const Offset(40, 1600),
      const Offset(240, 2000),
    ];

    for (int i = 0; i < cloudBases.length; i++) {
      final base = cloudBases[i];
      final double speed = 15.0 + (i * 5);
      final double currentX = ((base.dx + time * speed) % (size.width + 100)) - 50;
      
      // Draw a blocky 16-bit cloud
      canvas.drawRect(Rect.fromLTWH(currentX, base.dy, 40, 16), cloudPaint);
      canvas.drawRect(Rect.fromLTWH(currentX + 8, base.dy - 8, 24, 8), cloudPaint);
    }

    // 2. Flying Butterflies across the wellness trail
    final Paint butterflyPaint = Paint()..color = const Color(0xFFFF8A80);
    for (int i = 0; i < 6; i++) {
      final double bX = ((100 + i * 80 + time * 25) % size.width);
      final double bY = 300 + (i * 350) + 15 * math.sin(time * math.pi * 2 + i);
      final bool wingsOpen = (time * 8 + i).floor() % 2 == 0;

      if (wingsOpen) {
        canvas.drawRect(Rect.fromLTWH(bX, bY, 3, 3), butterflyPaint);
        canvas.drawRect(Rect.fromLTWH(bX + 5, bY, 3, 3), butterflyPaint);
      } else {
        canvas.drawRect(Rect.fromLTWH(bX + 2, bY - 2, 4, 4), butterflyPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedDecorationsPainter oldDelegate) => true;
}
