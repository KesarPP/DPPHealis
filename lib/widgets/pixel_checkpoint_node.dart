import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'pixel_health_sprites.dart';

enum CheckpointStatus { completed, current, locked }

enum PlatformStyle { woodenSignboard, stoneTablet, campfireStation, wellnessHut }

class MissionNodeData {
  final int sessionNumber;
  final String title;
  final int xpReward;
  final CheckpointStatus status;
  final PlatformStyle style;
  final PixelSprite iconSprite;
  final String description;

  const MissionNodeData({
    required this.sessionNumber,
    required this.title,
    required this.xpReward,
    required this.status,
    required this.style,
    required this.iconSprite,
    required this.description,
  });

  static List<MissionNodeData> get allMissions => [
        const MissionNodeData(
          sessionNumber: 1,
          title: 'Nutrition Basics',
          xpReward: 150,
          status: CheckpointStatus.completed,
          style: PlatformStyle.woodenSignboard,
          iconSprite: PixelSprites.salad,
          description: 'Learn the core foundations of healthy eating and blood sugar control.',
        ),
        const MissionNodeData(
          sessionNumber: 2,
          title: 'Walk Challenge',
          xpReward: 200,
          status: CheckpointStatus.completed,
          style: PlatformStyle.stoneTablet,
          iconSprite: PixelSprites.runningShoe,
          description: 'Step up your daily activity with an engaging walking quest.',
        ),
        const MissionNodeData(
          sessionNumber: 3,
          title: 'Hydration Quest',
          xpReward: 150,
          status: CheckpointStatus.completed,
          style: PlatformStyle.wellnessHut,
          iconSprite: PixelSprites.waterBottle,
          description: 'Master daily hydration to boost energy and metabolic health.',
        ),
        const MissionNodeData(
          sessionNumber: 4,
          title: 'Move More',
          xpReward: 250,
          status: CheckpointStatus.current,
          style: PlatformStyle.campfireStation,
          iconSprite: PixelSprites.dumbbell,
          description: 'Add strength and resistance exercises into your routine.',
        ),
        const MissionNodeData(
          sessionNumber: 5,
          title: 'Heart Health',
          xpReward: 300,
          status: CheckpointStatus.locked,
          style: PlatformStyle.stoneTablet,
          iconSprite: PixelSprites.heart,
          description: 'Protect your cardiovascular system with heart-healthy habits.',
        ),
        const MissionNodeData(
          sessionNumber: 6,
          title: 'Sleep Better',
          xpReward: 200,
          status: CheckpointStatus.locked,
          style: PlatformStyle.wellnessHut,
          iconSprite: PixelSprites.energyOrb,
          description: 'Optimize restorative sleep to balance hormones and cravings.',
        ),
        const MissionNodeData(
          sessionNumber: 7,
          title: 'Smart Plate',
          xpReward: 350,
          status: CheckpointStatus.locked,
          style: PlatformStyle.woodenSignboard,
          iconSprite: PixelSprites.broccoli,
          description: 'Master portion sizes and nutrient balancing for lifelong health.',
        ),
        const MissionNodeData(
          sessionNumber: 8,
          title: 'Lifestyle Master',
          xpReward: 500,
          status: CheckpointStatus.locked,
          style: PlatformStyle.campfireStation,
          iconSprite: PixelSprites.healthyBowl,
          description: 'Achieve total wellness mastery and reverse prediabetes!',
        ),
      ];
}

class PixelCheckpointNode extends StatefulWidget {
  final MissionNodeData mission;
  final VoidCallback? onTap;

  const PixelCheckpointNode({
    super.key,
    required this.mission,
    this.onTap,
  });

  @override
  State<PixelCheckpointNode> createState() => _PixelCheckpointNodeState();
}

class _PixelCheckpointNodeState extends State<PixelCheckpointNode>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (widget.mission.status == CheckpointStatus.completed) {
      return const Color(0xFFFFD700); // Gold border
    } else if (widget.mission.status == CheckpointStatus.current) {
      return const Color(0xFF00E676); // Bright Mint/Green pulse
    } else {
      return const Color(0xFF78909C); // Dimmed slate for locked
    }
  }

  Color get _bgTopColor {
    switch (widget.mission.style) {
      case PlatformStyle.woodenSignboard:
        return const Color(0xFF8D6E63);
      case PlatformStyle.stoneTablet:
        return const Color(0xFF546E7A);
      case PlatformStyle.campfireStation:
        return const Color(0xFFD84315);
      case PlatformStyle.wellnessHut:
        return const Color(0xFF2E7D32);
    }
  }

  Color get _bgBottomColor {
    switch (widget.mission.style) {
      case PlatformStyle.woodenSignboard:
        return const Color(0xFF5D4037);
      case PlatformStyle.stoneTablet:
        return const Color(0xFF37474F);
      case PlatformStyle.campfireStation:
        return const Color(0xFFBF360C);
      case PlatformStyle.wellnessHut:
        return const Color(0xFF1B5E20);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = widget.mission.status == CheckpointStatus.completed;
    final bool isCurrent = widget.mission.status == CheckpointStatus.current;
    final bool isLocked = widget.mission.status == CheckpointStatus.locked;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final double pulse = math.sin(_animController.value * math.pi * 2);
        final double scale = isCurrent ? 1.0 + (0.04 * pulse) : 1.0;
        final double glowAlpha = isCurrent ? 0.4 + (0.3 * pulse) : (isCompleted ? 0.3 : 0.0);

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: 170,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isLocked
                      ? [const Color(0xFF455A64), const Color(0xFF263238)]
                      : [_bgTopColor, _bgBottomColor],
                ),
                border: Border.all(
                  color: _borderColor,
                  width: isCurrent ? 3.5 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _borderColor.withValues(alpha: glowAlpha),
                    blurRadius: isCurrent ? 16 : 8,
                    spreadRadius: isCurrent ? 2 : 0,
                    offset: const Offset(0, 4),
                  ),
                  const BoxShadow(
                    color: Colors.black38,
                    blurRadius: 6,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Session # and XP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white24, width: 1),
                            ),
                            child: Text(
                              'LVL ${widget.mission.sessionNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFFFD700), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '⚡ ',
                                  style: TextStyle(fontSize: 9),
                                ),
                                Text(
                                  '+${widget.mission.xpReward}',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title & Icon Row
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isLocked ? Colors.white24 : Colors.white60,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: isLocked
                                  ? const Icon(Icons.lock_rounded, color: Colors.white54, size: 20)
                                  : PixelSpriteWidget(
                                      sprite: widget.mission.iconSprite,
                                      size: 26,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.mission.title,
                              style: TextStyle(
                                color: isLocked ? Colors.white60 : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black87,
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Celebration Tick & Ribbon for Completed
                  if (isCompleted)
                    Positioned(
                      top: -16,
                      right: -14,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),

                  // Current Progress Pulse Flag
                  if (isCurrent)
                    Positioned(
                      top: -18,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E676),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Text(
                          'CURRENT',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
