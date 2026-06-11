import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Very soft pastel lavender background
  static const Color _bgWarm = Color(0xFFF5EEFC);
  static const Color _navy = Color(0xFF1A3A5C);
  
  // Vibrant gamified palette
  static const Color _royalBlue = Color(0xFF2962FF);
  static const Color _purple = Color(0xFFAA00FF);
  static const Color _coral = Color(0xFFFF6D00);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWarm,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: _navy, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _ProfileHeader(),
            const SizedBox(height: 32),
            
            _SectionTitle('Journey Progress'),
            const SizedBox(height: 12),
            const _JourneyProgressCard(),
            const SizedBox(height: 32),

            _SectionTitle('Active Quests'),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: _GoalCard(
                  title: 'Weight Goal', 
                  target: 'Lose 10 kg', 
                  current: 'Current: 65 kg', 
                  progress: 0.4, 
                  icon: Icons.monitor_weight_rounded,
                  color: _royalBlue,
                  bgColor: Color(0xFFE8EAF6),
                )),
                SizedBox(width: 12),
                Expanded(child: _GoalCard(
                  title: 'Activity Goal', 
                  target: '150 min/wk', 
                  current: 'Current: 90 min', 
                  progress: 0.6, 
                  icon: Icons.directions_run_rounded,
                  color: _coral,
                  bgColor: Color(0xFFFFF3E0),
                )),
              ],
            ),
            const SizedBox(height: 32),

            _SectionTitle('Achievements'),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: _StatCard(title: 'Current Phase', value: 'Phase 1', icon: Icons.emoji_events_rounded, color: _royalBlue)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Sessions', value: '12 / 16', icon: Icons.menu_book_rounded, color: _purple)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Streak', value: '14 Days', icon: Icons.local_fire_department_rounded, color: _coral)),
              ],
            ),
            const SizedBox(height: 32),

            _SectionTitle('Journey Records'),
            const SizedBox(height: 12),
            const _HistorySection(),
            const SizedBox(height: 32),

            _SectionTitle('Settings'),
            const SizedBox(height: 12),
            const _SettingsSection(),
            const SizedBox(height: 32),

            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                  shadowColor: Colors.black12,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A3A5C), letterSpacing: -0.5),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFF6D00), width: 4), // Coral Orange Circle
          ),
          child: const CircleAvatar(
            radius: 56,
            backgroundColor: Color(0xFFFFF3E0),
            child: Icon(Icons.person_rounded, size: 56, color: Color(0xFFFF6D00)),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Janice Pattice',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1A3A5C), letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '🔥 On a 14-day winning streak!',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFFF6D00)),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () {},
          icon: const Icon(Icons.edit_rounded, size: 16),
          label: const Text('Edit Profile'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE8EAF6),
            foregroundColor: const Color(0xFF2962FF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final String target;
  final String current;
  final double progress;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _GoalCard({required this.title, required this.target, required this.current, required this.progress, required this.icon, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5))),
            ],
          ),
          const SizedBox(height: 16),
          Text(target, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C))),
          const SizedBox(height: 4),
          Text(current, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF546E7A))),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white70)),
        ],
      ),
    );
  }
}

class _JourneyProgressCard extends StatelessWidget {
  const _JourneyProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Purple tint
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFAA00FF).withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overall Journey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFAA00FF), letterSpacing: -0.5)),
                  SizedBox(height: 4),
                  Text('12 of 17 milestones', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFAA00FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('68%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 0.68,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFAA00FF)),
                  minHeight: 16,
                ),
              ),
              Positioned(
                right: MediaQuery.of(context).size.width * 0.32 - 40, // rough position
                top: -10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star_rounded, color: Color(0xFFFF6D00), size: 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection();

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _ActionTile(icon: Icons.show_chart_rounded, title: 'Weight Journey', color: const Color(0xFF2962FF)),
          const Divider(height: 1, color: Colors.black12, indent: 60),
          _ActionTile(icon: Icons.science_rounded, title: 'Lab Results', color: const Color(0xFFAA00FF)),
          const Divider(height: 1, color: Colors.black12, indent: 60),
          _ActionTile(icon: Icons.fact_check_rounded, title: 'Risk Assessments', color: const Color(0xFFFF6D00)),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF546E7A), size: 20),
            ),
            title: const Text('Notifications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C))),
            trailing: Switch(value: true, onChanged: (v) {}, activeColor: const Color(0xFF2962FF)),
          ),
          const Divider(height: 1, color: Colors.black12, indent: 60),
          _ActionTile(icon: Icons.privacy_tip_rounded, title: 'Privacy', color: const Color(0xFF546E7A)),
          const Divider(height: 1, color: Colors.black12, indent: 60),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.language_rounded, color: Color(0xFF546E7A), size: 20),
            ),
            title: const Text('Language', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C))),
            trailing: const Text('English 🇺🇸', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF78909C))),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _ActionTile({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C))),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFB0BEC5)),
      onTap: () {},
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _WhiteCard({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}
