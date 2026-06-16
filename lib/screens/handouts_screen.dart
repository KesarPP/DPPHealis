import 'package:flutter/material.dart';
import '../data/handouts_data.dart';
import '../data/gelato_theme.dart';

class HandoutsScreen extends StatelessWidget {
  final String title;
  final List<ModuleHandout> handouts;

  const HandoutsScreen({super.key, required this.title, required this.handouts});

  static const Color _navy = GelatoTheme.textDark;
  static const Color _pageBg = GelatoTheme.bg;

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
            color: GelatoTheme.blue,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black87, width: 1.5),
            boxShadow: [
              BoxShadow(color: GelatoTheme.blue.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(2, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MODULE ${module.moduleNumber}',
                  style: const TextStyle(
                      color: GelatoTheme.blueDark, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
              const SizedBox(height: 2),
              Text(module.moduleName,
                  style: const TextStyle(
                      color: GelatoTheme.textDark, fontSize: 15, fontWeight: FontWeight.w900)),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 0, offset: const Offset(2, 2)),
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
                  const Icon(Icons.folder_outlined, color: GelatoTheme.blueDark, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.session.sessionName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                  ),
                  Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: GelatoTheme.textLight),
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
                return InkWell(
                  onTap: () {
                    // Extract session number to determine which image to show
                    final match = RegExp(r'(?:Session|Module)\s+(\d+)').firstMatch(widget.session.sessionName);
                    int sessionNum = 1;
                    if (match != null) {
                      sessionNum = int.tryParse(match.group(1) ?? '1') ?? 1;
                    }
                    int imageIndex = ((sessionNum - 1) % 4) + 1;
                    String imagePath = 'assets/images/session_bg_$imageIndex.png';
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _HandoutImageScreen(
                          imagePath: imagePath,
                          title: item.title,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                              color: GelatoTheme.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black87, width: 1.0)),
                          child: Center(
                            child: Text('${item.number}',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w800, color: GelatoTheme.blueDark)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(item.title,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: GelatoTheme.textDark)),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFFB0BEC5), size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _HandoutImageScreen extends StatelessWidget {
  final String imagePath;
  final String title;

  const _HandoutImageScreen({required this.imagePath, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: GelatoTheme.textDark),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(title,
            style: const TextStyle(color: GelatoTheme.textDark, fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Image not found:\n$imagePath', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Please add the image to the assets folder', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}