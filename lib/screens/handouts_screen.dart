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
        ...module.sessions.map((s) => _SessionCard(
              session: s,
              initiallyExpanded: module.sessions.length == 1,
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SessionCard extends StatefulWidget {
  final SessionHandout session;
  final bool initiallyExpanded;
  const _SessionCard({
    required this.session,
    this.initiallyExpanded = false,
  });

  @override
  State<_SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<_SessionCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

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
                              child: _buildPageContent(widget.title, index, _displayPages[index]),
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

  void _showImageZoom(BuildContext context, String assetPath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black87, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: Image.asset(assetPath, fit: BoxFit.contain),
                ),
              ),
            ),
            IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 14,
                child: Icon(Icons.close, size: 16, color: GelatoTheme.textDark),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGinghamImage({
    required String assetPath,
    double? height,
    double? width,
    BoxFit fit = BoxFit.cover,
  }) {
    return GestureDetector(
      onTap: () => _showImageZoom(context, assetPath),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
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
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _GinghamPainter(widget.colorIndex, isMixed: true)),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    assetPath,
                    fit: fit,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          assetPath.split('/').last,
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideBySide({
    required String text,
    required String assetPath,
    bool imageOnLeft = false,
    double imageHeight = 150,
    int textFlex = 5,
    int imageFlex = 4,
    BoxFit fit = BoxFit.cover,
  }) {
    final imgWidget = _buildGinghamImage(
      assetPath: assetPath,
      height: imageHeight,
      fit: fit,
    );
    final txtWidget = _buildFormattedText(text);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageOnLeft) ...[
          Expanded(flex: imageFlex, child: imgWidget),
          const SizedBox(width: 14),
          Expanded(flex: textFlex, child: txtWidget),
        ] else ...[
          Expanded(flex: textFlex, child: txtWidget),
          const SizedBox(width: 14),
          Expanded(flex: imageFlex, child: imgWidget),
        ],
      ],
    );
  }

  Widget _buildLandscapeImage({
    required String assetPath,
    double height = 155,
    BoxFit fit = BoxFit.cover,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: _buildGinghamImage(
        assetPath: assetPath,
        height: height,
        fit: fit,
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    final paragraphs = text.split('\n\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((p) {
        final trimmed = p.trim();
        if (trimmed.isEmpty) return const SizedBox.shrink();

        final colonIndex = trimmed.indexOf(':');
        final qIndex = trimmed.indexOf('?');
        int splitIndex = -1;
        if (colonIndex > 0 && colonIndex < 35) {
          splitIndex = colonIndex + 1;
        } else if (qIndex > 0 && qIndex < 35) {
          splitIndex = qIndex + 1;
        }

        if (splitIndex > 0 && splitIndex < trimmed.length) {
          final header = trimmed.substring(0, splitIndex);
          final body = trimmed.substring(splitIndex).trim();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: Color(0xFF2C3E50),
                  height: 1.6,
                ),
                children: [
                  TextSpan(
                    text: '$header ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1B365D),
                    ),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            trimmed,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: Color(0xFF2C3E50),
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPageContent(String title, int pageIndex, String text) {
    final t = title.toLowerCase();

    // ==========================================
    // SESSION 1
    // ==========================================
    if (t.contains('prediabetes') && !t.contains('foundations')) {
      // Session 1, Item 1: Understanding Prediabetes
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_1/s1_glucose_levels.png',
            height: 165,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(
            "Welcome to your Diabetes Prevention Journey! This program is designed to help you take small, meaningful steps toward a healthier life. Over the coming weeks, you'll learn about nutrition, movement, and habits that can make a real difference — one session at a time. Let's get started!\n\nPrediabetes means that blood sugar is high but not yet high enough to be type 2 diabetes.",
          ),
        ],
      );
    }

    if (t.contains('type 2') || t.contains('type-2')) {
      // Session 1, Item 2: Understanding Type 2 Diabetes
      if (pageIndex == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLandscapeImage(
              assetPath: 'assets/images/handouts/module_1/s1_type2_diabetes.png',
              height: 155,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 14),
            _buildFormattedText(text),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('ndpp') || t.contains('diabetes prevention program')) {
      // Session 1, Item 3: Introduction to NDPP
      if (pageIndex == 0) {
        final paragraphs = text.split('\n\n');
        final firstPara = paragraphs.isNotEmpty ? paragraphs.first : text;
        final remaining = paragraphs.length > 1 ? paragraphs.sublist(1).join('\n\n') : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSideBySide(
              text: firstPara,
              assetPath: 'assets/images/handouts/module_1/s1_ndpp_logo.png',
              imageOnLeft: false,
              imageHeight: 125,
              textFlex: 5,
              imageFlex: 4,
              fit: BoxFit.contain,
            ),
            if (remaining.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildFormattedText(remaining),
            ],
          ],
        );
      } else if (pageIndex == _displayPages.length - 2 || (pageIndex == 6 && _displayPages.length > 6)) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildGinghamImage(
                    assetPath: 'assets/images/handouts/module_1/s1_scale_weight.png',
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildGinghamImage(
                    assetPath: 'assets/images/handouts/module_1/s1_healthy_activity.png',
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFormattedText(text),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('manage weight') || t.contains('why manage')) {
      // Session 1, Item 4: Why Manage Weight?
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_1/s1_manage_weight.png',
            height: 165,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    // ==========================================
    // SESSION 2
    // ==========================================
    if (t.contains('understanding calories')) {
      // Session 2, Item 1: Understanding Calories
      if (pageIndex == 0) {
        final paragraphs = text.split('\n\n');
        final firstPara = paragraphs.isNotEmpty ? paragraphs.first : text;
        final remaining = paragraphs.length > 1 ? paragraphs.sublist(1).join('\n\n') : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSideBySide(
              text: firstPara,
              assetPath: 'assets/images/handouts/module_1/s2_calories_notepad.png',
              imageOnLeft: false,
              imageHeight: 145,
              textFlex: 5,
              imageFlex: 4,
              fit: BoxFit.cover,
            ),
            if (remaining.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildFormattedText(remaining),
            ],
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('understanding fat')) {
      // Session 2, Item 2: Understanding Fat
      if (pageIndex == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLandscapeImage(
              assetPath: 'assets/images/handouts/module_1/s2_understanding_fats.png',
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
            _buildFormattedText(text),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('fat in foods') || t.contains('fats in food')) {
      // Session 2, Item 3: Fats in Food
      if (pageIndex == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLandscapeImage(
              assetPath: 'assets/images/handouts/module_1/s2_fat_per_day.png',
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
            _buildFormattedText(text),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSideBySide(
              text: text,
              assetPath: 'assets/images/handouts/module_1/s2_importance_of_fats.png',
              imageOnLeft: false,
              imageHeight: 155,
              textFlex: 5,
              imageFlex: 4,
              fit: BoxFit.contain,
            ),
          ],
        );
      }
    }

    if (t.contains('hidden calories') && (t.contains('hidden fat') || t.contains('hidden fats'))) {
      // Session 2, Item 4: Hidden Calories and Hidden Fats
      if (pageIndex == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSideBySide(
              text: text,
              assetPath: 'assets/images/handouts/module_1/s2_good_vs_bad_fats.png',
              imageOnLeft: false,
              imageHeight: 230,
              textFlex: 5,
              imageFlex: 4,
              fit: BoxFit.contain,
            ),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('why hidden calories matter')) {
      // Session 2, Item 5: Why Hidden Calories Matter
      if (pageIndex == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormattedText(text),
            const SizedBox(height: 14),
            _buildLandscapeImage(
              assetPath: 'assets/images/handouts/module_1/s2_fastfood_vs_homecooked.png',
              height: 175,
              fit: BoxFit.contain,
            ),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    // ==========================================
    // SESSION 3
    // ==========================================
    if (t.contains('reducing fat intake') || t.contains('measuring and preparation')) {
      // Session 3, Item 1: Measuring and Preparation
      if (pageIndex == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLandscapeImage(
              assetPath: 'assets/images/handouts/module_1/s3_measuring_prep.png',
              height: 155,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 14),
            _buildFormattedText(text),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('everyday fat reduction')) {
      // Session 3, Item 2: Everyday Fat Reduction Strategies
      if (pageIndex == 0) {
        final paragraphs = text.split('\n\n');
        final firstPara = paragraphs.isNotEmpty ? paragraphs.first : text;
        final remaining = paragraphs.length > 1 ? paragraphs.sublist(1).join('\n\n') : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSideBySide(
              text: firstPara,
              assetPath: 'assets/images/handouts/module_1/s3_calorie_counter.png',
              imageOnLeft: false,
              imageHeight: 140,
              textFlex: 5,
              imageFlex: 4,
              fit: BoxFit.cover,
            ),
            if (remaining.isNotEmpty) ...[
              const SizedBox(height: 14),
              _buildFormattedText(remaining),
            ],
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('without feeling deprived')) {
      // Session 3, Item 3: Reducing Calories Without Feeling Deprived
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 14),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_1/s3_healthy_vs_sweets.png',
            height: 155,
            fit: BoxFit.cover,
          ),
        ],
      );
    }

    // ==========================================
    // SESSION 4
    // ==========================================
    if (t.contains('principles of healthy eating')) {
      // Session 4, Item 1: Principles of Healthy Eating
      if (pageIndex == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLandscapeImage(
              assetPath: 'assets/images/handouts/module_1/s4_balanced_diet.png',
              height: 155,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 14),
            _buildFormattedText(text),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('the plate method') || t.contains('variety and balance')) {
      // Session 4, Item 2: The Plate Method / Variety and Balance
      if (pageIndex == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLandscapeImage(
              assetPath: 'assets/images/handouts/module_1/s4_myplate_guide.png',
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 14),
            _buildFormattedText(text),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('fruits & vegetables') || t.contains('more volume')) {
      // Session 4, Item 3: More Volume, Fewer Calories
      if (pageIndex == 1 || (pageIndex == 0 && _displayPages.length == 1)) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSideBySide(
              text: text,
              assetPath: 'assets/images/handouts/module_1/s4_high_low_volume.png',
              imageOnLeft: false,
              imageHeight: 230,
              textFlex: 5,
              imageFlex: 4,
              fit: BoxFit.contain,
            ),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('starches and diabetes') || t.contains('starchy foods')) {
      // Session 4, Item 4: Starchy Foods and Fiber
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 14),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_1/s4_starchy_fiber.png',
            height: 155,
            fit: BoxFit.cover,
          ),
        ],
      );
    }

    if (t.contains('low-fat flavoring') || t.contains('healthy food preparation')) {
      // Session 4, Item 5: Healthy Food Preparation
      if (pageIndex == _displayPages.length - 1 || pageIndex == 1) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormattedText(text),
            const SizedBox(height: 14),
            _buildLandscapeImage(
              assetPath: 'assets/images/handouts/module_1/s4_cooking_methods.png',
              height: 170,
              fit: BoxFit.contain,
            ),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('mindful eating')) {
      // Session 4, Item 6: Mindful Eating
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSideBySide(
            text: text,
            assetPath: 'assets/images/handouts/module_1/s4_mindful_eating.png',
            imageOnLeft: false,
            imageHeight: 145,
            textFlex: 5,
            imageFlex: 4,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    // ==========================================
    // MODULE 2: SESSION 5
    // ==========================================
    if (t.contains('understanding physical activity')) {
      // Session 5, Item 1: Understanding Physical Activity
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s5_understanding_activity.png',
            height: 160,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('why physical activity matters')) {
      // Session 5, Item 2: Why Physical Activity Matters
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s5_why_activity_matters.png',
            height: 140,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('health benefits of physical activity')) {
      // Session 5, Item 3: Health Benefits of Physical Activity
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s5_health_benefits.png',
            height: 155,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('insulin resistance')) {
      // Session 5, Item 4: Physical Activity and Insulin Resistance
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSideBySide(
            text: text,
            assetPath: 'assets/images/handouts/module_2/s5_insulin_resistance.png',
            imageOnLeft: false,
            imageHeight: 200,
            textFlex: 5,
            imageFlex: 4,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('understanding activity intensity')) {
      // Session 5, Item 5: Understanding Activity Intensity
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSideBySide(
            text: text,
            assetPath: 'assets/images/handouts/module_2/s5_activity_intensity.png',
            imageOnLeft: false,
            imageHeight: 140,
            textFlex: 5,
            imageFlex: 4,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('the ndpp physical activity goal') || (t.contains('physical activity goal') && !t.contains('understanding'))) {
      // Session 5, Item 6: The NDPP Physical Activity Goal
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s5_ndpp_goal.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('getting started safely')) {
      // Session 5, Item 7: Getting Started Safely
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s5_getting_started_safely.png',
            height: 175,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    // ==========================================
    // MODULE 2: SESSION 6
    // ==========================================
    if (t.contains('making physical activity a lifestyle') || t.contains('activity a lifestyle')) {
      // Session 6, Item 1: Making Physical Activity a Lifestyle
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s6_active_lifestyle.png',
            height: 175,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('starting safely') && !t.contains('getting')) {
      // Session 6, Item 2: Starting Safely
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s6_starting_safely.png',
            height: 175,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('types of physical activity')) {
      // Session 6, Item 3: Types of Physical Activity
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s6_types_of_activity.png',
            height: 145,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('flexibility activities') || t.contains('finding activities')) {
      // Session 6, Item 4: Flexibility Activities
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s6_flexibility_activities.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('building activity gradually')) {
      // Session 6, Item 5: Building Activity Gradually
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s6_building_gradually.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('reducing sedentary time')) {
      // Session 6, Item 6: Reducing Sedentary Time
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s6_reducing_sedentary.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('creating an activity plan') || (t.contains('activity plan') && !t.contains('jump'))) {
      // Session 6, Item 7: Creating an Activity Plan
      if (pageIndex == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormattedText(text),
            const SizedBox(height: 12),
            _buildLandscapeImage(
              assetPath: 'assets/images/handouts/module_2/s6_activity_plan.png',
              height: 180,
              fit: BoxFit.contain,
            ),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    // ==========================================
    // MODULE 2: SESSION 7
    // ==========================================
    if (t.contains('understanding calorie balance')) {
      // Session 7, Item 1: Understanding Calorie Balance
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s7_calorie_balance.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('where calories go')) {
      // Session 7, Item 2: Where Calories Go
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s7_calorie_balance.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('understanding weight change')) {
      // Session 7, Item 3: Understanding Weight Change
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s7_weight_change.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('food and activity work together')) {
      // Session 7, Item 4: Food and Activity Work Together
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s7_food_activity_together.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('setting realistic expectations') || t.contains('managing plateaus') || t.contains('weight loss plateaus')) {
      // Session 7, Item 5: Setting Realistic Expectations and Managing Plateaus
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s7_expectations_plateaus.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('tracking progress')) {
      // Session 7, Item 6: Tracking Progress
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s7_tracking_progress.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    if (t.contains('long-term weight management')) {
      // Session 7, Item 7: Long-Term Weight Management
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedText(text),
          const SizedBox(height: 12),
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_2/s7_long_term_management.png',
            height: 180,
            fit: BoxFit.contain,
          ),
        ],
      );
    }

    // ==========================================
    // MODULE 3: SESSION 8
    // ==========================================
    if (t.contains('understanding behaviour triggers') || t.contains('behavior triggers')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s8_behaviour_triggers.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('identifying food cues') || t.contains('personal triggers')) {
      if (pageIndex == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLandscapeImage(
              assetPath: 'assets/images/handouts/module_3/s8_identifying_food_cues.png',
              height: 165,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 14),
            _buildFormattedText(text),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('identifying activity cues')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s8_identifying_activity_cues.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('creating a healthy environment')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s8_creating_healthy_environment.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('taking control of your environment')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s8_taking_control_environment.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    // ==========================================
    // MODULE 3: SESSION 9
    // ==========================================
    if (t.contains('understanding problems and barriers') || t.contains('problems and barriers')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s9_problems_barriers.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('understanding problem solving')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s9_understanding_problem_solving.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('step 1') || t.contains('identify the problem')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s9_step1_identify_problem.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('step 2') || t.contains('generate possible solutions')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s9_step2_generate_solutions.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('step 3') || t.contains('choose the best solution')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s9_step3_choose_best.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('step 4') || t.contains('try the solution')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s9_step4_try_solution.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('step 5') || t.contains('review the results')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s9_step5_review_results.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('building a problem-solving mindset') || (t.contains('problem-solving mindset') && !t.contains('understanding'))) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s9_building_problem_solving_mindset.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    // ==========================================
    // MODULE 3: SESSION 10
    // ==========================================
    if (t.contains('challenges of eating outside') || t.contains('eating outside the home')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s10_challenges_eating_out.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('key 1') || t.contains('plan ahead')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s10_key1_plan_ahead.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('key 2') || t.contains('make healthy choices')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s10_key2_healthy_choices.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('key 3') || t.contains('watch portion sizes')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s10_key3_watch_portions.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('key 4') || t.contains('ask for what you want') || t.contains('eat mindfully')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s10_key4_ask_what_you_want.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    // ==========================================
    // MODULE 3: SESSION 11
    // ==========================================
    if (t.contains('identifying negative thoughts')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s11_identifying_negative_thoughts.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('understanding self-defeating thinking') || t.contains('self-defeating')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s11_self_defeating_thinking.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('challenging negative thoughts')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s11_challenging_negative_thoughts.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('replacing negative thoughts')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s11_replacing_negative_thoughts.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('building self-confidence') || t.contains('self-confidence')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s11_building_self_confidence.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    // ==========================================
    // MODULE 3: SESSION 12
    // ==========================================
    if (t.contains('understanding lifestyle change') && !t.contains('slippery slope')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s12_understanding_lifestyle_change.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('understanding lapses')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s12_understanding_lapses.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('understanding the slippery slope') || t.contains('slippery slope')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s12_understanding_slippery_slope.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('lapse vs relapse')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s12_lapse_vs_relapse.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    if (t.contains('responding to a lapse') || t.contains('recognize what happened')) {
      if (pageIndex == 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLandscapeImage(
              assetPath: 'assets/images/handouts/module_3/s12_responding_to_lapse.png',
              height: 165,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 14),
            _buildFormattedText(text),
          ],
        );
      }
      return _buildFormattedText(text);
    }

    if (t.contains('building long-term success')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLandscapeImage(
            assetPath: 'assets/images/handouts/module_3/s12_building_long_term_success.png',
            height: 165,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 14),
          _buildFormattedText(text),
        ],
      );
    }

    return _buildFormattedText(text);
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