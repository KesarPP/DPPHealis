import 'package:flutter/material.dart';
import '../data/handouts_data.dart';

class HandoutsScreen extends StatelessWidget {
  final String title;
  final List<ModuleHandout> handouts;

  const HandoutsScreen({super.key, required this.title, required this.handouts});

  static const Color _teal = Color(0xFF00897B);
  static const Color _navy = Color(0xFF1A3A5C);
  static const Color _grey = Color(0xFF78909C);
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
        title: Text(title,
            style: const TextStyle(color: _navy, fontWeight: FontWeight.w700, fontSize: 18)),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: handouts.length,
        itemBuilder: (context, i) => _ModuleCard(module: handouts[i]),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final ModuleHandout module;
  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Module header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF00897B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MODULE ${module.moduleNumber}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              const SizedBox(height: 2),
              Text(module.moduleName,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Sessions
        ...module.sessions.map((s) => _SessionCard(session: s)),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SessionCard extends StatefulWidget {
  final SessionHandout session;
  const _SessionCard({required this.session});

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Session header (tappable)
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.folder_outlined, color: Color(0xFF00897B), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.session.sessionName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A3A5C))),
                  ),
                  Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF78909C)),
                ],
              ),
            ),
          ),
          // Items list
          if (_expanded)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              itemCount: widget.session.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = widget.session.items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 24, height: 24,
                        decoration: const BoxDecoration(
                            color: Color(0xFFE0F2F1), shape: BoxShape.circle),
                        child: Center(
                          child: Text('${item.number}',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF00897B))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(item.title,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF1A3A5C))),
                      ),
                      const Icon(Icons.chevron_right, color: Color(0xFFB0BEC5), size: 18),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}