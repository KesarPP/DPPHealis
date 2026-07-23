import 'package:flutter/material.dart';

class PixelGameHeader extends StatelessWidget {
  final int level;
  final int currentXp;
  final int targetXp;
  final int streakDays;
  final int healthScore;
  final VoidCallback? onMenuTap;
  final VoidCallback? onStatsTap;

  const PixelGameHeader({
    super.key,
    this.level = 4,
    this.currentXp = 500,
    this.targetXp = 750,
    this.streakDays = 12,
    this.healthScore = 88,
    this.onMenuTap,
    this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentXp / targetXp).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20).withValues(alpha: 0.95), // Deep leaf green
        border: const Border(
          bottom: BorderSide(color: Color(0xFFFFD700), width: 3),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Bar: Title & Action Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              const Row(
                children: [
                  Text('🎮 ', style: TextStyle(fontSize: 18)),
                  Text(
                    'HEALTH JOURNEY',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
                      ],
                    ),
                  ),
                ],
              ),

              // Pixel Menu Buttons
              Row(
                children: [
                  _buildPixelIconButton(
                    icon: Icons.bar_chart_rounded,
                    color: const Color(0xFF40C4FF),
                    onTap: onStatsTap ?? () {},
                  ),
                  const SizedBox(width: 8),
                  _buildPixelIconButton(
                    icon: Icons.volume_up_rounded,
                    color: const Color(0xFFFF8A80),
                    onTap: onMenuTap ?? () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Middle Bar: Level & XP Progress
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black87, width: 2),
                ),
                child: Text(
                  'LVL $level',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // XP Bar
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'XP PROGRESS',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '$currentXp / $targetXp XP',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white38, width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF00E676), Color(0xFFB9F6CA)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom Bar: Streak 🔥 & Health Score ❤️
          Row(
            children: [
              Expanded(
                child: _buildStatBadge(
                  emoji: '🔥',
                  label: 'STREAK',
                  value: '$streakDays DAYS',
                  bgColor: const Color(0xFFE65100),
                  borderColor: const Color(0xFFFFB74D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBadge(
                  emoji: '❤️',
                  label: 'HEALTH SCORE',
                  value: '$healthScore / 100',
                  bgColor: const Color(0xFFC62828),
                  borderColor: const Color(0xFFFF8A80),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPixelIconButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildStatBadge({
    required String emoji,
    required String label,
    required String value,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: borderColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NintendoStartButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;

  const NintendoStartButton({
    super.key,
    required this.onPressed,
    this.label = 'CONTINUE ADVENTURE',
  });

  @override
  State<NintendoStartButton> createState() => _NintendoStartButtonState();
}

class _NintendoStartButtonState extends State<NintendoStartButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        margin: EdgeInsets.only(top: _isPressed ? 4.0 : 0.0, bottom: _isPressed ? 0.0 : 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF69F0AE), // Bright mint green
              Color(0xFF00E676), // Vibrant green
              Color(0xFF00C853), // Deep green
            ],
          ),
          border: Border.all(color: const Color(0xFF003300), width: 3),
          boxShadow: _isPressed
              ? []
              : const [
                  BoxShadow(
                    color: Color(0xFF003300),
                    offset: Offset(0, 6),
                    blurRadius: 0, // Blocky 3D Nintendo shadow!
                  ),
                  BoxShadow(
                    color: Colors.black45,
                    offset: Offset(0, 10),
                    blurRadius: 10,
                  ),
                ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '▶ ',
              style: TextStyle(
                color: Color(0xFF003300),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              widget.label,
              style: const TextStyle(
                color: Color(0xFF003300),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(color: Colors.white54, offset: Offset(1, 1), blurRadius: 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
