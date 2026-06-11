import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'handouts_screen.dart';
import '../data/handouts_data.dart';
import 'journey_screen.dart';

// Pastel Color Palette "GELATO DAYS"
const Color _pastelPink = Color(0xFFFFCBE1);
const Color _pastelGreen = Color(0xFFD6E5BD);
const Color _pastelYellow = Color(0xFFF9E1A8);
const Color _pastelBlue = Color(0xFFBCD8EC);
const Color _pastelPurple = Color(0xFFDCCCEC);
const Color _pastelPeach = Color(0xFFFFDAB4);

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pastelBlue.withValues(alpha: 0.3),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Color.lerp(_pastelBlue, Colors.black, 0.1)!, // slightly darker pastel blue
        icon: const Icon(Icons.auto_awesome_rounded, color: Colors.black87),
        label: const Text('Ask AI Coach',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'DPP Journey',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotsPainter(color: Colors.black87.withValues(alpha: 0.06)),
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
    final List<(Widget, String, Color, VoidCallback)> resources = [ // added Color
      (
      FaIcon(FontAwesomeIcons.utensils, color: Color.lerp(_pastelPeach, Colors.black, 0.4)!, size: 24), // orange
      'Food\nHandouts',
      _pastelPeach,
          () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const HandoutsScreen(title: 'Food Handouts', handouts: foodHandouts)))
      ),
      (
      FaIcon(FontAwesomeIcons.personWalking, color: Color.lerp(_pastelGreen, Colors.black, 0.4)!, size: 24), // green
      'Activity\nHandouts',
      _pastelGreen,
          () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const HandoutsScreen(title: 'Activity Handouts', handouts: activityHandouts)))
      ),
      (
      FaIcon(FontAwesomeIcons.bookOpen, color: Color.lerp(_pastelBlue, Colors.black, 0.4)!, size: 24), // blue
      'NDPP\nHandouts',
      _pastelBlue,
          () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const HandoutsScreen(title: 'NDPP Handouts', handouts: ndppHandouts)))
      ),
    ];
    return Row(
      children: resources
          .map((r) => Expanded(
        child: GestureDetector(
          onTap: r.$4, // was $3, now $4
          child: _ResourceTile(icon: r.$1, label: r.$2, color: r.$3), // pass color
        ),
      ))
          .toList(),
    );
  }

  Widget _buildPhaseCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _pastelBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: _pastelBlue.withValues(alpha: 0.5), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Module 2',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87)), // text
          const SizedBox(height: 2),
          const Text('Session 6',
              style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)), 
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.68,
              minHeight: 8,
              backgroundColor: Colors.black12, 
              color: Colors.white, // progress bar
            ),
          ),
          const SizedBox(height: 6),
          const Text('68% Completed',
              style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)), 
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session 6',
            style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          const Text(
            'Being Active as a Way of Life',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ActionButton(icon: Icons.play_circle_fill_rounded, label: 'Watch Video', color: _pastelPeach, onTap: () {})),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(icon: Icons.quiz_rounded, label: 'Take Quiz', color: _pastelGreen, onTap: () {})),
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
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87));
  }
}

// ══════════════════════════════════════════════════════════════
// Resource tile
// ══════════════════════════════════════════════════════════════

class _ResourceTile extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color; // added
  const _ResourceTile({required this.icon, required this.label, required this.color}); //

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.4), // tinted bg, increased opacity for visibility on pastel
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87, height: 1.3,
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
  final Color color;  // added
  const _ActionButton({required this.icon, required this.label, required this.onTap, required this.color});  //

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: Colors.black87),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,  // dynamic now
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        shadowColor: color.withValues(alpha: 0.5),
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
      icon: const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.black87),
      label: const Text('Ask Session Coach',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _pastelGreen,
        foregroundColor: Colors.black87,
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
