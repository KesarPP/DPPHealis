import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'handouts_screen.dart';
import '../data/handouts_data.dart';
import 'journey_screen.dart';

import '../data/gelato_theme.dart';

// Pastel Color Palette "GELATO DAYS" mapped to GelatoTheme
const Color _pastelGreen = GelatoTheme.green;
const Color _pastelBlue = GelatoTheme.blue;
const Color _pastelPeach = GelatoTheme.orange;
const Color _darkText = GelatoTheme.textDark;

const Color _greenDark = GelatoTheme.greenDark;
const Color _blueDark = GelatoTheme.blueDark;
const Color _peachDark = GelatoTheme.orangeDark;

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.blue.withValues(alpha: 0.3),
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
      body: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            const Positioned.fill(
              child: DottedGridBackground(),
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
          ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/session_header.jpg',
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
            color: _peachDark, size: 24), // orange
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
            color: _greenDark, size: 24), // green
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
            color: _blueDark, size: 24), // blue
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
        color: GelatoTheme.purple,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 2.0),
        boxShadow: [
          BoxShadow(
              color: GelatoTheme.purple.withValues(alpha: 0.6),
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
                      color: Colors.black,
                      letterSpacing: -0.8)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('In Progress',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.black)),
              )
            ],
          ),
          const SizedBox(height: 2),
          Text('Session 6',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.black.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          // Upgraded Pill-styled gradient progress bar
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.45),
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
                        colors: [Colors.white, GelatoTheme.purple],
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.white.withValues(alpha: 0.3),
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
                  fontSize: 14, color: Colors.black, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildCurrentSessionCard() {
    return Container(
      padding: const EdgeInsets.all(20), // Increased padding
      decoration: BoxDecoration(
        color: GelatoTheme.blue,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 2.0),
        boxShadow: [
          BoxShadow(
              color: GelatoTheme.blue.withValues(alpha: 0.6),
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
                color: Colors.black.withValues(alpha: 0.7),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0),
          ),
          const SizedBox(height: 4),
          const Text(
            'Being Active as a Way of Life',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black,
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
                      darkColor: _peachDark,
                      onTap: () {})),
              const SizedBox(width: 12),
              Expanded(
                  child: _ActionButton(
                      icon: Icons.quiz_rounded,
                      label: 'Take Quiz',
                      color: _pastelGreen,
                      darkColor: _greenDark,
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
        color: color,
        borderRadius: BorderRadius.circular(20), // Increased radius
        border:
            Border.all(color: Colors.black87, width: 1.5), // Thin black border
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
              color: Colors.white.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black87, width: 1.2),
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
  final Color darkColor;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.color,
      required this.darkColor}); //

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
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black87, width: 1.0),
          ),
          child: Icon(icon, size: 16, color: darkColor),
        ),
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
                color: Colors.black87, width: 1.5), // Thin black edge
          ),
          elevation: 0, // Handled by Container box shadow
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Subtle Dotted Grid Background
// ══════════════════════════════════════════════════════════════

class DottedGridBackground extends StatelessWidget {
  const DottedGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedGridPainter(),
    );
  }
}

class _DottedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.18) // subtle slate dots
      ..style = PaintingStyle.fill;

    const double spacing = 18.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.9, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
