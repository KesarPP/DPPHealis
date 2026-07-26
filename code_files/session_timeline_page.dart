import 'package:flutter/material.dart';
import '../models/week_model.dart';
import '../theme/manuscript_theme.dart';
import '../widgets/ancient_book_background.dart';
import '../widgets/floating_particles.dart';
import '../widgets/glowing_path.dart';
import '../widgets/session_week_card.dart';
import '../widgets/timeline_header.dart';
import 'session_detail_page.dart';

/// Phase 1 — Gamified Session Timeline.
///
/// Presents each NDPP week as a collectible "chapter" card along a
/// winding, glowing manuscript trail. Purely presentational for now: data
/// comes from [generateDummyWeeks] — swap that call for a real sessions
/// repository once the service layer lands, nothing else here needs to
/// change. Navigation to [SessionDetailPage] is a placeholder; Phase 2
/// owns the actual lesson/quiz/meal/activity content.
class SessionTimelinePage extends StatelessWidget {
  const SessionTimelinePage({super.key});

  static const double _rowHeight = 248;
  static const double _cardHorizontalInset = 20;

  @override
  Widget build(BuildContext context) {
    final weeks = generateDummyWeeks();

    return Scaffold(
      backgroundColor: ManuscriptColors.parchment,
      body: AncientBookBackground(
        // Drop a real manuscript/parchment texture at this path and it
        // renders automatically — see AncientBookBackground for the
        // gradient fallback used while it's missing.
        backgroundAsset: 'assets/images/backgrounds/manuscript_bg.png',
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: FloatingParticles(
                      areaSize: Size(constraints.maxWidth, constraints.maxHeight),
                    ),
                  ),
                  CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(child: TimelineHeader()),
                      SliverToBoxAdapter(
                        child: _Timeline(
                          weeks: weeks,
                          rowHeight: _rowHeight,
                          horizontalInset: _cardHorizontalInset,
                        ),
                      ),
                      const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Lays out the alternating chapter cards and the glowing connective path
/// behind them, using a fixed row height per week so both can share the
/// same anchor-point math.
class _Timeline extends StatelessWidget {
  final List<WeekModel> weeks;
  final double rowHeight;
  final double horizontalInset;

  const _Timeline({
    required this.weeks,
    required this.rowHeight,
    required this.horizontalInset,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final contentHeight = weeks.length * rowHeight;

        final anchors = List.generate(weeks.length, (i) {
          final x = i.isEven ? width * 0.30 : width * 0.70;
          final y = i * rowHeight + rowHeight / 2;
          return Offset(x, y);
        });

        return SizedBox(
          height: contentHeight,
          width: width,
          child: Stack(
            children: [
              Positioned.fill(
                child: RepaintBoundary(
                  child: GlowingPath(
                    anchors: anchors,
                    canvasSize: Size(width, contentHeight),
                  ),
                ),
              ),
              Column(
                children: List.generate(weeks.length, (i) {
                  final week = weeks[i];
                  final alignLeft = i.isEven;

                  return SizedBox(
                    height: rowHeight,
                    child: Align(
                      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalInset),
                        child: _StaggeredEntrance(
                          index: i,
                          child: SessionWeekCard(
                            week: week,
                            alignment: alignLeft ? CardAlignment.left : CardAlignment.right,
                            onTap: week.locked
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => SessionDetailPage(week: week),
                                      ),
                                    );
                                  },
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Fades + slides a child in shortly after first frame, staggered by
/// [index] so cards reveal one after another like an unrolling scroll,
/// rather than popping in all at once.
class _StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredEntrance({required this.index, required this.child});

  @override
  State<_StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<_StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ManuscriptMotion.cardEntrance,
    );
    _fade = CurvedAnimation(parent: _controller, curve: ManuscriptMotion.entranceCurve);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(_fade);

    Future.delayed(ManuscriptMotion.cardStagger * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
