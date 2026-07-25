import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> leaderboardData = [
      {'rank': 1, 'name': 'Claire', 'points': '1,450 pts', 'badges': 6, 'isUser': false},
      {'rank': 2, 'name': 'You', 'points': '1,280 pts', 'badges': 5, 'isUser': true},
      {'rank': 3, 'name': 'Evander', 'points': '1,120 pts', 'badges': 4, 'isUser': false},
      {'rank': 4, 'name': 'Kenton', 'points': '980 pts', 'badges': 3, 'isUser': false},
      {'rank': 5, 'name': 'Zackary R.', 'points': '850 pts', 'badges': 3, 'isUser': false},
      {'rank': 6, 'name': 'Brittny B.', 'points': '720 pts', 'badges': 2, 'isUser': false},
      {'rank': 7, 'name': 'Krysta K.', 'points': '540 pts', 'badges': 1, 'isUser': false},
    ];

    final top3 = leaderboardData.take(3).toList();
    final rest = leaderboardData.skip(3).toList();

    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        title: const Text(
          'Weekly Challenge',
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
            // Leaderboard Header Card
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
                      child: Icon(Icons.leaderboard_rounded, color: Colors.white, size: 28),
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
                          'Earn points by logging meals, completing weekly assessments, and recording your weight!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF78350F),
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '⏱ Resets every Sunday',
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
            const SizedBox(height: 16),
            const SizedBox(height: 8),

            // Podium Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _PodiumItem(
                    user: top3[1], 
                    rank: 2, 
                    color: GelatoTheme.blue, 
                    height: 120,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PodiumItem(
                    user: top3[0], 
                    rank: 1, 
                    color: GelatoTheme.yellow, 
                    height: 160,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PodiumItem(
                    user: top3[2], 
                    rank: 3, 
                    color: GelatoTheme.orange, 
                    height: 90,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Leaderboard List (Rank 4+)
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
                itemCount: rest.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.black.withValues(alpha: 0.08),
                ),
                itemBuilder: (context, index) {
                  final item = rest[index];
                  final int rank = item['rank'] as int;
                  final bool isUser = item['isUser'] as bool;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFEFF6FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                          index == rest.length - 1 ? 18 : 0),
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
                              color: Colors.black.withValues(alpha: 0.2),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item['name'] as String,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isUser ? FontWeight.w900 : FontWeight.w800,
                                      color: isUser ? const Color(0xFF1D4ED8) : GelatoTheme.textDark,
                                    ),
                                  ),
                                  if (isUser) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDBEAFE),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFF3B82F6), width: 1),
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
                                  const Icon(Icons.local_fire_department_rounded, size: 13, color: GelatoTheme.orangeDark),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${item['badges']} active badges',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: GelatoTheme.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Points Score
                        Text(
                          item['points'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isUser ? const Color(0xFF1E40AF) : GelatoTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
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
    required this.height
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = rank == 1;
    final isUser = user['isUser'] == true;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isFirst ? 60 : 50,
              height: isFirst ? 60 : 50,
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFFEFF6FF) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUser ? const Color(0xFF1D4ED8) : Colors.black, 
                  width: isUser ? 3 : 2
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser ? const Color(0xFF1D4ED8).withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.15), 
                    offset: isUser ? const Offset(0, 4) : const Offset(2, 2),
                    blurRadius: isUser ? 8 : 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  (user['name'] as String).substring(0, 1),
                  style: TextStyle(
                    fontSize: isFirst ? 24 : 20,
                    fontWeight: FontWeight.w900,
                    color: isUser ? const Color(0xFF1D4ED8) : GelatoTheme.textDark,
                  ),
                ),
              ),
            ),
            if (isUser)
              Positioned(
                top: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE68A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD97706), width: 1.5),
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
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: isUser ? const Color(0xFF1D4ED8) : Colors.black, 
              width: isUser ? 3 : 2
            ),
            boxShadow: [
              BoxShadow(
                color: isUser ? const Color(0xFF1D4ED8).withValues(alpha: 0.5) : Colors.black, 
                offset: const Offset(0, 4), // Only bottom shadow so it doesn't look weird on sides
                blurRadius: isUser ? 10 : 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${rank == 1 ? '1st' : rank == 2 ? '2nd' : '3rd'}',
                style: TextStyle(
                  fontSize: isUser ? 24 : 20,
                  fontWeight: FontWeight.w900,
                  color: isUser ? const Color(0xFF1E40AF) : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  user['name'],
                  style: TextStyle(
                    fontSize: isUser ? 16 : 14,
                    fontWeight: FontWeight.w900,
                    color: isUser ? const Color(0xFF1E40AF) : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user['points'].toString().split(' ')[0], // '1,450'
                style: TextStyle(
                  fontSize: isUser ? 14 : 12,
                  fontWeight: FontWeight.w900,
                  color: isUser ? const Color(0xFF1D4ED8) : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
