import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class ActivityHeader extends StatefulWidget {
  final bool isConnected;
  final DateTime? lastSyncTime;
  final VoidCallback onSyncTap;

  const ActivityHeader({
    super.key,
    required this.isConnected,
    this.lastSyncTime,
    required this.onSyncTap,
  });

  @override
  State<ActivityHeader> createState() => _ActivityHeaderState();
}

class _ActivityHeaderState extends State<ActivityHeader> with SingleTickerProviderStateMixin {
  late AnimationController _syncController;

  @override
  void initState() {
    super.initState();
    _syncController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _syncController.dispose();
    super.dispose();
  }

  void _onSyncTap() {
    _syncController.repeat();
    widget.onSyncTap();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _syncController.stop();
    });
  }

  String _getSyncText() {
    if (widget.lastSyncTime == null) return 'Live connected';
    final diff = DateTime.now().difference(widget.lastSyncTime!);
    if (diff.inMinutes == 0) return 'Synced: just now';
    if (diff.inMinutes < 60) return 'Synced: ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Synced: ${diff.inHours}h ago';
    return 'Synced: ${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Half (50% space): Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activity &\nFitness',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Every step brings you closer to your goal!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: GelatoTheme.textLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: widget.isConnected ? GelatoTheme.green : GelatoTheme.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _getSyncText(),
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: GelatoTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right Half (50% space): Sync Now Button & Pointer below it aligned with subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PointingSyncButton(
                  onSyncTap: _onSyncTap,
                  syncController: _syncController,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PointingSyncButton extends StatefulWidget {
  final VoidCallback onSyncTap;
  final AnimationController syncController;

  const _PointingSyncButton({required this.onSyncTap, required this.syncController});

  @override
  State<_PointingSyncButton> createState() => _PointingSyncButtonState();
}

class _PointingSyncButtonState extends State<_PointingSyncButton> with SingleTickerProviderStateMixin {
  late AnimationController _pointerAnim;
  final bool _showPointer = true;

  @override
  void initState() {
    super.initState();
    _pointerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pointerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), // Square shaped
            border: Border.all(color: Colors.black, width: 1.8),
            boxShadow: [
              BoxShadow(color: GelatoTheme.orangeDark.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 3)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.2),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFE0B2), // Soft light orange highlight
                          Color(0xFFFFDAB4), // Gelato Days light orange
                          Color(0xFFFFB74D), // Warm golden orange
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 18,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withValues(alpha: 0.35), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: widget.onSyncTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.2)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns: widget.syncController,
                        child: const Icon(Icons.sync_rounded, color: Color(0xFF7C2D12), size: 18),
                      ),
                      const SizedBox(width: 6),
                      const Flexible(
                        child: Text(
                          'Sync Now',
                          style: TextStyle(color: Color(0xFF7C2D12), fontSize: 13.5, fontWeight: FontWeight.w900, letterSpacing: 0.2),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showPointer) ...[
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _pointerAnim,
            builder: (ctx, child) => Transform.translate(
              offset: Offset(0, -4 * _pointerAnim.value),
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: GelatoTheme.pink,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward_rounded, color: Colors.black, size: 14),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Update progress',
                      style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
