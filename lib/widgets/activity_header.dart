import 'package:flutter/material.dart';

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity & Fitness',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A2E),
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Every step brings you closer to a healthier you! 💚',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Connected',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF22C55E),
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
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.more_vert, size: 14, color: Color(0xFF9CA3AF)),
            ],
          ),
          const Text(
            'via Health Connect',
            style: TextStyle(
              fontSize: 9,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const Text(
            'synced: 2 mins ago',
            style: TextStyle(
              fontSize: 9,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
