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
  static const Color _pageBg = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
      body: ListView(
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
          const _SectionLabel('Session Timeline'),
          const SizedBox(height: 12),
          const JourneyMap(),
          const SizedBox(height: 20),
          const _SectionLabel('Current Session Card'),
          const SizedBox(height: 10),
          _buildCurrentSessionCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/Session_Header.png',
        width: double.infinity,
        height: 200,
        fit: BoxFit.fitWidth,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildResourceLibrary(BuildContext context) {
    final List<(Widget, String, VoidCallback)> resources = [
      (
      const FaIcon(FontAwesomeIcons.utensils, color: Color(0xFF00897B), size: 24),
      'Food\nHandouts',
          () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const HandoutsScreen(title: 'Food Handouts', handouts: foodHandouts)))
      ),
      (
      const FaIcon(FontAwesomeIcons.personWalking, color: Color(0xFF00897B), size: 24),
      'Activity\nHandouts',
          () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const HandoutsScreen(title: 'Activity Handouts', handouts: activityHandouts)))
      ),
      (
      const FaIcon(FontAwesomeIcons.bookOpen, color: Color(0xFF00897B), size: 24),
      'NDPP\nHandouts',
          () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => const HandoutsScreen(title: 'NDPP Handouts', handouts: ndppHandouts)))
      ),
    ];
    return Row(
      children: resources
          .map((r) => Expanded(
        child: GestureDetector(
          onTap: r.$3,
          child: _ResourceTile(icon: r.$1, label: r.$2),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildPhaseCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _tealBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phase 2',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _navy)),
          const SizedBox(height: 2),
          const Text('Session 6',
              style: TextStyle(fontSize: 14, color: _grey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.68,
              minHeight: 8,
              backgroundColor: Colors.white,
              color: _teal,
            ),
          ),
          const SizedBox(height: 6),
          const Text('68% Completed',
              style: TextStyle(fontSize: 13, color: _grey, fontWeight: FontWeight.w500)),
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
          Row(
            children: [
              Expanded(child: _ActionButton(icon: Icons.play_circle_fill_rounded, label: 'Watch Video', onTap: () {})),
              const SizedBox(width: 10),
              Expanded(child: _ActionButton(icon: Icons.quiz_rounded, label: 'Take Quiz', onTap: () {})),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Summary tasks for\nSession 6',
                  style: TextStyle(fontSize: 13, color: _grey, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 10),
              _CoachButton(onTap: () {}),
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
  final Widget icon;  // new
  final String label;
  const _ResourceTile({required this.icon, required this.label});

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
            decoration: const BoxDecoration(color: Color(0xFFE0F2F1), shape: BoxShape.circle),
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
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00897B),
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

