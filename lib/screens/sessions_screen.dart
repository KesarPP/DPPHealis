import 'dart:math' as math;
import 'package:flutter/material.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  static const Color _teal   = Color(0xFF00897B);
  static const Color _tealBg = Color(0xFFE0F2F1);
  static const Color _navy   = Color(0xFF1A3A5C);
  static const Color _grey   = Color(0xFF78909C);
  static const Color _locked = Color(0xFFB0BEC5);
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
          _buildResourceLibrary(),
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
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF4DB6AC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(painter: _HillsPainter()),
            ),
          ),
          Positioned(top: 14, left: 80,  child: _Cloud(width: 48, height: 18, opacity: 0.35)),
          Positioned(top: 22, left: 140, child: _Cloud(width: 32, height: 14, opacity: 0.25)),
          Positioned(top: 12, right: 52, child: const _SunWidget()),
          Positioned(bottom: 38, right: 90,  child: const _Tree(height: 28)),
          Positioned(bottom: 42, right: 110, child: const _Tree(height: 22)),
          Positioned(bottom: 16, right: 20,  child: const _WalkingPerson()),
          const Positioned(
            left: 20, top: 24,
            child: SizedBox(
              width: 190,
              child: Text(
                'Welcome to your\nDiabetes Prevention\nJourney',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceLibrary() {
    const resources = [
      (Icons.apple,          'Food\nHandouts'),
      (Icons.directions_run, 'Activity\nHandouts'),
      (Icons.language,       'NDPP\nHandouts'),
    ];
    return Row(
      children: resources
          .map((r) => Expanded(child: _ResourceTile(icon: r.$1, label: r.$2)))
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
            child: LinearProgressIndicator(
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
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
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
  final IconData icon;
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(color: Color(0xFFE0F2F1), shape: BoxShape.circle),
            child: Icon(icon, size: 26, color: const Color(0xFF00897B)),
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
          boxShadow: [BoxShadow(color: _teal.withOpacity(0.35), blurRadius: 10, spreadRadius: 2)],
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

// ══════════════════════════════════════════════════════════════
// Hero banner painters & widgets
// ══════════════════════════════════════════════════════════════

class _HillsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintFar  = Paint()..color = const Color(0xFF4DB6AC).withOpacity(0.5);
    final paintNear = Paint()..color = const Color(0xFF00695C).withOpacity(0.6);

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.65)
        ..quadraticBezierTo(size.width * 0.25, size.height * 0.35, size.width * 0.5,  size.height * 0.55)
        ..quadraticBezierTo(size.width * 0.75, size.height * 0.7,  size.width,        size.height * 0.5)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      paintFar,
    );

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.8)
        ..quadraticBezierTo(size.width * 0.3,  size.height * 0.55, size.width * 0.55, size.height * 0.75)
        ..quadraticBezierTo(size.width * 0.75, size.height * 0.88, size.width,        size.height * 0.72)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      paintNear,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.35, size.height)
        ..quadraticBezierTo(size.width * 0.45, size.height * 0.5,  size.width * 0.52, size.height * 0.3)
        ..lineTo(size.width * 0.58, size.height * 0.3)
        ..quadraticBezierTo(size.width * 0.55, size.height * 0.5,  size.width * 0.65, size.height)
        ..close(),
      Paint()..color = Colors.white.withOpacity(0.25),
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Cloud extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;
  const _Cloud({required this.width, required this.height, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SizedBox(width: width, height: height, child: CustomPaint(painter: _CloudPainter())),
    );
  }
}

class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width * 0.30, size.height * 0.6),  size.height * 0.45, p);
    canvas.drawCircle(Offset(size.width * 0.50, size.height * 0.4),  size.height * 0.55, p);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.55), size.height * 0.42, p);
    canvas.drawRect(Rect.fromLTRB(size.width * 0.15, size.height * 0.55, size.width * 0.88, size.height), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SunWidget extends StatelessWidget {
  const _SunWidget();

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 36, height: 36, child: CustomPaint(painter: _SunPainter()));
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final ray = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        Offset(cx + math.cos(a) * 10, cy + math.sin(a) * 10),
        Offset(cx + math.cos(a) * 16, cy + math.sin(a) * 16),
        ray,
      );
    }
    canvas.drawCircle(Offset(cx, cy), 8, Paint()..color = const Color(0xFFFFD54F));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Tree extends StatelessWidget {
  final double height;
  const _Tree({required this.height});

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: height * 0.6, height: height, child: CustomPaint(painter: _TreePainter()));
}

class _TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTRB(size.width * 0.4, size.height * 0.65, size.width * 0.6, size.height),
      Paint()..color = const Color(0xFF5D4037),
    );
    final leaf = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), size.width * 0.38, leaf);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.38), size.width * 0.35, leaf);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.22), size.width * 0.28, leaf);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _WalkingPerson extends StatelessWidget {
  const _WalkingPerson();

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 36, height: 56, child: CustomPaint(painter: _WalkingPersonPainter()));
}

class _WalkingPersonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF1A3A5C)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cx = size.width / 2;

    canvas.drawCircle(Offset(cx, size.height * 0.10), size.width * 0.18, p..style = PaintingStyle.fill);
    p..style = PaintingStyle.stroke..strokeWidth = 3;
    canvas.drawLine(Offset(cx, size.height * 0.20), Offset(cx, size.height * 0.58), p);
    canvas.drawLine(Offset(cx, size.height * 0.30), Offset(cx - size.width * 0.30, size.height * 0.48), p);
    canvas.drawLine(Offset(cx, size.height * 0.30), Offset(cx + size.width * 0.28, size.height * 0.44), p);
    canvas.drawLine(Offset(cx, size.height * 0.58), Offset(cx - size.width * 0.25, size.height * 0.82), p);
    canvas.drawLine(Offset(cx - size.width * 0.25, size.height * 0.82), Offset(cx - size.width * 0.10, size.height), p);
    canvas.drawLine(Offset(cx, size.height * 0.58), Offset(cx + size.width * 0.22, size.height * 0.80), p);
    canvas.drawLine(Offset(cx + size.width * 0.22, size.height * 0.80), Offset(cx + size.width * 0.35, size.height * 0.96), p);
  }

  @override
  bool shouldRepaint(_) => false;
}