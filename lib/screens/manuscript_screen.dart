import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/week_model.dart';
import '../theme/manuscript_theme.dart';
import '../widgets/ancient_book_background.dart';
import '../widgets/floating_particles.dart';

class ManuscriptScreen extends StatefulWidget {
  const ManuscriptScreen({super.key});

  @override
  State<ManuscriptScreen> createState() => _ManuscriptScreenState();
}

class _ManuscriptScreenState extends State<ManuscriptScreen>
    with SingleTickerProviderStateMixin {
  static const double _rowHeight = 248;
  static const double _cardHorizontalInset = 20;

  bool _isBookOpen = false;
  bool _isOpening = false;
  late final AnimationController _coverController;
  late final Animation<double> _coverAngle;
  late final Animation<double> _pagesOpacity;

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
              ..rotateX(-0.15),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.15,
                  bottom: MediaQuery.of(context).size.height * 0.12,
                  left: MediaQuery.of(context).size.width * 0.12,
                  right: MediaQuery.of(context).size.width * 0.12,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
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
          ),

          // 3. 3D Swinging Book Cover Overlay and bottom unlock button sitting right on the desk bg image
          if (!_isBookOpen || _isOpening)
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015)
                        ..rotateX(-0.15),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.15,
                          bottom: 20,
                          left: MediaQuery.of(context).size.width * 0.12,
                          right: MediaQuery.of(context).size.width * 0.12,
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
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: _BookCoverPage(
                                        onOpen: _openBook,
                                      ),
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
                          bottom: MediaQuery.of(context).size.height * 0.02, // moved down exactly
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
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
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
                    'assets/images/session_timeline/manuscript_page_left.png',
                    fit: BoxFit.contain, // Changed from cover to contain to fit its native rounded corners
                    errorBuilder: (c, e, s) => const SizedBox.shrink(),
                  ),
                ),
                // Navigation prompt at bottom right of the left page
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: _nextPage,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
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
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'TURN PAGE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
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
                    'assets/images/session_timeline/manuscript_page_right.png',
                    fit: BoxFit.contain, // Fit like a page without cropping or zooming
                    errorBuilder: (c, e, s) => const SizedBox.shrink(),
                  ),
                ),
                // Navigation controls at bottom of the right page wrapped in Expanded to prevent any overflow
                Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _prevPage,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
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
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'PREVIOUS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // Clean 10px spacing between buttons
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onCloseBook,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
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
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'CLOSE BOOK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.1,
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
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
          // Book Cover Asset (Pure cropped leather cover art)
          ClipRect(
            child: Image.asset(
              'assets/images/session_timeline/book_cover_transparent.png',
              fit: BoxFit.contain, // Use contain so the pink book cover fits entirely in the padding
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/backgrounds/manuscript_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const SizedBox.shrink(),
              ),
            ),
          ),
          // Subtle Gold Border Vignette (Removed because user's image provides it natively)
          // Floating particles
          LayoutBuilder(
            builder: (context, constraints) => FloatingParticles(
              areaSize: Size(constraints.maxWidth, constraints.maxHeight),
            ),
          ),
          // Clasp & Unlock Prompt positioned down lower on the cover without any checkerboard
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // The clasp lock overlay has been removed to rely purely on the background image.
                const Spacer(flex: 2), // Clean spacing below where padlock used to be
              ],
            ),
          ),
        ],
      ),
    );
  }
}
