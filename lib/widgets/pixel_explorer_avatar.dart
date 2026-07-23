import 'dart:math' as math;
import 'package:flutter/material.dart';

class ExplorerOutfit {
  final String name;
  final Color outfitColor;
  final Color capColor;
  final Color backpackColor;
  final Color shoeColor;

  const ExplorerOutfit({
    required this.name,
    required this.outfitColor,
    required this.capColor,
    required this.backpackColor,
    required this.shoeColor,
  });

  static const List<ExplorerOutfit> allOutfits = [
    ExplorerOutfit(
      name: 'Mint Explorer',
      outfitColor: Color(0xFF2E7D32),
      capColor: Color(0xFF66BB6A),
      backpackColor: Color(0xFF5D4037),
      shoeColor: Color(0xFF1E88E5),
    ),
    ExplorerOutfit(
      name: 'Berry Runner',
      outfitColor: Color(0xFFC62828),
      capColor: Color(0xFFFF8A80),
      backpackColor: Color(0xFF37474F),
      shoeColor: Color(0xFFFFFFFF),
    ),
    ExplorerOutfit(
      name: 'Sky Athlete',
      outfitColor: Color(0xFF1565C0),
      capColor: Color(0xFF4FC3F7),
      backpackColor: Color(0xFF3E2723),
      shoeColor: Color(0xFFFFD54F),
    ),
    ExplorerOutfit(
      name: 'Golden Champion',
      outfitColor: Color(0xFFF9A825),
      capColor: Color(0xFFFFE082),
      backpackColor: Color(0xFF455A64),
      shoeColor: Color(0xFFE53935),
    ),
    ExplorerOutfit(
      name: 'Violet Voyager',
      outfitColor: Color(0xFF6A1B9A),
      capColor: Color(0xFFCE93D8),
      backpackColor: Color(0xFF4E342E),
      shoeColor: Color(0xFF00ACC1),
    ),
  ];
}

class PixelExplorerAvatar extends StatefulWidget {
  final double size;
  final ValueNotifier<ExplorerOutfit>? outfitNotifier;

  const PixelExplorerAvatar({
    super.key,
    this.size = 64.0,
    this.outfitNotifier,
  });

  @override
  State<PixelExplorerAvatar> createState() => _PixelExplorerAvatarState();
}

class _PixelExplorerAvatarState extends State<PixelExplorerAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _idleController;
  late ExplorerOutfit _currentOutfit;
  int _animFrame = 0;

  @override
  void initState() {
    super.initState();
    _currentOutfit = widget.outfitNotifier?.value ?? ExplorerOutfit.allOutfits[0];
    widget.outfitNotifier?.addListener(_onOutfitChanged);

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..addListener(() {
        final int newFrame = (_idleController.value * 4).floor() % 4;
        if (newFrame != _animFrame) {
          setState(() {
            _animFrame = newFrame;
          });
        }
      });
    _idleController.repeat();
  }

  void _onOutfitChanged() {
    if (widget.outfitNotifier != null) {
      setState(() {
        _currentOutfit = widget.outfitNotifier!.value;
      });
    }
  }

  @override
  void dispose() {
    widget.outfitNotifier?.removeListener(_onOutfitChanged);
    _idleController.dispose();
    super.dispose();
  }

  void _showCustomizationModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF263238),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CUSTOMIZE EXPLORER',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose your healthy adventurer style for your journey to reverse prediabetes!',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Outfit Grid
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: ExplorerOutfit.allOutfits.map((outfit) {
                      final bool isSelected = outfit.name == _currentOutfit.name;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentOutfit = outfit;
                          });
                          if (widget.outfitNotifier != null) {
                            widget.outfitNotifier!.value = outfit;
                          }
                          setModalState(() {});
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? outfit.outfitColor.withValues(alpha: 0.3) : Colors.black26,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: outfit.outfitColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: outfit.capColor, width: 3),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(Icons.check_rounded, color: isSelected ? Colors.white : Colors.transparent, size: 20),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                outfit.name.split(' ')[0],
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFFFFD700) : Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'EQUIP OUTFIT',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bobbing animation: frame 1 & 3 bob up 2 pixels
    final double bobOffset = (_animFrame == 1 || _animFrame == 3) ? -2.0 : 0.0;
    // Waving animation: on frame 2, wave hand
    final bool isWaving = _animFrame == 2;

    return GestureDetector(
      onTap: _showCustomizationModal,
      child: AnimatedBuilder(
        animation: _idleController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, bobOffset),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Shadow underneath
                Positioned(
                  bottom: -4,
                  child: Container(
                    width: widget.size * 0.7,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // Procedural Avatar Canvas
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ExplorerAvatarPainter(
                    outfit: _currentOutfit,
                    isWaving: isWaving,
                  ),
                ),

                // Customization hint badge
                Positioned(
                  top: 0,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.checkroom_rounded,
                      color: Colors.black87,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ExplorerAvatarPainter extends CustomPainter {
  final ExplorerOutfit outfit;
  final bool isWaving;

  _ExplorerAvatarPainter({required this.outfit, required this.isWaving});

  @override
  void paint(Canvas canvas, Size size) {
    final List<String> grid = [
      "    ..CCCC..    ",
      "   .CCCCCCCC.   ",
      "   .CCCCCCCW.   ",
      "   ..FFFFFF..   ",
      "   .FFEFFFFE.   ",
      "   .FFFFFFFF.   ",
      "    ..FFFF..    ",
      "  ..OOOOOOOO..  ",
      " .BBOOOOOOOO..  ",
      ".BB.OOOOOOOO.W. ",
      ".BB.OOOOOOOO.W. ",
      "    .OO..OO.    ",
      "    .OO..OO.    ",
      "   .SSS..SSS.   ",
      "   .SSS..SSS.   ",
      "                ",
    ];

    if (isWaving) {
      grid[8] = " .BBOOOOOOOO.F. ";
      grid[9] = ".BB.OOOOOOOO..  ";
      grid[10] = ".BB.OOOOOOOO.W. ";
    }

    final Map<String, Color> palette = {
      'C': outfit.capColor,
      'W': const Color(0xFF80DEEA), // Water bottle / cap highlight
      'F': const Color(0xFFFFCC80), // Skin tone
      'E': const Color(0xFF3E2723), // Eyes
      'O': outfit.outfitColor,
      'B': outfit.backpackColor,
      'S': outfit.shoeColor,
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
  bool shouldRepaint(covariant _ExplorerAvatarPainter oldDelegate) {
    return oldDelegate.outfit != outfit || oldDelegate.isWaving != isWaving;
  }
}
