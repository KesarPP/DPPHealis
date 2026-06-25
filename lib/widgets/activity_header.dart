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

class _ActivityHeaderState extends State<ActivityHeader>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
          _HealthConnectBadge(
            isConnected: widget.isConnected,
            lastSyncTime: widget.lastSyncTime,
            syncController: _syncController,
            onSyncTap: _onSyncTap,
          ),
        ],
      ),
    );
  }
}

class _HealthConnectBadge extends StatelessWidget {
  final bool isConnected;
  final DateTime? lastSyncTime;
  final AnimationController syncController;
  final VoidCallback onSyncTap;

  const _HealthConnectBadge({
    required this.isConnected,
    this.lastSyncTime,
    required this.syncController,
    required this.onSyncTap,
  });

  String _getSyncText() {
    if (lastSyncTime == null) return 'Not synced';
    final diff = DateTime.now().difference(lastSyncTime!);
    if (diff.inMinutes == 0) return 'synced: just now';
    if (diff.inMinutes < 60) return 'synced: ${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return 'synced: ${diff.inHours} hours ago';
    return 'synced: ${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2, // Slight shadow
      shadowColor: GelatoTheme.cardShadow.first.color,
      child: InkWell(
        onTap: onSyncTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: GelatoTheme.cardBorder,
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? GelatoTheme.green : GelatoTheme.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isConnected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isConnected ? GelatoTheme.greenDark : GelatoTheme.orangeDark,
                ),
              ),
              const SizedBox(width: 4),
              RotationTransition(
                turns: syncController,
                child: const Icon(
                  Icons.sync,
                  size: 14,
                  color: GelatoTheme.textLight,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.more_vert, size: 14, color: GelatoTheme.textMuted),
            ],
          ),
          const Text(
            'via Health Connect',
            style: TextStyle(
              fontSize: 9,
              color: GelatoTheme.textMuted,
            ),
          ),
          Text(
            _getSyncText(),
            style: const TextStyle(
              fontSize: 9,
              color: GelatoTheme.textMuted,
            ),
          ),
        ],
      ),
    )));
  }
}
