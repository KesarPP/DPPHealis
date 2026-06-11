import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'handouts_screen.dart';
import '../data/handouts_data.dart';
import 'journey_screen.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  static const Color _teal   = Color(0xFF00897B);
  static const Color _tealBg = Color(0xFFE0F2F1);
  static const Color _navy   = Color(0xFF1A3A5C);
  static const Color _grey   = Color(0xFF78909C);
  static const Color _pageBg = Color(0xFFEAF2F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF7B1FA2), // 🟣 purple
        icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        label: const Text('Ask AI Coach',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _navy),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'DPP Journey',
          style: TextStyle(color: _navy, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotsPainter(color: const Color(0xFF1A3A5C).withValues(alpha: 0.06)),
            ),
          ),
          ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          _buildHeroBanner(),
          const SizedBox(height: 20),
          const _SectionLabel('Resource Library'),
          const SizedBox(height: 10),
          _buildResourceLibrary(context),
          const SizedBox(height: 20),
          _buildPhaseCard(),
          const SizedBox(height: 20),
          const _SectionLabel('Current Session'),
          const SizedBox(height: 10),
          _buildCurrentSessionCard(),
          const SizedBox(height: 20),
          const _SectionLabel('Session Timeline'),
          const SizedBox(height: 12),
          const JourneyMap(),
          const SizedBox(height: 32),
        ],
      ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/session_header.png',
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildResourceLibrary(BuildContext context) {
    final List<(Widget, String, Color, VoidCallback)> resources = [ // 👈 added Color
      (
      FaIcon(FontAwesomeIcons.utensils, color: const Color(0xFFFF7043), size: 24), // 🟠 orange
      'Food\nHandouts',
      const Color(0xFFFF7043),
          () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const HandoutsScreen(title: 'Food Handouts', handouts: foodHandouts)))
      ),
      (
      FaIcon(FontAwesomeIcons.personWalking, color: const Color(0xFF43A047), size: 24), // 🟢 green
      'Activity\nHandouts',
      const Color(0xFF43A047),
          () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const HandoutsScreen(title: 'Activity Handouts', handouts: activityHandouts)))
      ),
      (
      FaIcon(FontAwesomeIcons.bookOpen, color: const Color(0xFF1E88E5), size: 24), // 🔵 blue
      'NDPP\nHandouts',
      const Color(0xFF1E88E5),
          () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const HandoutsScreen(title: 'NDPP Handouts', handouts: ndppHandouts)))
      ),
    ];
    return Row(
      children: resources
          .map((r) => Expanded(
        child: GestureDetector(
          onTap: r.$4, // 👈 was $3, now $4
          child: _ResourceTile(icon: r.$1, label: r.$2, color: r.$3), // 👈 pass color
        ),
      ))
          .toList(),
    );
  }

  Widget _buildPhaseCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A5C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Module 2',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)), // 👈 white text
          const SizedBox(height: 2),
          const Text('Session 6',
              style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)), // 👈
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.68,
              minHeight: 8,
              backgroundColor: Colors.white30, // 👈
              color: const Color(0xFFFF7043), // 🟠 orange progress bar
            ),
          ),
          const SizedBox(height: 6),
          const Text('68% Completed',
              style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)), // 👈
        ],
      ),
    );
  }



  Widget _buildCurrentSessionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session 6',
            style: TextStyle(fontSize: 11, color: _grey, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          const Text(
            'Being Active as a Way of Life',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _navy),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ActionButton(icon: Icons.play_circle_fill_rounded, label: 'Watch Video', color: const Color(0xFFFF7043), onTap: () {})),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(icon: Icons.quiz_rounded, label: 'Take Quiz', color: const Color(0xFF43A047), onTap: () {})),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Section label
// ══════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A3A5C)));
  }
}

// ══════════════════════════════════════════════════════════════
// Resource tile
// ══════════════════════════════════════════════════════════════

class _ResourceTile extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color; // 👈 added
  const _ResourceTile({required this.icon, required this.label, required this.color}); // 👈

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15), // 👈 dynamic tinted bg
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C), height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
// ══════════════════════════════════════════════════════════════
// Buttons
// ══════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;  // 👈 added
  const _ActionButton({required this.icon, required this.label, required this.onTap, required this.color});  // 👈

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,  // 👈 dynamic now
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}

class _CoachButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CoachButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
      label: const Text('Ask Session Coach',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
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
