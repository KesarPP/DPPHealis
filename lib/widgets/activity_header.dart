import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class ActivityHeader extends StatefulWidget {
  const ActivityHeader({super.key});

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
                Text(
                  'Activity & Fitness',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: GelatoTheme.textDark,
                        letterSpacing: -0.5,
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
            syncController: _syncController,
            onSyncTap: _onSyncTap,
          ),
        ],
      ),
    );
  }
}

class _HealthConnectBadge extends StatelessWidget {
  final AnimationController syncController;
  final VoidCallback onSyncTap;

  const _HealthConnectBadge({
    required this.syncController,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
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
                decoration: const BoxDecoration(
                  color: GelatoTheme.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Connected',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: GelatoTheme.greenDark,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onSyncTap,
                child: RotationTransition(
                  turns: syncController,
                  child: const Icon(
                    Icons.sync,
                    size: 14,
                    color: GelatoTheme.textLight,
                  ),
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
          const Text(
            'synced: 2 mins ago',
            style: TextStyle(
              fontSize: 9,
              color: GelatoTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
