import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/gelato_theme.dart';
import '../services/points_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Map<String, dynamic>? _fallbackUser;

  @override
  void initState() {
    super.initState();
    _ensureCurrentUserInLeaderboard();
  }

  void _ensureCurrentUserInLeaderboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await PointsService.ensureLeaderboardEntry(
        user.uid,
        user.displayName ?? 'User',
      );

      // Fetch user's own points as reliable fallback in case /leaderboard stream has permissions error
      try {
        final lbDoc = await FirebaseFirestore.instance.collection('leaderboard').doc(user.uid).get();
        final currentWeekKey = PointsService.getCurrentWeekKey();
        final int thisWeekPoints = (lbDoc.exists && lbDoc.data()?['weekKey'] == currentWeekKey)
            ? ((lbDoc.data()?['weeklyPoints'] as num?)?.toInt() ?? 0)
            : 0;

        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (mounted) {
          final totalPoints = (userDoc.data()?['totalPoints'] as num?)?.toInt() ?? 0;
          final name = (userDoc.data()?['name'] as String?) ?? user.displayName ?? 'User';
          setState(() {
            _fallbackUser = {
              'uid': user.uid,
              'name': 'You',
              'displayName': name,
              'points': thisWeekPoints,
              'badges': (totalPoints / 100).floor(),
              'isUser': true,
            };
          });
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('leaderboard').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData &&
            !snapshot.hasError) {
          return const Scaffold(
            backgroundColor: GelatoTheme.bg,
            body: Center(
              child: CircularProgressIndicator(color: GelatoTheme.purpleDark),
            ),
          );
        }

        final bool hasPermissionError = snapshot.hasError;
        final currentWeekKey = PointsService.getCurrentWeekKey();
        final allUsers = <Map<String, dynamic>>[];

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final String? docWeekKey = data['weekKey'] as String?;

            // If the document is from an earlier week, points reset to 0 for this week!
            final int weeklyPoints = (docWeekKey == currentWeekKey)
                ? ((data['weeklyPoints'] as num?)?.toInt() ?? 0)
                : 0;

            final int totalPoints =
                (data['totalPoints'] as num?)?.toInt() ?? 0;
            final int points = weeklyPoints;

            final rawName = data['name'] as String?;
            final String name =
                (rawName != null && rawName.trim().isNotEmpty)
                    ? rawName.trim()
                    : 'User';
            final bool isUser = doc.id == currentUid;
            final int badges = (data['badgesCount'] as num?)?.toInt() ??
                (totalPoints / 100).floor();

            allUsers.add({
              'uid': doc.id,
              'name': isUser ? 'You' : name,
              'points': points,
              'badges': badges,
              'isUser': isUser,
            });
          }
        }

        // If stream errored (e.g. firestore.rules on cloud not yet updated for /leaderboard),
        // fallback to the user's personal record so they still see their score on the podium!
        if (allUsers.isEmpty && _fallbackUser != null) {
          allUsers.add(Map<String, dynamic>.from(_fallbackUser!));
        }

        // Sort descending by points
        allUsers.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));

        // Find user's actual position
        int userRank = -1;
        Map<String, dynamic>? currentUserEntry;
        for (int i = 0; i < allUsers.length; i++) {
          if (allUsers[i]['isUser'] == true) {
            userRank = i + 1;
            currentUserEntry = allUsers[i];
            break;
          }
        }

        // Prepare podium slots (top 3)
        final Map<String, dynamic> firstPlace = allUsers.isNotEmpty
            ? {
                ...allUsers[0],
                'rank': 1,
                'isOpen': false,
              }
            : {
                'name': 'Open Spot',
                'points': 0,
                'badges': 0,
                'rank': 1,
                'isUser': false,
                'isOpen': true,
              };

        final Map<String, dynamic> secondPlace = allUsers.length > 1
            ? {
                ...allUsers[1],
                'rank': 2,
                'isOpen': false,
              }
            : {
                'name': 'Open Spot',
                'points': 0,
                'badges': 0,
                'rank': 2,
                'isUser': false,
                'isOpen': true,
              };

        final Map<String, dynamic> thirdPlace = allUsers.length > 2
            ? {
                ...allUsers[2],
                'rank': 3,
                'isOpen': false,
              }
            : {
                'name': 'Open Spot',
                'points': 0,
                'badges': 0,
                'rank': 3,
                'isUser': false,
                'isOpen': true,
              };

        // Remaining runners (Rank 4+)
        final restUsers = <Map<String, dynamic>>[];
        for (int i = 3; i < allUsers.length; i++) {
          restUsers.add({
            ...allUsers[i],
            'rank': i + 1,
          });
        }

        final bool hasAnyParticipants = allUsers.isNotEmpty;

        return Scaffold(
          backgroundColor: GelatoTheme.bg,
          appBar: AppBar(
            title: const Text(
              'Leaderboard',
              style: TextStyle(
                color: GelatoTheme.textDark,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (hasPermissionError) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Showing your personal progress. To view all participants, update the /leaderboard rules in Firebase Console.',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF78350F),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Leaderboard Banner Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: GelatoTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.leaderboard_rounded,
                              color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly Challenge',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: GelatoTheme.textDark,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Earn points this week by logging meals, meeting goals, and recording weight!',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF78350F),
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              '⏱ Resets every Sunday midnight',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Empty State or Podium
                if (!hasAnyParticipants) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 36, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 1.5),
                      boxShadow: GelatoTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: const Icon(Icons.emoji_events_rounded,
                              color: Color(0xFFD97706), size: 36),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Be the First Champion!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: GelatoTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'No points recorded yet. Complete a daily meal log, risk assessment, or weigh-in to claim the top spot!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: GelatoTheme.textLight,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Top 3 Podium
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _PodiumItem(
                          user: secondPlace,
                          rank: 2,
                          color: GelatoTheme.blue,
                          height: 125,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PodiumItem(
                          user: firstPlace,
                          rank: 1,
                          color: GelatoTheme.yellow,
                          height: 160,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PodiumItem(
                          user: thirdPlace,
                          rank: 3,
                          color: GelatoTheme.orange,
                          height: 100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Leaderboard List (Rank 4+)
                  if (restUsers.isNotEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: GelatoTheme.cardShadow,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: restUsers.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: Colors.black.withValues(alpha: 0.08),
                        ),
                        itemBuilder: (context, index) {
                          final item = restUsers[index];
                          final int rank = item['rank'] as int;
                          final bool isUser = item['isUser'] as bool;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? const Color(0xFFEFF6FF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                  index == restUsers.length - 1 ? 18 : 0),
                            ),
                            child: Row(
                              children: [
                                // Rank Indicator
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '#$rank',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: GelatoTheme.textDark,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Name & Badges
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              item['name'] as String,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: isUser
                                                    ? FontWeight.w900
                                                    : FontWeight.w800,
                                                color: isUser
                                                    ? const Color(0xFF1D4ED8)
                                                    : GelatoTheme.textDark,
                                              ),
                                            ),
                                          ),
                                          if (isUser) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDBEAFE),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color:
                                                        const Color(0xFF3B82F6),
                                                    width: 1),
                                              ),
                                              child: const Text(
                                                'YOU',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFF1E40AF),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons
                                                  .local_fire_department_rounded,
                                              size: 13,
                                              color: GelatoTheme.orangeDark),
                                          const SizedBox(width: 3),
                                          Flexible(
                                            child: Text(
                                              '${item['badges']} badges',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: GelatoTheme.textLight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Points Score
                                Text(
                                  '${item['points']} pts',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: isUser
                                        ? const Color(0xFF1E40AF)
                                        : GelatoTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],

                // Highlighted user standing card if outside the top 3
                if (currentUserEntry != null && userRank > 3) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF3B82F6), width: 1.5),
                      boxShadow: GelatoTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3B82F6),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '#$userRank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Current Rank',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E40AF),
                                ),
                              ),
                              Text(
                                'Keep logging to break into the podium!',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: GelatoTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${currentUserEntry['points']} pts',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final int rank;
  final Color color;
  final double height;

  const _PodiumItem({
    required this.user,
    required this.rank,
    required this.color,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOpen = user['isOpen'] == true;
    final bool isFirst = rank == 1;
    final bool isUser = user['isUser'] == true;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(height: 14),
        // Avatar
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isFirst ? 60 : 50,
              height: isFirst ? 60 : 50,
              decoration: BoxDecoration(
                color: isOpen
                    ? const Color(0xFFF1F5F9)
                    : (isUser ? const Color(0xFFEFF6FF) : Colors.white),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isOpen
                      ? const Color(0xFFCBD5E1)
                      : (isUser ? const Color(0xFF1D4ED8) : Colors.black),
                  width: isUser ? 3 : 2,
                ),
                boxShadow: isOpen
                    ? null
                    : [
                        BoxShadow(
                          color: isUser
                              ? const Color(0xFF1D4ED8).withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.15),
                          offset: isUser
                              ? const Offset(0, 4)
                              : const Offset(2, 2),
                          blurRadius: isUser ? 8 : 0,
                        ),
                      ],
              ),
              child: Center(
                child: isOpen
                    ? Icon(
                        Icons.person_add_rounded,
                        size: isFirst ? 26 : 22,
                        color: const Color(0xFF94A3B8),
                      )
                    : Text(
                        ((user['name'] as String?)?.trim().isNotEmpty ?? false)
                            ? (user['name'] as String).trim()[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          fontSize: isFirst ? 24 : 20,
                          fontWeight: FontWeight.w900,
                          color: isUser
                              ? const Color(0xFF1D4ED8)
                              : GelatoTheme.textDark,
                        ),
                      ),
              ),
            ),
            if (isUser && !isOpen)
              Positioned(
                top: -12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE68A),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: const Color(0xFFD97706), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: const Text(
                    'YOU',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Podium Box
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: isOpen ? const Color(0xFFF8FAFC) : color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: isOpen
                  ? const Color(0xFFCBD5E1)
                  : (isUser ? const Color(0xFF1D4ED8) : Colors.black),
              width: isUser ? 3 : 2,
            ),
            boxShadow: isOpen
                ? null
                : [
                    BoxShadow(
                      color: isUser
                          ? const Color(0xFF1D4ED8).withValues(alpha: 0.5)
                          : Colors.black,
                      offset: const Offset(0, 4),
                      blurRadius: isUser ? 10 : 0,
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    rank == 1 ? '1st' : (rank == 2 ? '2nd' : '3rd'),
                    style: TextStyle(
                      fontSize: isUser ? 24 : 20,
                      fontWeight: FontWeight.w900,
                      color: isOpen
                          ? const Color(0xFF94A3B8)
                          : (isUser ? const Color(0xFF1E40AF) : Colors.black),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOpen ? 'Open Spot' : (user['name'] as String? ?? 'User'),
                    style: TextStyle(
                      fontSize: isUser ? 16 : 14,
                      fontWeight: FontWeight.w900,
                      color: isOpen
                          ? const Color(0xFF94A3B8)
                          : (isUser ? const Color(0xFF1E40AF) : Colors.black87),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOpen ? '—' : '${user['points']} pts',
                    style: TextStyle(
                      fontSize: isUser ? 14 : 12,
                      fontWeight: FontWeight.w900,
                      color: isOpen
                          ? const Color(0xFFCBD5E1)
                          : (isUser ? const Color(0xFF1D4ED8) : Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
