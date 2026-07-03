import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../services/achievements_service.dart';
import '../services/activity_metrics_engine.dart';
import '../widgets/dashboard_achievements.dart';
import '../widgets/food_achievements_widget.dart';
import '../widgets/dashboard_momentum.dart';

class TrophyCollectionScreen extends StatelessWidget {
  const TrophyCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: GelatoTheme.bg,
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_rounded, color: GelatoTheme.orangeDark, size: 28),
              SizedBox(width: 8),
              Text(
                'Trophy Collection',
                style: TextStyle(
                  color: GelatoTheme.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: GelatoTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: GelatoTheme.textDark,
            unselectedLabelColor: GelatoTheme.textLight,
            indicatorColor: GelatoTheme.orangeDark,
            indicatorWeight: 3.5,
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
            tabs: const [
              Tab(text: 'Achievements'),
              Tab(text: 'Weekly Leaderboard'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Achievements (contains all present cards: Program Badges, Food Badges, Momentum)
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  FutureBuilder<List<Achievement>>(
                    future: AchievementsService.getCachedAchievements(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(color: GelatoTheme.orangeDark),
                          ),
                        );
                      }
                      final list = snapshot.data ?? [];
                      return DashboardAchievements(achievements: list);
                    },
                  ),
                  const SizedBox(height: 16),
                  const FoodAchievementsWidget(),
                  const SizedBox(height: 16),
                  const DashboardMomentum(),
                ],
              ),
            ),
            // Tab 2: Weekly Leaderboard
            _buildWeeklyLeaderboardTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyLeaderboardTab() {
    final List<Map<String, dynamic>> leaderboardData = [
      {'rank': 1, 'name': 'Sarah K.', 'points': '1,450 pts', 'badges': 6, 'isUser': false},
      {'rank': 2, 'name': 'You', 'points': '1,280 pts', 'badges': 5, 'isUser': true},
      {'rank': 3, 'name': 'David M.', 'points': '1,120 pts', 'badges': 4, 'isUser': false},
      {'rank': 4, 'name': 'Elena R.', 'points': '980 pts', 'badges': 3, 'isUser': false},
      {'rank': 5, 'name': 'Marcus T.', 'points': '850 pts', 'badges': 3, 'isUser': false},
      {'rank': 6, 'name': 'Priya J.', 'points': '720 pts', 'badges': 2, 'isUser': false},
    ];

    return SingleChildScrollView(
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
                        'Weekly Champions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Compete with fellow members by completing missions and logging daily progress!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF78350F),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Leaderboard List
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
              itemCount: leaderboardData.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.black.withValues(alpha: 0.08),
              ),
              itemBuilder: (context, index) {
                final item = leaderboardData[index];
                final int rank = item['rank'] as int;
                final bool isUser = item['isUser'] as bool;

                Color? medalColor;
                IconData? medalIcon;
                if (rank == 1) {
                  medalColor = const Color(0xFFEAB308);
                  medalIcon = Icons.workspace_premium_rounded;
                } else if (rank == 2) {
                  medalColor = const Color(0xFF94A3B8);
                  medalIcon = Icons.workspace_premium_rounded;
                } else if (rank == 3) {
                  medalColor = const Color(0xFFD97706);
                  medalIcon = Icons.workspace_premium_rounded;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFFEFF6FF) : Colors.transparent,
                    borderRadius: BorderRadius.circular(rank == 1
                        ? 18
                        : (rank == leaderboardData.length ? 18 : 0)),
                  ),
                  child: Row(
                    children: [
                      // Rank Indicator
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: medalColor ?? const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: medalColor != null ? Colors.black : Colors.black.withValues(alpha: 0.2),
                            width: medalColor != null ? 1.2 : 1.0,
                          ),
                        ),
                        child: Center(
                          child: medalIcon != null
                              ? Icon(medalIcon, color: Colors.white, size: 18)
                              : Text(
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
        ],
      ),
    );
  }
}
