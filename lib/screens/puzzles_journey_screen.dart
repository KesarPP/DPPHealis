import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../main.dart';
import '../data/gelato_theme.dart';
import '../data/handouts_data.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/food_notifiers.dart';
import '../repositories/activity_log_repository_impl.dart';
import '../services/firestore_activity_log_service.dart';
import 'food_tracking_screen.dart';
import 'activity_fitness_screen.dart';
import 'handouts_screen.dart';

class PuzzlesJourneyScreen extends StatefulWidget {
  const PuzzlesJourneyScreen({super.key});

  @override
  State<PuzzlesJourneyScreen> createState() => _PuzzlesJourneyScreenState();
}

class _PuzzlesJourneyScreenState extends State<PuzzlesJourneyScreen> {
  final TransformationController _transformationController = TransformationController();

  // Define canvas size
  final double canvasWidth = 600;
  final double canvasHeight = 1600;

  int _currentPawnLevel = 1;
  int? _selectedNode;
  double? _selectedNodeX;
  double? _selectedNodeY;

  bool _isCardsCollapsed = false;
  double? _initialY;
  
  int _todayActivityMinutes = 0;
  int _todaySteps = 0;

  @override
  void initState() {
    super.initState();
    _loadTodayActivity();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size screenSize = MediaQuery.of(context).size;
      final double scale = screenSize.width / canvasWidth; // Reset to fit exactly one width (same as old FittedBox)
      
      final Matrix4 matrix = Matrix4.identity()
        ..translate(
          0.0, // Aligned to left
          -(canvasHeight * scale - screenSize.height) - 150, // Pushed up to show node 1 clearly above cards
        )
        ..scale(scale);
        
      _transformationController.value = matrix;
    });

    double? lastY;
    _transformationController.addListener(() {
      final y = _transformationController.value.getTranslation().y;
      if (lastY == null) {
        lastY = y;
        return;
      }

      final dy = y - lastY!;
      // Scrolling up (map moving up, y increasing) -> collapse
      if (dy > 2.0 && !_isCardsCollapsed) {
        setState(() { _isCardsCollapsed = true; });
      } 
      // Scrolling down (map moving down, y decreasing) -> expand
      else if (dy < -2.0 && _isCardsCollapsed) {
        setState(() { _isCardsCollapsed = false; });
      }
      
      lastY = y;
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int cachedSteps = prefs.getInt('hc_cached_steps') ?? 0;
      
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final repo = ActivityLogRepositoryImpl(FirestoreActivityLogService());
        final logs = await repo.getTodayActivityLogs(); // Wait, let's use getTodayActivityLogs
        int mins = logs.fold(0, (sum, log) => sum + log.durationMinutes);
        if (mounted) {
          setState(() {
            _todayActivityMinutes = mins;
            _todaySteps = cachedSteps;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _todaySteps = cachedSteps;
          });
        }
      }
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.green,
      body: Stack(
        children: [
          // 1. Scrollable Zoom Map
          InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            panAxis: PanAxis.vertical,
            scaleEnabled: false,
            boundaryMargin: const EdgeInsets.only(bottom: 400),
            child: SizedBox(
              width: canvasWidth,
              height: canvasHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Isometric Checkerboard Background
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _IsometricCheckerboardPainter(),
                        ),
                      ),
                      
                      // Decorative Trees along the sides
                      ..._buildTrees(),
                      
                      // Path Nodes (bottom to top)
                      _buildNode(1, 400, 1400, isCompleted: true),
                      _buildNode(2, 330, 1310, isCompleted: true),
                      _buildNode(3, 260, 1220, isCompleted: true),
                      _buildNode(4, 190, 1130, isCompleted: true),
                      _buildNode(5, 120, 1040, isCompleted: true),



                      _buildNode(6, 180, 950, isCompleted: true),
                      _buildNode(7, 240, 860, isCompleted: true),
                      _buildNode(8, 300, 770, isCompleted: true),
                      _buildNode(9, 360, 680, isCompleted: true),
                      _buildNode(10, 310, 590, isCompleted: true),
                      _buildNode(11, 260, 500, isCompleted: true),
                      _buildNode(12, 210, 410, isCompleted: true),
                      _buildNode(13, 160, 320, isCompleted: true),
                      // Locked levels in clouds
                      _buildNode(14, 210, 230, isCompleted: false),
                      _buildNode(15, 260, 140, isCompleted: false),
                      _buildNode(16, 310, 50, isCompleted: false),

                      // Clouds (Obscuring future levels)
                      Positioned(
                        top: 0,
                        left: -100,
                        right: -100,
                        height: 480, // Covers upper half down to level 12 (y=410)
                        child: _buildCloudsArea(),
                      ),

                      // Player Pawn Mascot! Travels from level 1 to 2
                      AnimatedPositioned(
                        duration: const Duration(seconds: 2),
                        curve: Curves.easeInOutCubic,
                        left: (_currentPawnLevel == 1 ? 400.0 : 330.0) + 10, // Offset to center on stump
                        top: (_currentPawnLevel == 1 ? 1400.0 : 1310.0) - 45, // Shifted up so feet rest on top
                        child: _PlayerPawn(),
                      ),
                      
                      // Dropdown Menu (on top of everything, centered above the block)
                      if (_selectedNode != null && _selectedNodeX != null && _selectedNodeY != null)
                        Positioned(
                          left: _selectedNodeX! - 105, // Center the 300px wide dropdown above the 90px wide block
                          bottom: canvasHeight - _selectedNodeY! + 10, // Place 10px above the top of the block
                          child: _buildDropdownMenu(_selectedNode!),
                        ),
                    ],
                  ),
                ),
              ),
          
          // 4. Bottom UI Overlay - Floating Cards
          Positioned(
            bottom: 120,
            left: 20,
            child: _buildMealLogCard(context),
          ),
          Positioned(
            bottom: 120,
            right: 20,
            child: _buildActivityCard(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(int number, double x, double y, {required bool isCompleted}) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () {
          // Redirect to Journal tab when clicking a level
          MainShell.of(context)?.selectedIndex = 1;
        },
        child: _ColorfulBlockNode(number: number, isHighlighted: _currentPawnLevel == number),
      ),
    );
  }

  Widget _buildMealLogCard(BuildContext context) {
    // Dynamic meal count from FoodDiaryNotifier
    final foodNotifier = Provider.of<FoodDiaryNotifier>(context, listen: true);
    final int mealsLogged = foodNotifier.dailyLog?.entries.length ?? 0;
    
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodTrackingScreen())),
      child: Container(
        width: 130, // Increased width
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2), // Gives crisp edges
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 24, spreadRadius: 6, offset: Offset(0, 12)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAB9), // Peach
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: Radius.circular(_isCardsCollapsed ? 16 : 0),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant, color: Color(0xFFD87093), size: 24),
                    SizedBox(height: 4),
                    Text('Meal Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    const Text("Today's Log", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: (mealsLogged / 5).clamp(0.0, 1.0),
                            strokeWidth: 6,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE57373)),
                          ),
                          Center(child: Text("$mealsLogged/5", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Meals Logged", style: TextStyle(fontSize: 10, color: Colors.black54)),
                  ],
                ),
              ),
              crossFadeState: _isCardsCollapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivityFitnessScreen())),
      child: Container(
        width: 130, // Same width as Meal Log card
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 24, spreadRadius: 6, offset: Offset(0, 12)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFBBDEFB), // Light blue
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: Radius.circular(_isCardsCollapsed ? 16 : 0),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_run, color: Color(0xFF1976D2), size: 24),
                    SizedBox(height: 4),
                    Text('Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: Column(
                  children: [
                    const Text("Daily Steps", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text("$_todaySteps / 10000 steps", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_todaySteps / 10000).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
              crossFadeState: _isCardsCollapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownMenu(int number) {
    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Light cream color
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDropdownItem(Icons.play_circle_fill, 'Video', 0.5, true),
          const SizedBox(height: 24),
          _buildDropdownItem(Icons.description, 'Handout', 0.0, false, onTap: () {
            _openSessionHandout(context, number);
          }),
          const SizedBox(height: 24),
          _buildDropdownItem(Icons.quiz, 'Quiz', 0.0, false),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(IconData icon, String title, double progress, bool isStarred, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF795548), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                if (progress > 0) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF455A64)),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isStarred ? Icons.star : Icons.star_border,
            color: isStarred ? const Color(0xFFFFCA28) : Colors.grey.shade300,
            size: 20,
          ),
        ],
      ),
    );
  }

  void _openSessionHandout(BuildContext context, int sessionNumber) {
    ModuleHandout? targetModule;
    SessionHandout? targetSession;
    
    for (var module in ndppHandouts) {
      for (var session in module.sessions) {
        if (session.sessionName.contains('Session $sessionNumber:') || 
            (sessionNumber == 16 && session.sessionName.contains('Module 5'))) {
          targetModule = module;
          targetSession = session;
          break;
        }
      }
      if (targetSession != null) break;
    }

    if (targetModule != null && targetSession != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HandoutsScreen(
            title: 'Session $sessionNumber Handout',
            handouts: [
              ModuleHandout(
                targetModule!.moduleNumber, 
                targetModule.moduleName, 
                [targetSession!],
              )
            ],
          ),
        ),
      );
    }
  }

  List<Widget> _buildTrees() {
    final List<Offset> nodePositions = [
      const Offset(400, 1400), const Offset(330, 1310), const Offset(260, 1220),
      const Offset(190, 1130), const Offset(120, 1040), const Offset(180, 950),
      const Offset(240, 860), const Offset(300, 770), const Offset(360, 680),
      const Offset(310, 590), const Offset(260, 500), const Offset(210, 410),
      const Offset(160, 320), const Offset(210, 230), const Offset(260, 140),
      const Offset(310, 50),
    ];

    final math.Random rng = math.Random(12345); // Fixed seed for consistent layout across rebuilds
    final List<Widget> trees = [];
    final List<Offset> placedTrees = []; // Track centers to prevent clumping

    // Create an extremely dense grid of potential tree spots
    final double step = 35.0;
    for (double y = -100; y < canvasHeight + 300; y += step) {
      for (double x = -150; x < canvasWidth + 150; x += step) {
         
         double px = x + rng.nextDouble() * 50 - 25;
         double py = y + rng.nextDouble() * 50 - 25;
         double size = 130 + rng.nextDouble() * 50; // Random size between 130 and 180
         
         // Only restrict vertical top/bottom extremes to avoid infinite scrolling, 
         // but explicitly allow them to cross the horizontal phone boundaries!
         if (py < -150 || py > canvasHeight + 250) {
            continue;
         }

         double tcx = px + size / 2;
         double tcy = py + size / 2;

         // 1. Keep away from blocks AND the paths connecting them
         bool tooCloseToPath = false;
         for (int i = 0; i < nodePositions.length; i++) {
            var node = nodePositions[i];
            double ncx = node.dx + 45; // center X of 90px wide node
            double ncy = node.dy + 35; // center Y of 70px tall node
            
            double dx = tcx - ncx;
            double dy = tcy - ncy;
            
            // Invisible border radius around blocks
            if (math.sqrt(dx * dx + dy * dy) < 95) {
               tooCloseToPath = true;
               break;
            }

            // Also check the path line connecting to the NEXT node
            if (i < nodePositions.length - 1) {
               var nextNode = nodePositions[i + 1];
               double nextNcx = nextNode.dx + 45;
               double nextNcy = nextNode.dy + 35;
               
               double mx = (ncx + nextNcx) / 2; // Midpoint of the path
               double my = (ncy + nextNcy) / 2;
               
               double mdx = tcx - mx;
               double mdy = tcy - my;
               
               // Keep away from the path lines
               if (math.sqrt(mdx * mdx + mdy * mdy) < 95) {
                  tooCloseToPath = true;
                  break;
               }
            }
         }
         
         if (tooCloseToPath) continue;

         // 2. Keep away from other trees to prevent complete clumping
         bool tooCloseToTree = false;
         for (var other in placedTrees) {
            double dx = tcx - other.dx;
            double dy = tcy - other.dy;
            
            // Minimum distance between trees (increased to provide more breathing room)
            double minDistance = 95;
            
            // Extreme thinning for the space specifically below block 1
            if (py > 1400) {
               minDistance = 140; // Less dense than the sides, but more than before
            }

            if (math.sqrt(dx * dx + dy * dy) < minDistance) {
               tooCloseToTree = true;
               break;
            }
         }

         if (tooCloseToTree) continue;

         // Spot is valid!
         placedTrees.add(Offset(tcx, tcy));
         bool isApple = rng.nextBool();
         trees.add(_buildTree(isApple ? 'apple_tree.png' : 'orange_tree.png', px, py, size));
      }
    }
    return trees;
  }

  Widget _buildTree(String fileName, double x, double y, double size) {
    return Positioned(
      left: x,
      top: y,
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/$fileName',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(), // Hide if file not found
      ),
    );
  }

  Widget _buildCloudsArea() {
    return Stack(
      children: [
        // Subtle fog overlay for the locked area
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.6),
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Stylized puffy anime cloud shapes with floating delays
        // Positioned using 'top' to perfectly cover levels 14, 15, and 16 (Y: 270-410)
        Positioned(left: 30, top: 380, child: _CloudPuff(size: 180, delay: 0.0)),
        Positioned(left: 170, top: 250, child: _CloudPuff(size: 240, delay: 0.5)),
        Positioned(left: 280, top: 320, child: _CloudPuff(size: 200, delay: 1.2)),
        Positioned(left: -60, top: 150, child: _CloudPuff(size: 280, delay: 0.8)),
        Positioned(left: 400, top: 220, child: _CloudPuff(size: 260, delay: 1.5)),
        Positioned(left: 150, top: 100, child: _CloudPuff(size: 190, delay: 0.3)),
      ],
    );
  }

  // --- Scenery Elements ---

  Widget _buildAppleTree() {
    return SizedBox(
      width: 100,
      height: 140,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Trunk
          Container(
            width: 20,
            height: 40,
            decoration: BoxDecoration(color: const Color(0xFF795548), borderRadius: BorderRadius.circular(4)),
          ),
          // Leaves (bottom to top overlapping)
          Positioned(bottom: 30, child: _TreeLeaves(size: 80, hasApples: true)),
          Positioned(bottom: 60, child: _TreeLeaves(size: 70, hasApples: false)),
          Positioned(bottom: 90, child: _TreeLeaves(size: 60, hasApples: true)),
        ],
      ),
    );
  }

  Widget _buildBigTree() {
    return SizedBox(
      width: 120,
      height: 180,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Trunk
          Container(
            width: 24,
            height: 60,
            decoration: BoxDecoration(color: const Color(0xFF8D6E63), borderRadius: BorderRadius.circular(4)),
          ),
          // Leaves
          Positioned(bottom: 50, child: _TreeLeaves(size: 100)),
          Positioned(bottom: 90, child: _TreeLeaves(size: 90)),
          Positioned(bottom: 130, child: _TreeLeaves(size: 70)),
        ],
      ),
    );
  }

  Widget _buildPond() {
    return Container(
      width: 150,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF29B6F6),
        borderRadius: const BorderRadius.all(Radius.elliptical(150, 90)),
        border: Border.all(color: const Color(0xFF0288D1), width: 4),
      ),
      child: Stack(
        children: const [
          Positioned(left: 20, top: 20, child: _LilyPad()),
          Positioned(left: 80, top: 40, child: _LilyPad()),
          Positioned(left: 50, top: 60, child: _LilyPad(size: 15)),
        ],
      ),
    );
  }

  Widget _buildHouse() {
    return SizedBox(
      width: 120,
      height: 140,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Base
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFD7CCC8), // Wooden beige
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF8D6E63), width: 2),
            ),
          ),
          // Door
          Positioned(
            bottom: 0,
            left: 40,
            child: Container(
              width: 30,
              height: 45,
              decoration: const BoxDecoration(
                color: Color(0xFF5D4037),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: const Icon(Icons.shield, color: Colors.green, size: 16),
            ),
          ),
          // Roof
          Positioned(
            top: 20,
            child: CustomPaint(
              size: const Size(120, 50),
              painter: _RoofPainter(),
            ),
          ),
          // Chimney
          Positioned(
            top: 10,
            right: 25,
            child: Container(
              width: 16,
              height: 30,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBench() {
    return SizedBox(
      width: 80,
      height: 60,
      child: Stack(
        children: [
          // Wood planks
          Positioned(top: 20, left: 0, child: Container(width: 80, height: 6, color: const Color(0xFF8D6E63))),
          Positioned(top: 28, left: 0, child: Container(width: 80, height: 6, color: const Color(0xFF8D6E63))),
          Positioned(top: 36, left: 0, child: Container(width: 80, height: 20, color: const Color(0xFF795548))),
          // Chessboard on bench
          Positioned(
            top: 34,
            left: 20,
            child: Container(
              width: 24,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black87, width: 1),
              ),
              child: CustomPaint(painter: _ChessboardPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Custom Painters & Minor Widgets ---

class _IsometricCheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = const Color(0xFFC5D4AB);
    final paintLight = Paint()..color = const Color(0xFFD6E5BD);
    final lockedDark = Paint()..color = const Color(0xFFB5C49B);
    final lockedLight = Paint()..color = const Color(0xFFC5D4AB);

    // Isometric grid dimensions
    const double tileWidth = 80.0;
    const double tileHeight = 40.0;

    // Draw tiles
    for (int y = -20; y < (size.height / tileHeight) + 20; y++) {
      for (int x = -10; x < (size.width / tileWidth) + 10; x++) {
        // Offset alternating rows
        final double offsetX = x * tileWidth + (y % 2 == 0 ? 0 : tileWidth / 2);
        final double offsetY = y * tileHeight;

        final path = Path();
        path.moveTo(offsetX, offsetY - tileHeight / 2); // Top
        path.lineTo(offsetX + tileWidth / 2, offsetY); // Right
        path.lineTo(offsetX, offsetY + tileHeight / 2); // Bottom
        path.lineTo(offsetX - tileWidth / 2, offsetY); // Left
        path.close();

        // Diagonal dividing line representing the "foggy" locked area bounds
        bool isLocked = offsetY < (0.5 * offsetX + 350);
        
        bool isEven = (x + y) % 2 == 0;
        Paint currentPaint = isLocked 
            ? (isEven ? lockedDark : lockedLight) 
            : (isEven ? paintDark : paintLight);

        canvas.drawPath(path, currentPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ColorfulBlockNode extends StatelessWidget {
  final int number;
  final bool isHighlighted;
  const _ColorfulBlockNode({required this.number, this.isHighlighted = false});

  List<Color> _getColorsForNumber(int number) {
    switch (number) {
      case 1: return [const Color(0xFFFFE082), const Color(0xFFFFCA28), const Color(0xFFFFA000)]; // Yellow
      case 2: return [const Color(0xFF80DEEA), const Color(0xFF4DD0E1), const Color(0xFF0097A7)]; // Teal
      case 3: return [const Color(0xFFFFCC80), const Color(0xFFFFB74D), const Color(0xFFF57C00)]; // Peach
      case 4: return [const Color(0xFFEF9A9A), const Color(0xFFE57373), const Color(0xFFD32F2F)]; // Pink-red
      case 5: return [const Color(0xFFF8BBD0), const Color(0xFFF48FB1), const Color(0xFFC2185B)]; // Pink
      case 6: return [const Color(0xFFC8E6C9), const Color(0xFFA5D6A7), const Color(0xFF388E3C)]; // Light Green
      case 7: return [const Color(0xFFB2EBF2), const Color(0xFF80DEEA), const Color(0xFF0097A7)]; // Cyan
      case 8:
      case 9:
      case 10: return [const Color(0xFFE1BEE7), const Color(0xFFCE93D8), const Color(0xFF8E24AA)]; // Purple
      case 11: return [const Color(0xFFBBDEFB), const Color(0xFF90CAF9), const Color(0xFF1976D2)]; // Light blue
      default: return [const Color(0xFFE0E0E0), const Color(0xFFBDBDBD), const Color(0xFF757575)]; // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColorsForNumber(number);
    final Color topColor = colors[0];
    final Color borderColor = colors[1];
    final Color baseColor = colors[2];

    return SizedBox(
      width: 90,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Drop shadow
          Positioned(
            bottom: -2,
            child: Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  isHighlighted
                      ? const BoxShadow(color: Color(0xFFFFD700), blurRadius: 16, offset: Offset(0, 4))
                      : const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 6))
                ],
              ),
            ),
          ),
          // Base depth
          Positioned(
            bottom: 0,
            child: Container(
              width: 90,
              height: 52,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Top surface
          Positioned(
            top: 0,
            child: Container(
              width: 86,
              height: 56,
              decoration: BoxDecoration(
                color: topColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isHighlighted ? const Color(0xFFFFD700) : borderColor,
                  width: isHighlighted ? 4 : 3,
                ),
                boxShadow: [
                  isHighlighted
                      ? BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.8), blurRadius: 8, offset: const Offset(0, -2))
                      : BoxShadow(color: Colors.white.withValues(alpha: 0.6), blurRadius: 2, offset: const Offset(0, -2))
                ],
              ),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Book watermark icon in the background
                  Icon(Icons.menu_book, color: Colors.white.withValues(alpha: 0.4), size: 36),
                  Text(
                    '$number',
                    style: const TextStyle(
                      color: Color(0xFF424242),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
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
}

class _StoneBlockNode extends StatelessWidget {
  final int number;
  const _StoneBlockNode({required this.number});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Drop shadow
          Positioned(
            bottom: -2,
            child: Container(
              width: 56,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 6))
                ]
              ),
            ),
          ),
          // Base depth
          Positioned(
            bottom: 0,
            child: Container(
              width: 66,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB5C49B), Color(0xFF9FB283)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Top surface
          Positioned(
            top: 0,
            child: Container(
              width: 62,
              height: 46,
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0xFFE2F0C9), Color(0xFFC5D4AB)],
                  radius: 0.8,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF9FB283), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.white.withValues(alpha: 0.7), blurRadius: 2, offset: const Offset(0, -2))
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Color(0xFF3B571B),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeLeaves extends StatelessWidget {
  final double size;
  final bool hasApples;
  
  const _TreeLeaves({required this.size, this.hasApples = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF689F38), // Vibrant leaf green
              borderRadius: BorderRadius.all(Radius.elliptical(size, size * 0.8)),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4))
              ]
            ),
          ),
          if (hasApples) ...[
            const Positioned(left: 10, top: 10, child: Icon(Icons.circle, color: Colors.red, size: 8)),
            const Positioned(right: 20, top: 20, child: Icon(Icons.circle, color: Colors.red, size: 8)),
            const Positioned(left: 30, bottom: 15, child: Icon(Icons.circle, color: Colors.red, size: 8)),
          ]
        ],
      ),
    );
  }
}

