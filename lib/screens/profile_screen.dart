import 'package:flutter/material.dart';
import 'login_screen.dart';

// Pastel Color Palette "GELATO DAYS"
const Color _pastelPink = Color(0xFFFFCBE1);
const Color _pastelGreen = Color(0xFFD6E5BD);
const Color _pastelYellow = Color(0xFFF9E1A8);
const Color _pastelBlue = Color(0xFFBCD8EC);
const Color _pastelPurple = Color(0xFFDCCCEC);
const Color _pastelPeach = Color(0xFFFFDAB4);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pastelPink.withValues(alpha: 0.3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotsPainter(color: Colors.black87.withValues(alpha: 0.04)),
            ),
          ),
          SingleChildScrollView(
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
                  color: _pastelBlue,
                  bgColor: _pastelBlue,
                )),
                SizedBox(width: 12),
                Expanded(child: _GoalCard(
                  title: 'Activity Goal', 
                  target: '150 min/wk', 
                  current: 'Current: 90 min', 
                  progress: 0.6, 
                  icon: Icons.directions_run_rounded,
                  color: _pastelPeach,
                  bgColor: _pastelYellow,
                )),
              ],
            ),
            const SizedBox(height: 32),

            _SectionTitle('Achievements'),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: _StatCard(title: 'Current Phase', value: 'Phase 1', icon: Icons.emoji_events_rounded, color: _pastelBlue)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Sessions', value: '12 / 16', icon: Icons.menu_book_rounded, color: _pastelPurple)),
                SizedBox(width: 12),
                Expanded(child: _StatCard(title: 'Streak', value: '14 Days', icon: Icons.local_fire_department_rounded, color: _pastelPeach)),
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
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  shadowColor: Colors.redAccent.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color color;
  const _DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double gridSize = 16.0;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    for (double x = 0; x <= size.width; x += gridSize) {
      for (double y = 0; y <= size.height; y += gridSize) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) => oldDelegate.color != color;
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5),
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
            border: Border.all(color: _pastelPeach, width: 4), // Coral Orange Circle
          ),
          child: const CircleAvatar(
            radius: 56,
            backgroundColor: _pastelYellow,
            child: Icon(Icons.person_rounded, size: 56, color: _pastelPeach),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Janice Pattice',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _pastelYellow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'On a 14-day winning streak!',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () {},
          icon: const Icon(Icons.edit_rounded, size: 16),
          label: const Text('Edit Profile'),
          style: FilledButton.styleFrom(
            backgroundColor: _pastelBlue,
            foregroundColor: Colors.black87,
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
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 22, shadows: const [Shadow(color: Colors.black26, blurRadius: 4)]),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5, shadows: [Shadow(color: Colors.black26, blurRadius: 4)]))),
            ],
          ),
          const SizedBox(height: 16),
          Text(target, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 4)])),
          const SizedBox(height: 4),
          Text(current, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(color == _pastelBlue ? _pastelPeach : _pastelBlue),
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
          BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 12, offset: const Offset(0, 6)),
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
            child: Icon(icon, color: Colors.white, size: 28, shadows: const [Shadow(color: Colors.black26, blurRadius: 4)]),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5, shadows: [Shadow(color: Colors.black26, blurRadius: 4)])),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, shadows: [Shadow(color: Colors.black26, blurRadius: 2)])),
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
        color: _pastelPurple, // Purple tint
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _pastelPurple.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(color: _pastelPurple.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8)),
        ],
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
                  Text('Overall Journey', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5)),
                  SizedBox(height: 4),
                  Text('12 of 17 milestones', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _pastelPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('68%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),
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
                  backgroundColor: Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                  child: const Icon(Icons.star_rounded, color: _pastelPeach, size: 24),
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
          _ActionTile(icon: Icons.show_chart_rounded, title: 'Weight Journey', color: _pastelBlue),
          const Divider(height: 1, color: Colors.black12, indent: 60),
          _ActionTile(icon: Icons.science_rounded, title: 'Lab Results', color: _pastelPurple),
          const Divider(height: 1, color: Colors.black12, indent: 60),
          _ActionTile(icon: Icons.fact_check_rounded, title: 'Risk Assessments', color: _pastelPeach),
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
              decoration: BoxDecoration(color: _pastelGreen, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.notifications_active_rounded, color: Colors.black54, size: 20),
            ),
            title: const Text('Notifications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
            trailing: Switch(value: true, onChanged: (v) {}, activeColor: _pastelBlue),
          ),
          const Divider(height: 1, color: Colors.black12, indent: 60),
          const _ActionTile(icon: Icons.privacy_tip_rounded, title: 'Privacy', color: Colors.black54),
          const Divider(height: 1, color: Colors.black12, indent: 60),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _pastelGreen, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.language_rounded, color: Colors.black54, size: 20),
            ),
            title: const Text('Language', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
            trailing: const Text('English', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black54)),
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
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black54),
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
