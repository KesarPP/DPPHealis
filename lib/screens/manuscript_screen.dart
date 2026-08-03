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
import '../widgets/bouncing_button.dart';
import '../widgets/page_turn_widget.dart';

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
  late final Animation<double> _buttonCompress;
  late final Animation<double> _journalLift;
  late final Animation<double> _claspOpen;
  late final Animation<double> _coverAngle;
  late final Animation<double> _pagesOpacity;
  late final Animation<double> _pageRipple;

  late final AnimationController _idleController;
  late final Animation<double> _idleFloat;

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
      duration: const Duration(milliseconds: 1600), // Extended for complex sequence
    );

    _buttonCompress = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _coverController,
        curve: const Interval(0.0, 0.1, curve: Curves.easeIn),
      ),
    );

    _journalLift = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(
        parent: _coverController,
        curve: const Interval(0.1, 0.25, curve: Curves.easeOutCubic),
      ),
    );

    _claspOpen = Tween<double>(begin: 0.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _coverController,
        curve: const Interval(0.2, 0.35, curve: Curves.easeInBack),
      ),
    );

    // Swings the cover open from 0 to -165 degrees (-2.88 radians) along spine
    _coverAngle = Tween<double>(begin: 0.0, end: -2.88).animate(
      CurvedAnimation(
        parent: _coverController,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutBack), // Natural bounce
      ),
    );

    _pagesOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _coverController,
        curve: const Interval(0.35, 0.45, curve: Curves.easeOut), // Quick fade in of pages underneath
      ),
    );

    _pageRipple = Tween<double>(begin: 1.02, end: 1.0).animate(
      CurvedAnimation(
        parent: _coverController,
        curve: const Interval(0.85, 1.0, curve: Curves.elasticOut), // Page settling ripple
      ),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _idleFloat = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _idleController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _coverController.dispose();
    _idleController.dispose();
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
                            letterSpacing: 0.5, // Increased spacing
                          ),
                        ),
                        TextSpan(
                          text: 'Health\n',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD96B85),
                            letterSpacing: 0.5,
                            height: 1.2, // Improved vertical spacing
                          ),
                        ),
                        TextSpan(
                          text: 'Journal',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E5339),
                            letterSpacing: 0.5,
                            height: 1.2,
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
        children: <Widget>[
          // Base Ambient Background
          const AncientBookBackground(child: SizedBox.expand()),
          
          // Render Cover or Pages based on state
          if (_isBookOpen)
            _OpenBookInterior(
              weeks: weeks,
              rowHeight: _rowHeight,
              horizontalInset: _cardHorizontalInset,
              onCloseBook: _closeBook,
            )
          else
            _BookCoverPage(onOpen: _openBook),

          // Header Overlay when closed (Title + Quote)
          if (!_isBookOpen && !_isOpening)
            _buildHeaderCard(context),
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
  final GlobalKey<PageTurnWidgetState> _pageTurnKey = GlobalKey<PageTurnWidgetState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _nextPage() {
    _pageTurnKey.currentState?.nextPage();
  }

  void _prevPage() {
    _pageTurnKey.currentState?.prevPage();
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
    return BouncingButton(
      onTap: onTap,
      scaleFactor: 0.96, // Slight 2-3px compression equivalent
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), // Increased breathing room
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFBF7), // Premium warm paper
          borderRadius: BorderRadius.circular(6), // Slightly rounded paper strip
          border: Border.all(color: baseColor.withValues(alpha: 0.3), width: 1),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFDFBF7),
              baseColor.withValues(alpha: bgAlpha + 0.05),
            ],
          ),
          boxShadow: [
            // Inner shadow for slight embossing
            BoxShadow(
              color: Colors.white,
              offset: const Offset(-1, -1),
              blurRadius: 1,
            ),
            // Realistic sharp paper shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(1, 3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left circular icon
            if (showIcons) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: baseColor.withValues(alpha: 0.1),
                  border: Border.all(color: baseColor.withValues(alpha: 0.4), width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      offset: Offset(-1, -1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Icon(leftIcon, color: baseColor.withValues(alpha: 0.9), size: 18),
              ),
              const SizedBox(width: 12),
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
                      fontSize: 13,
                      color: const Color(0xFF2E5339),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: showIcons ? TextAlign.left : TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia', // Switched from Roboto to Georgia
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF2E5339).withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            // Right Arrow
            if (showIcons)
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: baseColor.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkButton({
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return BouncingButton(
      onTap: onTap,
      scaleFactor: 0.95,
      child: Container(
        height: 48, // Explicit height to prevent crushing by IntrinsicHeight
        margin: const EdgeInsets.only(bottom: 12), // Matching the bottom margin of action cards
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9ED), // Richer cream color to contrast with the page
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          border: Border(
            top: BorderSide(color: color.withValues(alpha: 0.6), width: 4), // Stronger fold highlight
            left: BorderSide(color: Colors.black.withValues(alpha: 0.08), width: 1),
            right: BorderSide(color: Colors.black.withValues(alpha: 0.08), width: 1),
            bottom: BorderSide(color: Colors.black.withValues(alpha: 0.15), width: 1.5),
          ),
          boxShadow: [
            // Very subtle fold detail shadow, no heavy shadows
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color, // Fully opaque text
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildEmbossedIcon(IconData icon, Color color, double size) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7), // Warm ivory paper tone
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
        boxShadow: [
          // Laminated drop shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(1, 2),
            blurRadius: 3,
          ),
          // Emboss highlight
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-1, -1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: color.withValues(alpha: 0.8), size: size),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageTurnWidget(
          key: _pageTurnKey,
          leftPage: Stack(
            fit: StackFit.expand,
            children: [
              ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/session_timeline/manuscript_page_left_new.png',
                        fit: BoxFit.contain, // Changed from cover to contain to fit its native rounded corners
                        errorBuilder: (c, e, s) => const SizedBox.shrink(),
                      ),
                      // Paper texture overlay
                      IgnorePointer(
                        child: Container(
                          color: const Color(0xFFFAF7F2).withValues(alpha: 0.15), // Warm ivory tint
                        ),
                      ),
                      // Gutter Shadow (Ambient Occlusion)
                      IgnorePointer(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.black.withValues(alpha: 0.25),
                                  Colors.black.withValues(alpha: 0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Outer container for the gradient border
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Container(
                                    padding: const EdgeInsets.all(8), // This forms the thick gradient border
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFE5B96E), // Pastel Gold
                                          Color(0xFFFDFBF7), // Warm paper
                                          Color(0xFFD4AF37), // Metallic Gold
                                          Color(0xFFFFF8DC), // Cornsilk
                                        ],
                                        stops: [0.0, 0.3, 0.7, 1.0],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFD96B85).withValues(alpha: 0.15),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6), // Light neutral gray/white for video area
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          // Soft ambient background circles
                                          Positioned(
                                            top: -20,
                                            right: -20,
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(0xFFFFB6C1).withValues(alpha: 0.2),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: -30,
                                            left: 20,
                                            child: Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(0xFFB0E0E6).withValues(alpha: 0.2),
                                              ),
                                            ),
                                          ),
                                          // Sparkles
                                          const Positioned(top: 20, left: 40, child: Text('✨', style: TextStyle(fontSize: 10))),
                                          const Positioned(bottom: 30, right: 50, child: Text('✨', style: TextStyle(fontSize: 14))),
                                          const Positioned(top: 40, right: 30, child: Icon(Icons.eco, color: Color(0xFFC1E1C1), size: 14)),
                                          const Positioned(bottom: 20, left: 60, child: Icon(Icons.eco, color: Color(0xFFC1E1C1), size: 12)),
                                          
                                          // Big Play Button
                                          Center(
                                            child: BouncingButton(
                                              onTap: () {
                                                // Handle video play
                                              },
                                              child: Container(
                                                width: 55,
                                                height: 55,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.15),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: const Center(
                                                  child: Icon(Icons.play_arrow_rounded, color: Color(0xFFFF4757), size: 36),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Decorative Elements overlapping the border
                                // Top Left Heart Monitor
                                Positioned(
                                  top: -10,
                                  left: 15,
                                  child: _buildEmbossedIcon(Icons.favorite_rounded, const Color(0xFFFF6B81), 18),
                                ),
                                // Top Right Water Drop
                                Positioned(
                                  top: -22,
                                  right: 5,
                                  child: Transform.rotate(
                                    angle: 0.2,
                                    child: _buildEmbossedIcon(Icons.water_drop_rounded, const Color(0xFF64B5F6), 24),
                                  ),
                                ),
                                // Bottom Left Shoes
                                Positioned(
                                  bottom: -20,
                                  left: -15,
                                  child: Transform.rotate(
                                    angle: -0.15,
                                    child: _buildEmbossedIcon(Icons.directions_run_rounded, const Color(0xFFFF9800), 28),
                                  ),
                                ),
                                // Bottom Center Health Icon
                                Positioned(
                                  bottom: -12,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: _buildEmbossedIcon(Icons.monitor_heart_rounded, const Color(0xFF4ADE80), 20),
                                  ),
                                ),
                                // Bottom Right Salad
                                Positioned(
                                  bottom: -20,
                                  right: -15,
                                  child: Transform.rotate(
                                    angle: 0.1,
                                    child: _buildEmbossedIcon(Icons.restaurant_rounded, const Color(0xFF81C784), 28),
                                  ),
                                ),
                                
                                // Extra Leaves
                                Positioned(
                                  top: -20,
                                  left: -15,
                                  child: Transform.rotate(
                                    angle: -0.3,
                                    child: _buildEmbossedIcon(Icons.eco_rounded, const Color(0xFFC5E1A5), 20),
                                  ),
                                ),
                                Positioned(
                                  top: -5,
                                  right: -25,
                                  child: Transform.rotate(
                                    angle: 0.5,
                                    child: _buildEmbossedIcon(Icons.eco_rounded, const Color(0xFFC5E1A5), 18),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  right: -30,
                                  child: Transform.rotate(
                                    angle: 2.2,
                                    child: _buildEmbossedIcon(Icons.eco_rounded, const Color(0xFFC5E1A5), 16),
                                  ),
                                ),
                              ],
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
                            _pageTurnKey.currentState?.nextPage();
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
            rightPage: Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/session_timeline/manuscript_page_right_new.png',
                        fit: BoxFit.contain, // Fit like a page without cropping or zooming
                        errorBuilder: (c, e, s) => const SizedBox.shrink(),
                      ),
                      // Paper texture overlay
                      IgnorePointer(
                        child: Container(
                          color: const Color(0xFFFAF7F2).withValues(alpha: 0.15), // Warm ivory tint
                        ),
                      ),
                      // Gutter Shadow (Ambient Occlusion)
                      IgnorePointer(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withValues(alpha: 0.25),
                                  Colors.black.withValues(alpha: 0.05),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Tab Depth Shadow (Right Edge)
                      IgnorePointer(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: 25,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                colors: [
                                  Colors.black.withValues(alpha: 0.12),
                                  Colors.black.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                              child: _buildBookmarkButton(
                                title: 'Previous Page',
                                color: const Color(0xFFD4AF37), // Muted Gold
                                onTap: () => _pageTurnKey.currentState?.prevPage(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildBookmarkButton(
                                title: 'Close Book',
                                color: const Color(0xFFE57373), // Muted Rose
                                onTap: widget.onCloseBook,
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
          Stack(
            fit: StackFit.expand,
            children: [
              // Contact Shadow (Grounding)
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  widthFactor: 0.85,
                  heightFactor: 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        // Deep contact shadow directly underneath
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        // Soft bounce shadow spreading outward
                        BoxShadow(
                          color: const Color(0xFF3E2723).withValues(alpha: 0.3),
                          blurRadius: 80,
                          offset: const Offset(0, 30),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
              // Clasp Ambient Occlusion (Right Edge)
              Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.2,
                  heightFactor: 0.4,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.centerRight,
                        radius: 1.0,
                        colors: [
                          Colors.black.withValues(alpha: 0.4), // Darker near clasp
                          Colors.black.withValues(alpha: 0.0), // Fades out
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Gold Medallion Specular Highlight
              AnimatedBuilder(
                animation: _specularController,
                builder: (context, child) {
                  final progress = _specularController.value;
                  return Center(
                    child: Container(
                      width: 140, // Match medallion size approx
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Realistic drop shadow for medallion resting on leather
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        // Inner bevel shadow approximation
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 2.0,
                        ),
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) {
                          return SweepGradient(
                            center: Alignment.center,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.9), // Bright metallic reflection
                              const Color(0xFFD4AF37).withValues(alpha: 0.5), // Brushed bronze tone
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.8), // Secondary reflection
                              const Color(0xFFD4AF37).withValues(alpha: 0.4),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.15, 0.25, 0.5, 0.65, 0.75, 1.0],
                            transform: GradientRotation(progress * 4 * math.pi),
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.screen,
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Subtle Leather Texture Overlay
              IgnorePointer(
                child: Opacity(
                  opacity: 0.04,
                  child: Image.asset(
                    'assets/images/backgrounds/noise_texture.png', // Assuming a standard noise texture exists, or we use a basic color blend
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.brown, // fallback blend
                    ),
                    colorBlendMode: BlendMode.overlay,
                  ),
                ),
              ),
            ],
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
