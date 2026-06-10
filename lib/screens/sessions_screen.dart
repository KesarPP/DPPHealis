import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'handouts_screen.dart';
import '../data/handouts_data.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  static const Color _teal   = Color(0xFF00897B);
  static const Color _tealBg = Color(0xFFE0F2F1);
  static const Color _navy   = Color(0xFF1A3A5C);
  static const Color _grey   = Color(0xFF78909C);
  static const Color _pageBg = Color(0xFFF5F5F5);

  static const List<_SessionData> _sessions = [
    _SessionData(1, 'Completed',       null,                         null,                     true,  false, false),
    _SessionData(2, 'Completed',       'Unlocked Food Tracking',     Icons.apple,              true,  false, false),
    _SessionData(3, 'Completed',       'Unlocked Recipe Making',     Icons.menu_book_outlined, true,  false, false),
    _SessionData(4, 'Completed',       'Unlocked Barcode Scanner',   Icons.barcode_reader,     true,  false, false),
    _SessionData(5, 'Completed',       'Unlocked Activity Tracking', Icons.directions_run,     true,  false, false),
    _SessionData(6, 'Current Session', 'Unlocked Exercise Handbook', Icons.menu_book_outlined, false, true,  false),
    _SessionData(7, 'Locked',          null,                         null,                     false, false, true),
    _SessionData(8, 'Locked',          null,                         null,                     false, false, true),
  ];

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
          _buildTimeline(),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _tealBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phase 2',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: _navy)),
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

  Widget _buildTimeline() {
    return Column(
      children: List.generate(_sessions.length, (i) {
        return _TimelineRow(session: _sessions[i], isLast: i == _sessions.length - 1);
      }),
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
// Session data model
// ══════════════════════════════════════════════════════════════

class _SessionData {
  final int number;
  final String status;
  final String? unlockLabel;
  final IconData? unlockIcon;
  final bool completed;
  final bool current;
  final bool locked;

  const _SessionData(
      this.number, this.status, this.unlockLabel, this.unlockIcon,
      this.completed, this.current, this.locked,
      );
}

// ══════════════════════════════════════════════════════════════
// Timeline row
// ══════════════════════════════════════════════════════════════

class _TimelineRow extends StatelessWidget {
  final _SessionData session;
  final bool isLast;
  const _TimelineRow({required this.session, required this.isLast});

  static const _teal   = Color(0xFF00897B);
  static const _locked = Color(0xFFB0BEC5);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _buildDot(),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: session.completed ? _teal : _locked),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session ${session.number}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C))),
                      const SizedBox(height: 2),
                      Text(
                        session.status,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: (session.completed || session.current) ? _teal : _locked,
                        ),
                      ),
                      if (session.unlockLabel != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(session.unlockIcon, size: 14, color: const Color(0xFF546E7A)),
                            const SizedBox(width: 4),
                            Text(session.unlockLabel!,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF546E7A), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (session.current)
                    Positioned(
                      right: 0, top: -4,
                      child: Transform.rotate(
                        angle: 0.52,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'START\nHERE',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, height: 1.2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    if (session.completed) {
      return Container(
        width: 30, height: 30,
        decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.white, size: 18),
      );
    }
    if (session.current) {
      return Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: Colors.white, shape: BoxShape.circle,
          border: Border.all(color: _teal, width: 3),
          boxShadow: [BoxShadow(color: _teal.withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 2)],
        ),
        child: const Icon(Icons.play_arrow_rounded, color: _teal, size: 20),
      );
    }
    return Container(
      width: 30, height: 30,
      decoration: BoxDecoration(
        color: Colors.white, shape: BoxShape.circle,
        border: Border.all(color: _locked, width: 2),
      ),
      child: const Icon(Icons.lock_outline, color: _locked, size: 16),
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
