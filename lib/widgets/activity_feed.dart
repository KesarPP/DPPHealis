// Deprecated: Manual activity logging has been replaced by ActivitiesLoggedWidget
// sourcing data directly from Google Fit / Health Connect.
import 'package:flutter/material.dart';

@Deprecated('Use ActivitiesLoggedWidget instead')
class ActivityFeed extends StatelessWidget {
  final VoidCallback? onActivityLogged;

  const ActivityFeed({super.key, this.onActivityLogged});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
