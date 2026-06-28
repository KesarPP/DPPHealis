import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/gelato_theme.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_hero_cards.dart';
import '../widgets/dashboard_timeline.dart';
import '../widgets/dashboard_risk_card.dart';
import '../widgets/dashboard_momentum.dart';
import '../widgets/dashboard_achievements.dart';
import '../widgets/user_side_drawer.dart';
import '../services/health_sync_service.dart';
import '../services/activity_metrics_engine.dart';
import '../services/achievements_service.dart';
import '../models/ndpp_constants.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Achievement> _achievements = [];
  List<DailyAggregate> _past30Days = [];
  bool _isLoading = true;

  // Coach Tour Guide State
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _selectedCoach;
  bool _isLoadingCoach = true;
  bool _showTourGuide = true;
  bool _isPlayingVoice = false;
  late FlutterTts _flutterTts;
  int _tourStep = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> _tourScripts = [
    "Welcome to your dashboard! Let's take a quick look around.",
    "First, here is your Weight Journey screen, where you can log and track your weight progress.",
    "At the bottom, you can tap the Food icon to track and log your daily meals.",
    "Next is the Activity tab, where you can view your steps and log exercise.",
    "Under the Sessions tab, you will find and complete your educational lessons.",
    "Tap the Coach tab to chat directly with me, your personal lifestyle coach.",
    "And finally, this top-right menu opens your sidebar where you can view your IDRS Scorecard, GPAQ scorecard, weekly weigh-in history, FFQ, and Handouts Library!"
  ];

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _fetchAssignedCoach();
    _loadData();
  }

  Future<void> _fetchAssignedCoach() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        final coachId = userDoc.data()?['assignedCoachId'];
        if (coachId != null) {
          final coachDoc = await _firestore.collection('coaches').doc(coachId).get();
          if (coachDoc.exists) {
            setState(() {
              _selectedCoach = coachDoc.data();
              _isLoadingCoach = false;
            });
            _speakIntro();
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching assigned coach: $e');
    }
    setState(() {
      _isLoadingCoach = false;
    });
  }

  int _getCoachAvatarIndex() {
    if (_selectedCoach == null) return 1;
    final localPath = _selectedCoach!['localImagePath'] as String?;
    int? avatarIndex;
    if (localPath != null && localPath.startsWith('avatar_')) {
      avatarIndex = int.tryParse(localPath.replaceFirst('avatar_', ''));
    }
    avatarIndex ??= _selectedCoach!['avatarIndex'] as int?;
    return (avatarIndex ?? 0) + 1; // 1-based index matching new files
  }

  bool _isFemaleCoach() {
    final fileIndex = _getCoachAvatarIndex();
    return fileIndex % 2 == 0;
  }

  Future<void> _speakIntro() async {
    if (_selectedCoach == null) return;
    
    final isFemale = _isFemaleCoach();
    final text = _tourScripts[_tourStep];

    if (mounted) {
      setState(() {
        _isPlayingVoice = true;
      });
    }

    await _flutterTts.setLanguage("en-US");
    
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      Map<String, String>? targetVoice;
      
      for (var voice in voices) {
        if (voice is Map) {
          final name = voice['name']?.toString().toLowerCase() ?? '';
          final locale = voice['locale']?.toString() ?? '';
          if (locale.startsWith('en')) {
            if (isFemale && (name.contains('female') || name.contains('zira') || name.contains('samantha') || name.contains('a') || name.contains('c') || name.contains('d') || name.contains('network'))) {
              targetVoice = Map<String, String>.from(voice.cast<String, String>());
              break;
            } else if (!isFemale && (name.contains('male') || name.contains('david') || name.contains('b') || name.contains('e') || name.contains('keynote'))) {
              targetVoice = Map<String, String>.from(voice.cast<String, String>());
              break;
            }
          }
        }
      }
      
      if (targetVoice != null) {
        await _flutterTts.setVoice(targetVoice);
      } else {
        await _flutterTts.setPitch(isFemale ? 1.35 : 0.85);
      }
    } catch (e) {
      await _flutterTts.setPitch(isFemale ? 1.35 : 0.85);
    }

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlayingVoice = false;
        });
      }
    });

    _flutterTts.setErrorHandler((_) {
      if (mounted) {
        setState(() {
          _isPlayingVoice = false;
        });
      }
    });

    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Widget _buildTourGuideOverlay() {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final padding = mediaQuery.padding;

    // Calculate spotlight rect for each step
    Rect? spotlightRect;
    switch (_tourStep) {
      case 1:
        // Weight Card (Top left card in DashboardHeroCards)
        spotlightRect = Rect.fromLTWH(
          16,
          padding.top + 70, // Below header
          size.width / 2 - 24,
          235,
        );
        break;
      case 2:
        // Food Tab
        spotlightRect = Rect.fromLTWH(
          (size.width / 5) * 1 + 6,
          size.height - 85,
          size.width / 5 - 12,
          75,
        );
        break;
      case 3:
        // Activity Tab
        spotlightRect = Rect.fromLTWH(
          (size.width / 5) * 2 + 6,
          size.height - 85,
          size.width / 5 - 12,
          75,
        );
        break;
      case 4:
        // Sessions Tab
        spotlightRect = Rect.fromLTWH(
          (size.width / 5) * 3 + 6,
          size.height - 85,
          size.width / 5 - 12,
          75,
        );
        break;
      case 5:
        // Coach Tab
        spotlightRect = Rect.fromLTWH(
          (size.width / 5) * 4 + 6,
          size.height - 85,
          size.width / 5 - 12,
          75,
        );
        break;
      case 6:
        // Sidebar Menu button (Top right)
        spotlightRect = Rect.fromLTWH(
          size.width - 64,
          padding.top + 12,
          48,
          48,
        );
        break;
      default:
        spotlightRect = null;
        break;
    }

    return Positioned.fill(
      child: Stack(
        children: [
          // Spotlight overlay with custom cutout painting
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: CustomPaint(
                painter: SpotlightPainter(targetRect: spotlightRect),
              ),
            ),
          ),
          
          // Tour guide content
          Positioned(
            left: 16,
            right: 16,
            bottom: (_tourStep == 2 || _tourStep == 3 || _tourStep == 4 || _tourStep == 5)
                ? 120 // Position bubble higher when pointing to bottom tabs
                : 16, // Default bottom position
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cloud Thought Bubble
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.black, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(4, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _selectedCoach?['name'] ?? 'Coach',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _tourScripts[_tourStep],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: GelatoTheme.textDark,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Mute / Unmute Button
                          IconButton(
                            onPressed: () {
                              if (_isPlayingVoice) {
                                _flutterTts.stop();
                                setState(() {
                                  _isPlayingVoice = false;
                                });
                              } else {
                                _speakIntro();
                              }
                            },
                            icon: Icon(
                              _isPlayingVoice ? Icons.volume_up : Icons.volume_off,
                              color: Colors.black87,
                              size: 24,
                            ),
                          ),
                          Row(
                            children: [
                              // Skip Button
                              TextButton(
                                onPressed: () {
                                  _flutterTts.stop();
                                  _scaffoldKey.currentState?.closeEndDrawer();
                                  setState(() {
                                    _showTourGuide = false;
                                    _isPlayingVoice = false;
                                  });
                                },
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Next / Finish Button
                              ElevatedButton(
                                onPressed: () {
                                  if (_tourStep < _tourScripts.length - 1) {
                                    setState(() {
                                      _tourStep++;
                                    });
                                    if (_tourStep == 6) {
                                      _scaffoldKey.currentState?.openEndDrawer();
                                    }
                                    _speakIntro();
                                  } else {
                                    _flutterTts.stop();
                                    _scaffoldKey.currentState?.closeEndDrawer();
                                    setState(() {
                                      _showTourGuide = false;
                                      _isPlayingVoice = false;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GelatoTheme.purple,
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Colors.black, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                child: Text(
                                  _tourStep < _tourScripts.length - 1 ? 'Next' : 'Finish',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Cloud thought bubble trails pointing to bottom-left
                if (!(_tourStep == 2 || _tourStep == 3 || _tourStep == 4 || _tourStep == 5)) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 60.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2.0),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
                ],
                const SizedBox(height: 12),

                // Coach Portrait at the bottom-left
                if (!(_tourStep == 2 || _tourStep == 3 || _tourStep == 4 || _tourStep == 5))
                  Container(
                    height: 250,
                    width: 180,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Image.asset(
                      'assets/images/coaches/coach_${_getCoachAvatarIndex()}.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomLeft,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    try {
      final healthSync = HealthSyncService();
      try {
        await healthSync.requestPermissions().timeout(const Duration(seconds: 4));
      } catch (e) {
        debugPrint('Dashboard requestPermissions error: $e');
      }
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 29));
      List<DailyAggregate> past30Days = [];
      try {
        past30Days = await healthSync.getStatsForInterval(startTime: thirtyDaysAgo, endTime: now).timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Dashboard getStatsForInterval error: $e');
      }
      
      if (past30Days.isEmpty) {
        for (int i = 29; i >= 0; i--) {
          past30Days.add(DailyAggregate.empty(now.subtract(Duration(days: i))));
        }
      }
      
      const int programWeek = 6;

      final achievements = await AchievementsService.evaluateAndSync(
        trailing30Days: past30Days,
        programWeek: programWeek,
        context: mounted ? context : null,
      );

      if (mounted) {
        setState(() {
          _achievements = achievements;
          _past30Days = past30Days;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Dashboard loadData overall error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF3E8FF).withValues(alpha: 0.5),
      endDrawer: const UserSideDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DotsPainter(color: GelatoTheme.purpleDark.withValues(alpha: 0.05)),
              ),
            ),
            IgnorePointer(
              ignoring: _showTourGuide,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                // 1. Dashboard Header
                const SliverToBoxAdapter(
                  child: DashboardHeader(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // 2. Hero Progress Area (Weight & Activity)
                SliverToBoxAdapter(
                  child: _isLoading
                      ? const SizedBox(height: 480, child: Center(child: CircularProgressIndicator()))
                      : DashboardHeroCards(trailing30Days: _past30Days, programWeek: 6),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 3. Today's Mission (Timeline)
                SliverToBoxAdapter(
                  child: _isLoading
                      ? const SizedBox(height: 180, child: Center(child: CircularProgressIndicator()))
                      : DashboardTimeline(
                          todayAgg: _past30Days.isNotEmpty ? _past30Days.last : null,
                          mealLogCount: 2,
                          waterLogged: true,
                          weightLogged: true,
                          lessonCompleted: true,
                          journalLogged: false,
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 4. Prediabetes Risk Card (Compact)
                const SliverToBoxAdapter(
                  child: DashboardRiskCard(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 5. Your Momentum
                const SliverToBoxAdapter(
                  child: DashboardMomentum(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // 6. Achievement Showcase
                SliverToBoxAdapter(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator()) 
                    : DashboardAchievements(achievements: _achievements),
                ),
                
                // Bottom Padding for BottomNavigationBar
                const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
              ],
            ),
          ),
          if (_showTourGuide && _selectedCoach != null)
            _buildTourGuideOverlay(),
        ],
      ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color color;
  const _DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double gridSize = 16.0;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x <= size.width; x += gridSize) {
      for (double y = 0; y <= size.height; y += gridSize) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) => oldDelegate.color != color;
}

class SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final double borderRadius;

  SpotlightPainter({this.targetRect, this.borderRadius = 16.0});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final screenPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (targetRect == null) {
      canvas.drawPath(screenPath, backgroundPaint);
      return;
    }

    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(targetRect!, Radius.circular(borderRadius)));

    final resultPath = Path.combine(PathOperation.difference, screenPath, cutoutPath);
    canvas.drawPath(resultPath, backgroundPaint);

    final borderPaint = Paint()
      ..color = GelatoTheme.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRRect(RRect.fromRectAndRadius(targetRect!, Radius.circular(borderRadius)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect || oldDelegate.borderRadius != borderRadius;
  }
}
