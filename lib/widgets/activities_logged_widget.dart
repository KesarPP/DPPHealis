import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/gelato_theme.dart';
import '../models/ndpp_constants.dart';

class ActivitiesLoggedWidget extends StatefulWidget {
  final List<DailyAggregate> pastDays;
  final bool isConnected;
  final VoidCallback onConnectGoogleFit;

  const ActivitiesLoggedWidget({
    super.key,
    required this.pastDays,
    required this.isConnected,
    required this.onConnectGoogleFit,
  });

  @override
  State<ActivitiesLoggedWidget> createState() => _ActivitiesLoggedWidgetState();
}

class _ActivitiesLoggedWidgetState extends State<ActivitiesLoggedWidget> {
  String? _selectedDateKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14), // Reduced card size
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: GelatoTheme.blue.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: GelatoTheme.blueDark,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Activities Logged',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: GelatoTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.isConnected
                      ? GelatoTheme.green.withValues(alpha: 0.3)
                      : GelatoTheme.orange.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Text(
                  widget.isConnected ? 'Synced' : 'Not Connected',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: widget.isConnected ? GelatoTheme.greenDark : GelatoTheme.orangeDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content based on connection status
          if (!widget.isConnected)
            _buildNotConnectedState()
          else
            _buildSessionsList(),
        ],
      ),
    );
  }

  Widget _buildNotConnectedState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: GelatoTheme.blue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.sync_disabled_rounded,
            size: 36,
            color: GelatoTheme.blueDark,
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect Google Fit to see activities',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: GelatoTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Automatically track workouts, duration, and calories burned directly from Google Fit / Health Connect.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: GelatoTheme.textDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: widget.onConnectGoogleFit,
            icon: const Icon(Icons.link_rounded, size: 16, color: Colors.white),
            label: const Text(
              'Connect Google Fit',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: GelatoTheme.blueDark,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    // Collect all sessions grouped by day, reverse chronologically
    final Map<String, List<ActivitySession>> grouped = {};
    
    final sortedDays = [...widget.pastDays]..sort((a, b) => b.date.compareTo(a.date));

    for (var day in sortedDays) {
      final sessions = day.allSessions;
      if (sessions.isNotEmpty) {
        final dateKey = _formatDayHeader(day.date);
        grouped[dateKey] = sessions;
      }
    }

    if (grouped.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 8),
            const Text(
              'No activity logged yet today',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: GelatoTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your workouts recorded in Google Fit / Health Connect will automatically appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: GelatoTheme.textDark.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Default to the first (newest) day key if selected is null or missing
    final String currentKey = (_selectedDateKey != null && grouped.containsKey(_selectedDateKey))
        ? _selectedDateKey!
        : grouped.keys.first;

    final sessionsForDay = grouped[currentKey]!;
    final bool isToday = currentKey.startsWith('TODAY');

    // Calculate totals for enlarged banner
    int totalMins = 0;
    double totalCals = 0;
    for (var s in sessionsForDay) {
      totalMins += s.durationMinutes;
      if (s.hasCalorieData && s.caloriesBurned > 0) {
        totalCals += s.caloriesBurned;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown for selecting Day
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentKey,
              isExpanded: true,
              icon: const Icon(Icons.calendar_today_rounded, size: 16, color: GelatoTheme.textDark),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: GelatoTheme.textDark,
              ),
              items: grouped.keys.map((k) {
                return DropdownMenuItem<String>(
                  value: k,
                  child: Text(k),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedDateKey = val;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Enlarged version for Current Ongoing Day (Today)
        if (isToday) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '$totalMins min',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ongoing Day Active Time',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70),
                    ),
                  ],
                ),
                Container(width: 1, height: 32, color: Colors.white24),
                Column(
                  children: [
                    Text(
                      '${totalCals.round()} kcal',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Calories Burned Today',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Compact sessions list for selected day
        ...sessionsForDay.map((session) => _buildSessionCard(session)),
      ],
    );
  }

  String _formatDayHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return 'TODAY, ${DateFormat('MMM d').format(date).toUpperCase()}';
    } else if (target == today.subtract(const Duration(days: 1))) {
      return 'YESTERDAY, ${DateFormat('MMM d').format(date).toUpperCase()}';
    } else {
      return DateFormat('EEEE, MMM d').format(date).toUpperCase();
    }
  }

  Widget _buildSessionCard(ActivitySession session) {
    final timeFormat = DateFormat('h:mm a');
    final timeRange = '${timeFormat.format(session.startTime)} - ${timeFormat.format(session.endTime)}';

    IconData icon;
    Color color;
    Color darkColor;

    switch (session.activityType) {
      case ActivityType.walking:
      case ActivityType.briskWalking:
        icon = Icons.directions_walk_rounded;
        color = GelatoTheme.green;
        darkColor = GelatoTheme.greenDark;
        break;
      case ActivityType.swimming:
        icon = Icons.pool_rounded;
        color = GelatoTheme.blue;
        darkColor = GelatoTheme.blueDark;
        break;
      case ActivityType.dancing:
        icon = Icons.music_note_rounded;
        color = GelatoTheme.pink;
        darkColor = GelatoTheme.pinkDark;
        break;
      case ActivityType.stairClimbing:
        icon = Icons.stairs_rounded;
        color = GelatoTheme.orange;
        darkColor = GelatoTheme.orangeDark;
        break;
      case ActivityType.stretching:
        icon = Icons.self_improvement_rounded;
        color = GelatoTheme.purple;
        darkColor = GelatoTheme.purpleDark;
        break;
      default:
        icon = Icons.fitness_center_rounded;
        color = GelatoTheme.yellow;
        darkColor = GelatoTheme.yellowDark;
        break;
    }

    final displayCals = (!session.hasCalorieData || session.caloriesBurned <= 0)
        ? '—'
        : '${session.caloriesBurned.round()}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10), // Reduced item size
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 1.2),
            ),
            child: Icon(icon, color: darkColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.readableName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                  ),
                ),
                Text(
                  timeRange,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${session.durationMinutes} min',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: GelatoTheme.textDark,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 13, color: Color(0xFFEA580C)),
                  const SizedBox(width: 2),
                  Text(
                    '$displayCals kcal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: displayCals == '—' ? const Color(0xFF94A3B8) : const Color(0xFFEA580C),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
