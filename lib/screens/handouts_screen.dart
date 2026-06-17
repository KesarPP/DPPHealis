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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _HandoutImageScreen(
                          title: item.title,
                          content: item.content,
                          pages: item.pages,
                          colorIndex: item.number,
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

class _HandoutImageScreen extends StatefulWidget {
  final String title;
  final String? content;
  final List<String>? pages;
  final int colorIndex;

  const _HandoutImageScreen({required this.title, this.content, this.pages, this.colorIndex = 0});

  @override
  State<_HandoutImageScreen> createState() => _HandoutImageScreenState();
}

class _HandoutImageScreenState extends State<_HandoutImageScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  List<String> get _displayPages => widget.pages ?? (widget.content != null && widget.content!.isNotEmpty ? [widget.content!] : ['']);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: GelatoTheme.textDark),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(widget.title,
            style: const TextStyle(color: GelatoTheme.textDark, fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _GinghamPainter(
                widget.colorIndex,
                isMixed: widget.title == 'Understanding Prediabetes',
              ),
            ),
          ),
          if (_displayPages.isEmpty)
            const SizedBox.shrink()
          else
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (idx) => setState(() => _currentPage = idx),
                        itemCount: _displayPages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F5F0), // Paper-like color
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: const Color(0xFF5A5A5A), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                              child: _buildPageContent(widget.title, _displayPages[index]),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_displayPages.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_displayPages.length, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index ? GelatoTheme.textDark : Colors.grey.withValues(alpha: 0.3),
                              ),
                            );
                          }),
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

  Widget _buildPageContent(String title, String text) {
    if (title == 'Understanding Prediabetes') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  "Welcome to your Diabetes Prevention Journey! This program is designed to help you take small, meaningful steps toward a healthier life.",
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    color: Color(0xFF2C3E50),
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.only(top: 40),
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF5A5A5A), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(painter: _GinghamPainter(0, isMixed: true)),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset('assets/images/Image 1.jpg', fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300], child: const Center(child: Text('Image 1', style: TextStyle(fontSize: 10))),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            "Over the coming weeks, you'll learn about nutrition, movement, and habits that can make a real difference — one session at a time. Let's get started!",
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              color: Color(0xFF2C3E50),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF5A5A5A), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(painter: _GinghamPainter(0, isMixed: true)),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset('assets/images/Image 2.jpg', fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300], child: const Center(child: Text('Image 2', style: TextStyle(fontSize: 10))),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                flex: 5,
                child: Text(
                  "Prediabetes means that blood sugar is high but not yet high enough to be type 2 diabetes.",
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    color: Color(0xFF2C3E50),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Container(
            width: double.infinity,
            height: 140,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF5A5A5A), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: _GinghamPainter(0, isMixed: true)),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset('assets/images/Image 3.png', fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300], child: const Center(child: Text('Image 3 (Chart)', style: TextStyle(fontSize: 12))),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Default layout for other pages
    return Text(
      text,
      textAlign: TextAlign.left,
      style: const TextStyle(
        fontFamily: 'serif',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: Color(0xFF2C3E50),
        height: 1.6,
      ),
    );
  }
}

class _GinghamPainter extends CustomPainter {
  final int colorIndex;
  final bool isMixed;
  _GinghamPainter(this.colorIndex, {this.isMixed = false});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFAF9F6)); // Off-white base
    
    const double stripeWidth = 30.0;

    if (isMixed) {
      // Light pink vertical stripes
      final pinkPaint = Paint()..color = const Color(0xFFF5D0D6).withValues(alpha: 0.4);
      for (double x = 0; x < size.width; x += stripeWidth * 2) {
        canvas.drawRect(Rect.fromLTWH(x, 0, stripeWidth, size.height), pinkPaint);
      }
      
      // Light green horizontal stripes
      final greenPaint = Paint()..color = const Color(0xFFD3E4CD).withValues(alpha: 0.4);
      for (double y = 0; y < size.height; y += stripeWidth * 2) {
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, stripeWidth), greenPaint);
      }
      return;
    }
    
    Color stripeColor;
    int index = colorIndex % 3;
    if (index == 2) {
      stripeColor = const Color(0xFFDCA6A6); // Pink
    } else if (index == 0) {
      stripeColor = const Color(0xFF8F9779); // Green
    } else {
      stripeColor = const Color(0xFF85A1C1); // Blue
    }
    
    final paint = Paint()..color = stripeColor.withValues(alpha: 0.4);
    
    // Vertical stripes
    for (double x = 0; x < size.width; x += stripeWidth * 2) {
      canvas.drawRect(Rect.fromLTWH(x, 0, stripeWidth, size.height), paint);
    }
    
    // Horizontal stripes
    for (double y = 0; y < size.height; y += stripeWidth * 2) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, stripeWidth), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GinghamPainter oldDelegate) => 
      oldDelegate.colorIndex != colorIndex || oldDelegate.isMixed != isMixed;
}