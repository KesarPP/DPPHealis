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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activity & Fitness',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Every step brings you closer to a healthier you!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GelatoTheme.textLight,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.isConnected ? GelatoTheme.green : GelatoTheme.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getSyncText(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GelatoTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Repositioned Top Middle Prominent Sync Button with Pointing Animation
          Center(
            child: _PointingSyncButton(
              onSyncTap: _onSyncTap,
              syncController: _syncController,
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
  bool _showPointer = true;

  @override
  void initState() {
    super.initState();
    _pointerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showPointer = false;
        });
        _pointerAnim.stop();
      }
    });
  }

  @override
  void dispose() {
    _pointerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(27),
            border: Border.all(color: Colors.black, width: 2.5),
            boxShadow: [
              BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3B82F6), // Royal blue shine highlight
                          Color(0xFF1E3A8A), // Deep navy blue
                          Color(0xFF0F172A), // Dark navy slate
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withValues(alpha: 0.22), Colors.transparent],
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RotationTransition(
                        turns: widget.syncController,
                        child: const Icon(Icons.sync_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Sync Activity Now',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showPointer) ...[
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _pointerAnim,
            builder: (ctx, child) => Transform.translate(
              offset: Offset(-8 * _pointerAnim.value, 0),
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: GelatoTheme.orangeDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text('CLICK TO SYNC', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
