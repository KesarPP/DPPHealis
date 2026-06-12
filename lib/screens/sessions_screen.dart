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
const Color _darkText = Color(0xFF2E3A59);

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.lerp(_pastelBlue, Colors.white, 0.85), // Soft pastel wash
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [_pastelGreen, _pastelBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: _pastelBlue.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 8)),
          ],
          border: Border.all(
              color: Colors.black87, width: 0.5), // Thin black border
        ),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.transparent, // Handled by container gradient
          elevation: 0,
          highlightElevation: 0,
          hoverElevation: 0,
          focusElevation: 0,
          icon: const Icon(Icons.auto_awesome_rounded, color: _darkText),
          label: const Text('Ask AI Coach',
              style: TextStyle(
                  color: _darkText,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: -0.5)),
        ),
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
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter:
                  _DotsPainter(color: Colors.black87.withValues(alpha: 0.04)),
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
    final List<(Widget, String, Color, VoidCallback)> resources = [
      // added Color
      (
        const FaIcon(FontAwesomeIcons.utensils,
            color: _darkText, size: 24), // orange
        'Food\nHandouts',
        _pastelPeach,
        () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const HandoutsScreen(
                    title: 'Food Handouts', handouts: foodHandouts)))
      ),
      (
        const FaIcon(FontAwesomeIcons.personWalking,
            color: _darkText, size: 24), // green
        'Activity\nHandouts',
        _pastelGreen,
        () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const HandoutsScreen(
                    title: 'Activity Handouts', handouts: activityHandouts)))
      ),
      (
        const FaIcon(FontAwesomeIcons.bookOpen,
            color: _darkText, size: 24), // blue
        'NDPP\nHandouts',
        _pastelBlue,
        () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const HandoutsScreen(
                    title: 'NDPP Handouts', handouts: ndppHandouts)))
      ),
    ];
    return Row(
      children: resources
          .map((r) => Expanded(
                child: GestureDetector(
                  onTap: r.$4, // was $3, now $4
                  child: _ResourceTile(
                      icon: r.$1, label: r.$2, color: r.$3), // pass color
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPhaseCard() {
    return Container(
      padding: const EdgeInsets.all(20), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85), // Frosted white effect
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: _pastelPurple.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Module 2',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _darkText,
                      letterSpacing: -0.8)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _pastelPurple,
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('In Progress',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _darkText)),
              )
            ],
          ),
          const SizedBox(height: 2),
          Text('Session 6',
              style: TextStyle(
                  fontSize: 15,
                  color: _darkText.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          // Upgraded Pill-styled gradient progress bar
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.68,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [_pastelBlue, _pastelPurple],
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: _pastelPurple.withValues(alpha: 0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('68% Completed',
              style: TextStyle(
                  fontSize: 14, color: _darkText, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildCurrentSessionCard() {
    return Container(
      padding: const EdgeInsets.all(20), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: _pastelBlue.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SESSION 6',
            style: TextStyle(
                fontSize: 12,
                color: _darkText.withValues(alpha: 0.6),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0),
          ),
          const SizedBox(height: 4),
          const Text(
            'Being Active as a Way of Life',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _darkText,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _ActionButton(
                      icon: Icons.play_circle_fill_rounded,
                      label: 'Watch Video',
                      color: _pastelPeach,
                      onTap: () {})),
              const SizedBox(width: 12),
              Expanded(
                  child: _ActionButton(
                      icon: Icons.quiz_rounded,
                      label: 'Take Quiz',
                      color: _pastelGreen,
                      onTap: () {})),
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
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _darkText,
            letterSpacing: -0.5));
  }
}

// ══════════════════════════════════════════════════════════════
// Resource tile
// ══════════════════════════════════════════════════════════════

class _ResourceTile extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color color; // added
  const _ResourceTile(
      {required this.icon, required this.label, required this.color}); //

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(
          vertical: 20, horizontal: 8), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Increased radius
        border:
            Border.all(color: Colors.black87, width: 0.5), // Thin black border
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8)), // Soft Neumorphic wide shadow
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, // Slightly larger icon container
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // Soft gradient icon background
                colors: [
                  color.withValues(alpha: 0.6),
                  color.withValues(alpha: 0.2)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _darkText,
              height: 1.2,
              letterSpacing: -0.3,
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
  final Color color; // added
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.color}); //

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: _darkText),
        label: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: _darkText,
                letterSpacing: -0.3)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // dynamic now
          foregroundColor: _darkText,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
                color: Colors.black87, width: 0.5), // Thin black edge
          ),
          elevation: 0, // Handled by Container box shadow
        ),
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
      icon: const Icon(Icons.auto_awesome_rounded,
          size: 16, color: Colors.black87),
      label: const Text('Ask Session Coach',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.black87)),
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
  bool shouldRepaint(covariant _DotsPainter oldDelegate) =>
      oldDelegate.color != color;
}
