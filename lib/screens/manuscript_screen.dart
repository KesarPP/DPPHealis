import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/week_model.dart';
import '../theme/manuscript_theme.dart';
import '../widgets/ancient_book_background.dart';
import '../widgets/floating_particles.dart';
import 'activity_fitness_screen.dart';
import 'food_tracking_screen.dart';
import 'weigh_in_screen.dart';
import 'handouts_screen.dart';
import '../data/handouts_data.dart';

class ManuscriptScreen extends StatefulWidget {
  const ManuscriptScreen({super.key});

  @override
  State<ManuscriptScreen> createState() => _ManuscriptScreenState();
}

class _ManuscriptScreenState extends State<ManuscriptScreen>
    with TickerProviderStateMixin {
  static const double _rowHeight = 248;
  static const double _cardHorizontalInset = 20;

  bool _isBookOpen = false;
  bool _isOpening = false;
  late final AnimationController _coverController;
  late final Animation<double> _coverAngle;
  late final Animation<double> _pagesOpacity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/session_timeline/manuscript_page_left_new.png'), context);
    precacheImage(const AssetImage('assets/images/session_timeline/manuscript_page_right_new.png'), context);
  }

  @override
  void initState() {
    super.initState();
    _coverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Swings the cover open from 0 to -115 degrees (-2.0 radians) along spine
    _coverAngle = Tween<double>(begin: 0.0, end: -2.0).animate(
      CurvedAnimation(
        parent: _coverController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeInOutCubic),
      ),
    );

    // Fades in the inside pages right as the cover begins opening
    _pagesOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _coverController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _coverController.dispose();
    super.dispose();
  }

  void _openBook() {
    if (_isOpening || _isBookOpen) return;
    HapticFeedback.heavyImpact();
    setState(() => _isOpening = true);
    _coverController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _isBookOpen = true;
          _isOpening = false;
        });
      }
    });
  }

  void _closeBook() {
    if (!_isBookOpen && !_isOpening) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isBookOpen = false;
      _isOpening = true;
    });
    _coverController.reverse(from: 1.0).then((_) {
      if (mounted) {
        setState(() => _isOpening = false);
      }
    });
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06), // Reposition higher
      child: Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24), // Adjusted horizontal padding
          decoration: const BoxDecoration(
            color: Colors.transparent, // Completely transparent
          ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Your ',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24, // Decreased font
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E5339),
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Health\n',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD96B85),
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Journal',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E5339),
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 15, height: 1, color: const Color(0xFFE5A8B8)),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.0),
                        child: Icon(Icons.favorite, color: Color(0xFFD96B85), size: 10),
                      ),
                      Container(width: 15, height: 1, color: const Color(0xFFE5A8B8)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(Icons.spa, color: Color(0xFF6B8E76), size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Small steps today.\nHealthier tomorrow.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2E5339),
                          height: 1.3,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.spa, color: Color(0xFF6B8E76), size: 12),
                    ],
                  ),
                ],
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weeks = generateDummyWeeks();

    return Scaffold(
      backgroundColor: const Color(0xFF1C120C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Scholar's Desk Background (The background table around/behind the book)
          Image.asset(
            'assets/images/session_timeline/manuscript_bg_green1.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2A1B0D), Color(0xFF140D06), Color(0xFF0F0904)],
                ),
              ),
            ),
          ),

          // Floating ambient particles over the desk
          LayoutBuilder(
            builder: (context, constraints) => FloatingParticles(
              areaSize: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),

          // 2. The Book Container (Open Manuscript State) sitting cleanly on the scholar's desk
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateX(-0.15)
              ..scale(0.85) // Reduced size significantly
              ..translate(0.0, 0.0, 0.0), // Centered vertically
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.12,
                  bottom: MediaQuery.of(context).size.height * 0.12,
                  left: MediaQuery.of(context).size.width * 0.04,
                  right: MediaQuery.of(context).size.width * 0.04,
                ),
                child: AnimatedBuilder(
              animation: _coverController,
              builder: (context, child) {
                final opacity = (_isBookOpen && !_isOpening)
                    ? 1.0
                    : _pagesOpacity.value;
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: Stack(
                  fit: StackFit.expand,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: FloatingParticles(
                                areaSize: Size(constraints.maxWidth, constraints.maxHeight),
                              ),
                            ),
                            _OpenBookInterior(
                                weeks: weeks,
                                rowHeight: _rowHeight,
                                horizontalInset: _cardHorizontalInset,
                                onCloseBook: _closeBook,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                ),
              ),
            ),
          ), // padding
          ), // transform

          // 3. 3D Swinging Book Cover Overlay and bottom unlock button sitting right on the desk bg image
          if (!_isBookOpen || _isOpening)
            SafeArea(
              child: Column(
                children: [
                  _buildHeaderCard(context),
                  Expanded(
                    child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.0015)
                            ..rotateX(-0.15)
                            ..scale(0.85, 0.99, 1.0) // Decreased width by 10% and height by 5%
                            ..translate(0.0, -15.0, 0.0), // Shifted up to keep top edge anchored
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.01,
                              bottom: 0,
                              left: MediaQuery.of(context).size.width * 0.02,
                              right: MediaQuery.of(context).size.width * 0.02,
                            ),
                          child: AnimatedBuilder(
                      animation: _coverController,
                      builder: (context, child) {
                        final progress = _coverController.value;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            IgnorePointer(
                                ignoring: progress > 0.6 || _isBookOpen,
                                child: Transform(
                                  alignment: Alignment.centerLeft,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.0012)
                                    ..rotateY(_coverAngle.value),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      // Removed all box shadows because they draw a solid rectangle behind the transparent PNG cover
                                    ),
                                    // Removed ClipRRect so the native PNG bookmark and corners are not cut off
                                    child: _BookCoverPage(
                                      onOpen: _openBook,
                                    ),
                                  ),
                                ),
                              ),
                              // Shimmer overlay during opening
                              if (progress > 0.05 && progress < 0.95)
                                IgnorePointer(
                                  child: Opacity(
                                    opacity: math.sin(progress * math.pi) * 0.35,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(22),
                                        gradient: const RadialGradient(
                                          colors: [ManuscriptColors.goldLight, Colors.transparent],
                                          radius: 0.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  ),
                    // Tap to unlock button adapted to the vintage gold/leather scroll theme
                    if (!_isBookOpen && !_isOpening)
                      Padding(
                        padding: EdgeInsets.only(
                          top: 8,
                          bottom: MediaQuery.of(context).size.height * 0.02, // moved lower
                        ),
                        child: GestureDetector(
                          onTap: _openBook,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            width: 260, // decreased width
                            height: 48, // decreased height
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFBB8D0), Color(0xFFF07BA8)], // Soft pink gradient
                              ),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white, width: 2.0),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                                  blurRadius: 25,
                                  spreadRadius: 4,
                                ),
                                BoxShadow(
                                  color: const Color(0xFFF07BA8).withValues(alpha: 0.4),
                                  blurRadius: 35,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'OPEN MY JOURNAL',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Renders the open book interior with sequential Left & Right manuscript pages and zero extra cards
class _OpenBookInterior extends StatefulWidget {
  final List<WeekModel> weeks;
  final double rowHeight;
  final double horizontalInset;
  final VoidCallback onCloseBook;

  const _OpenBookInterior({
    required this.weeks,
    required this.rowHeight,
    required this.horizontalInset,
    required this.onCloseBook,
  });

  @override
  State<_OpenBookInterior> createState() => _OpenBookInteriorState();
}

class _OpenBookInteriorState extends State<_OpenBookInterior> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  void _prevPage() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  Widget _buildManuscriptButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: ManuscriptColors.gold.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ManuscriptColors.gold.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: ManuscriptColors.darkWood, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ManuscriptColors.darkWood,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: ManuscriptColors.darkWood, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required Color baseColor,
    required IconData leftIcon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    double bgAlpha = 0.1,
    bool showIcons = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: baseColor.withValues(alpha: bgAlpha),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Row(
          children: [
            // Left circular icon
            if (showIcons) ...[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: baseColor.withValues(alpha: 0.15),
                  border: Border.all(color: baseColor.withValues(alpha: 0.3)),
                ),
                child: Icon(leftIcon, color: baseColor, size: 16),
              ),
              const SizedBox(width: 10),
            ],
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: showIcons ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: showIcons ? TextAlign.left : TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: const Color(0xFF2E5339),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    textAlign: showIcons ? TextAlign.left : TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 9,
                      color: const Color(0xFF2E5339).withValues(alpha: 0.8),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            // Right Arrow
            if (showIcons)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: baseColor.withValues(alpha: 0.4)),
                  color: Colors.white,
                ),
                child: Icon(Icons.arrow_forward_ios_rounded, size: 10, color: baseColor),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          children: [
            // Page 1: Manuscript Left Page
            Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: Image.asset(
                    'assets/images/session_timeline/manuscript_page_left_new.png',
                    fit: BoxFit.contain, // Changed from cover to contain to fit its native rounded corners
                    errorBuilder: (c, e, s) => const SizedBox.shrink(),
                  ),
                ),
                // Content overlaid on the left page
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      left: 45,
                      right: 55, // Increased to prevent bleeding into the right side
                      bottom: 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Center(
                            child: FractionallySizedBox(
                              widthFactor: 0.9,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFBB8D0).withValues(alpha: 0.2), // Pastel Pink Tint
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: const Color(0xFFF07BA8).withValues(alpha: 0.4), width: 3), // Pink border
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFD96B85).withValues(alpha: 0.15),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(13),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // Pastel placeholder background
                                            Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFFE1F5FE), // Light Pastel Blue
                                                    Color(0xFFF3E5F5), // Light Pastel Purple
                                                  ],
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.play_circle_fill_rounded,
                                                color: Colors.white54,
                                                size: 64,
                                              ),
                                            ),
                                            // "Watch Video" label
                                            Positioned(
                                              bottom: 12,
                                              left: 16,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.8),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: const [
                                                    Icon(Icons.spa_rounded, color: Color(0xFF81C784), size: 14),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Session Video',
                                                      style: TextStyle(
                                                        color: Color(0xFF2E5339),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Georgia',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              // Elaborate Health & Fitness Elements Around the Frame
                              // Top Left: Apple & Leaves
                              Positioned(
                                top: -25,
                                left: -20,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.rotate(
                                      angle: -0.2,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(2, 4)),
                                          ],
                                        ),
                                        child: const Icon(Icons.apple_rounded, color: Color(0xFFE57373), size: 36),
                                      ),
                                    ),
                                    Positioned(
                                      top: -10,
                                      right: -10,
                                      child: Transform.rotate(
                                        angle: 0.5,
                                        child: const Icon(Icons.eco_rounded, color: Color(0xFF81C784), size: 24),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Top Right: Heart & Pulse
                              Positioned(
                                top: -20,
                                right: -15,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Transform.rotate(
                                      angle: 0.1,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(-2, 4)),
                                          ],
                                        ),
                                        child: const Icon(Icons.monitor_heart_rounded, color: Color(0xFFF06292), size: 36),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -5,
                                      left: -15,
                                      child: const Icon(Icons.favorite_rounded, color: Color(0xFFF48FB1), size: 20),
                                    ),
                                  ],
                                ),
                              ),
                              // Bottom Left: Fitness/Dumbbell
                              Positioned(
                                bottom: -20,
                                left: -10,
                                child: Transform.rotate(
                                  angle: -0.3,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: const Icon(Icons.fitness_center_rounded, color: Color(0xFF64B5F6), size: 32),
                                  ),
                                ),
                              ),
                              // Bottom Right: Scale/Weight
                              Positioned(
                                bottom: -15,
                                right: -20,
                                child: Transform.rotate(
                                  angle: 0.2,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: const Icon(Icons.monitor_weight_rounded, color: Color(0xFFBA68C8), size: 32),
                                  ),
                                ),
                              ),
                              // Side Floating Leaves
                              Positioned(
                                top: 80,
                                left: -25,
                                child: Transform.rotate(
                                  angle: -1.0,
                                  child: const Icon(Icons.spa_rounded, color: Color(0xFFAED581), size: 28),
                                ),
                              ),
                              Positioned(
                                top: 90,
                                right: -25,
                                child: Transform.rotate(
                                  angle: 1.0,
                                  child: const Icon(Icons.local_dining_rounded, color: Color(0xFFFFB74D), size: 28),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                        const SizedBox(height: 16),
                        _buildActionCard(
                          baseColor: const Color(0xFF64B5F6), // Pastel Blue
                          leftIcon: Icons.replay_rounded,
                          title: 'Replay Session',
                          subtitle: 'Listen to the session audio again.',
                          onTap: () {},
                          bgAlpha: 0.6, // More vibrant fill
                        ),
                        _buildActionCard(
                          baseColor: const Color(0xFF81C784), // Pastel Green
                          leftIcon: Icons.last_page_rounded,
                          title: 'Turn Page',
                          subtitle: 'Flip the page to see more options.',
                          onTap: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          bgAlpha: 0.6, // More vibrant fill
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Page 2: Manuscript Right Page
            Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: Image.asset(
                    'assets/images/session_timeline/manuscript_page_right_new.png',
                    fit: BoxFit.contain, // Fit like a page without cropping or zooming
                    errorBuilder: (c, e, s) => const SizedBox.shrink(),
                  ),
                ),
                // Content overlaid on the right page
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 10,
                      left: 55, // clear the binding
                      right: 48, // clear the tabs
                      bottom: 35, // Reduced from 70 to push buttons lower
                    ),
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: IntrinsicHeight(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                        const SizedBox(height: 6),
                        // Today's Session Header
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.eco_rounded, color: Color(0xFFC5E1A5), size: 20),
                                const SizedBox(width: 6),
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Today's ",
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF2E5339),
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Session",
                                        style: TextStyle(
                                          fontFamily: 'Georgia',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFFF06292),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.eco_rounded, color: Color(0xFFC5E1A5), size: 20),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Learn • Grow • Thrive",
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontSize: 11,
                                color: Color(0xFF81C784),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildActionCard(
                          baseColor: const Color(0xFFF06292), // Pink
                          leftIcon: Icons.description_rounded,
                          title: 'Session Handouts',
                          subtitle: 'View and download resources from today\'s session.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HandoutsScreen(
                                title: 'Session Handouts',
                                handouts: ndppHandouts,
                              )),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildActionCard(
                          baseColor: const Color(0xFFFF9800), // Orange
                          leftIcon: Icons.assignment_turned_in_rounded,
                          title: 'Session Quiz',
                          subtitle: 'Test your knowledge with a quick quiz.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Scaffold(
                                appBar: AppBar(
                                  backgroundColor: const Color(0xFFFAF7F2),
                                  title: const Text('Session Quiz', style: TextStyle(color: Colors.black87)),
                                  iconTheme: const IconThemeData(color: Colors.black87),
                                  elevation: 0,
                                ),
                                body: const Center(child: Text('Quiz Page Coming Soon')),
                              )),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildActionCard(
                          baseColor: const Color(0xFFAB47BC), // Purple
                          leftIcon: Icons.monitor_weight_rounded,
                          title: 'Weekly Weigh-In',
                          subtitle: 'Track your progress and celebrate your wins.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WeighInScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildActionCard(
                          baseColor: const Color(0xFF81C784), // Green
                          leftIcon: Icons.restaurant_rounded,
                          title: 'Meal Log',
                          subtitle: 'Log your meals and build healthier habits.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FoodTrackingScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildActionCard(
                          baseColor: const Color(0xFF64B5F6), // Blue
                          leftIcon: Icons.directions_run_rounded,
                          title: 'Activity',
                          subtitle: 'Record your activities and stay active every day.',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ActivityFitnessScreen()),
                            );
                          },
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                baseColor: const Color(0xFFFFD54F), // Pastel Yellow
                                leftIcon: Icons.arrow_back_ios_new_rounded,
                                title: 'Previous Page',
                                subtitle: 'Go back.',
                                onTap: _prevPage,
                                showIcons: false,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionCard(
                                baseColor: const Color(0xFFE57373), // Pastel Red
                                leftIcon: Icons.close_rounded,
                                title: 'Close Book',
                                subtitle: 'Finish for now.',
                                onTap: widget.onCloseBook,
                                showIcons: false,
                              ),
                            ),
                          ],
                        ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              ),
            ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// The Closed Book Cover Page with gold border vignette, smaller lowered clasp, and unlock prompt
