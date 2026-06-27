import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/activity_log.dart';

/// Purely presentational — never touches Firestore, the repository,
/// or the service layer. Receives already-loaded state from
/// ActivityFitnessScreen.
class ActivityTimelineWidget extends StatelessWidget {
  final List<ActivityLog> logs;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ActivityTimelineWidget({
    super.key,
    required this.logs,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildShimmerList();
    if (errorMessage != null) return _buildErrorState(context);
    if (logs.isEmpty) return _buildEmptyState(context);
    return _buildList();
  }

  Widget _buildList() {
    return Column(
      children: logs.map((log) => _ActivityTimelineCard(log: log)).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.directions_walk_rounded, size: 48, color: outline),
          const SizedBox(height: 12),
          Text(
            'No activities logged today',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: outline),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded,
              size: 40, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? "Couldn't load today's activities",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (onRetry != null)
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  // Simple shimmer placeholder using plain containers. Swap for the
  // `shimmer` package if it's already a dependency elsewhere in the app,
  // for visual consistency with other loading states.
  Widget _buildShimmerList() {
    return Column(
      children: List.generate(
        3,
            (i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(height: 64, color: Colors.grey.withOpacity(0.15)),
          ),
        ),
      ),
    );
  }
}

class _ActivityTimelineCard extends StatelessWidget {
  final ActivityLog log;

  const _ActivityTimelineCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat('h:mm a').format(log.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(log.activityName),
        subtitle: Text('${log.durationMinutes} min · ${log.frequency}'),
        trailing: Text(timeLabel, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}