class _LilyPad extends StatelessWidget {
  final double size;
  const _LilyPad({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF7CB342),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _CloudPuff extends StatefulWidget {
  final double size;
  final double delay;

  const _CloudPuff({required this.size, this.delay = 0});

  @override
  State<_CloudPuff> createState() => _CloudPuffState();
}

class _CloudPuffState extends State<_CloudPuff> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );
    _animation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: SizedBox(
            width: widget.size,
            height: widget.size * 0.7,
            child: CustomPaint(
              painter: _AnimeCloudPainter(),
            ),
          ),
        );
      },
    );
  }
}

class _AnimeCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Path cloudPath = Path();
    // Left puff
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.05, size.height * 0.4, size.width * 0.35, size.height * 0.5));
    // Top-center puff
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.3, size.height * 0.1, size.width * 0.4, size.height * 0.6));
    // Right puff
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.6, size.height * 0.3, size.width * 0.35, size.height * 0.55));
    // Bottom filler
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.15, size.height * 0.5, size.width * 0.7, size.height * 0.45));

    // Inner smaller puffs for extra anime volume
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.4, size.height * 0.3, size.width * 0.3, size.height * 0.4));
    cloudPath.addOval(Rect.fromLTWH(size.width * 0.25, size.height * 0.45, size.width * 0.25, size.height * 0.35));

    final paintStroke = Paint()
      ..color = const Color(0xFFB2EBF2) // Light cyan/blue outline matching the screenshot
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeJoin = StrokeJoin.round;

    final paintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw the thick cyan border. Because the stroke is centered on the path, 
    // the inner intersections will be drawn here but completely painted over by the white fill!
    canvas.drawPath(cloudPath, paintStroke);
    
    // Fill the cloud with white, perfectly covering the inner intersecting strokes and 
    // leaving only the crisp outer cyan border visible.
    canvas.drawPath(cloudPath, paintFill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoofPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawPath(path, paint);
    
    // Draw tiles pattern
    final tilePaint = Paint()
      ..color = const Color(0xFF795548)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (double y = 10; y < size.height; y += 10) {
      canvas.drawLine(Offset(size.width / 2 - y, y), Offset(size.width / 2 + y, y), tilePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChessboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintBlack = Paint()..color = Colors.black87;
    final double tileW = size.width / 4;
    final double tileH = size.height / 2;

    for (int y = 0; y < 2; y++) {
      for (int x = 0; x < 4; x++) {
        if ((x + y) % 2 == 1) {
          canvas.drawRect(Rect.fromLTWH(x * tileW, y * tileH, tileW, tileH), paintBlack);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayerPawn extends StatefulWidget {
  @override
  State<_PlayerPawn> createState() => _PlayerPawnState();
}

class _PlayerPawnState extends State<_PlayerPawn> with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -5 * _floatController.value), // Subtle gentle float up and down
          child: child,
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}

class _MovingClouds extends StatefulWidget {
  const _MovingClouds({super.key});

  @override
  State<_MovingClouds> createState() => _MovingCloudsState();
}

class _MovingCloudsState extends State<_MovingClouds> with SingleTickerProviderStateMixin {
  late final AnimationController _cloudController;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cloudController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(40 * math.sin(_cloudController.value * math.pi * 2), 15 * math.cos(_cloudController.value * math.pi * 2)),
          child: child,
        );
      },
      // Using the same CustomPaint clouds but animated
      child: CustomPaint(
        painter: _AnimeCloudPainter(),
      ),
    );
  }
}