class _BookCoverPage extends StatefulWidget {
  final VoidCallback onOpen;

  const _BookCoverPage({required this.onOpen});

  @override
  State<_BookCoverPage> createState() => _BookCoverPageState();
}

class _BookCoverPageState extends State<_BookCoverPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _specularController;

  @override
  void initState() {
    super.initState();
    _specularController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9), // 8-10 seconds
    )..repeat();
  }

  @override
  void dispose() {
    _specularController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onOpen,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Book Cover Asset
          Align(
            alignment: Alignment.center,
            child: FractionallySizedBox(
              widthFactor: 0.95,
              heightFactor: 0.95,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Actual Image
                  Image.asset(
                    'assets/images/session_timeline/book_cover_transparent.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/backgrounds/manuscript_bg.png',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const SizedBox.shrink(),
                    ),
                  ),
              // FIX: Removed Lighting Integration overlays that caused black screen
              // Gold Medallion Specular Highlight
              AnimatedBuilder(
                animation: _specularController,
                builder: (context, child) {
                  final progress = _specularController.value;
                  double highlightPos = -1.0;
                  // ~0.8s duration in a 9s loop is about 0.088 of the progress
                  if (progress < 0.1) {
                    highlightPos = -1.0 + (progress * 20.0); // maps 0.0->0.1 to -1.0->1.0
                  } else {
                    highlightPos = 2.0; // keep offscreen for the rest of the loop
                  }

                  return Center(
                    child: Container(
                      width: 140, // Match medallion size approx
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.6), // Specular highlight
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: [
                            0.0,
                            (highlightPos - 0.1).clamp(0.0, 1.0),
                            highlightPos.clamp(0.0, 1.0),
                            (highlightPos + 0.1).clamp(0.0, 1.0),
                            1.0,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // Floating particles
          LayoutBuilder(
            builder: (context, constraints) => FloatingParticles(
              areaSize: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),
        ],
      ),
    );
  }
}
