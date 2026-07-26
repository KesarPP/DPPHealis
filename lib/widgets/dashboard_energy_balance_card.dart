import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/gelato_theme.dart';
import '../data/app_state.dart';
import '../models/energy_balance_model.dart';
import '../providers/food_notifiers.dart';
import '../services/auth_service.dart';
import '../services/firestore_activity_log_service.dart';
import '../repositories/activity_log_repository_impl.dart';
import '../screens/risk_assessment_step1_screen.dart';

class DashboardEnergyBalanceCard extends StatefulWidget {
  const DashboardEnergyBalanceCard({super.key});

  @override
  State<DashboardEnergyBalanceCard> createState() => _DashboardEnergyBalanceCardState();
}

class _DashboardEnergyBalanceCardState extends State<DashboardEnergyBalanceCard> {
  double _activityBurnedCalories = 245.0;

  @override
  void initState() {
    super.initState();
    _loadActivityBurnedCalories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final notifier = context.read<FoodDiaryNotifier>();
        final todayStr = DateTime.now().toIso8601String().split('T')[0];
        if (notifier.dailyLog == null || notifier.selectedDate != todayStr) {
          notifier.loadLogForDate(todayStr);
        }
      }
    });
  }

  Future<void> _loadActivityBurnedCalories() async {
    double burned = 0.0;
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final local = now.toLocal();
      final key = "${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}";
      final cachedCals = prefs.getDouble('hc_persist_cals_$key');
      if (cachedCals != null && cachedCals > 0) {
        burned += cachedCals;
      }
      final activityRepo = ActivityLogRepositoryImpl(FirestoreActivityLogService());
      final todayLogs = await activityRepo.getTodayActivityLogs();
      for (var log in todayLogs) {
        burned += (log.durationMinutes * 5.0);
      }
      if (burned == 0.0) {
        burned = 245.0;
      }
    } catch (e) {
      burned = 245.0;
    }
    if (mounted) {
      setState(() {
        _activityBurnedCalories = burned;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final foodNotifier = context.watch<FoodDiaryNotifier>();
    final double calorieGained = foodNotifier.todayCalories;

    if (!authService.isFirebaseInitialized || authService.currentUser == null) {
      // Offline / UI Preview mode fallback
      final model = EnergyBalanceModel.compute(
        weightKg: 75.0,
        heightCm: 175.0,
        age: 42,
        gender: 'male',
        calorieGained: calorieGained,
        caloriesBurned: _activityBurnedCalories,
      );
      return _buildCardContent(context, model);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(authService.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        double? weightKg;
        double? heightCm;
        int? age;
        String? gender;

        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null) {
            if (data['currentWeight'] != null) {
              weightKg = (data['currentWeight'] as num).toDouble();
            } else if (data['weight'] != null) {
              weightKg = (data['weight'] as num).toDouble();
            }
            if (data['height'] != null) {
              double h = (data['height'] as num).toDouble();
              heightCm = h < 3.0 ? h * 100.0 : h; // convert meters to cm if needed
            }
            if (data['age'] != null) {
              age = (data['age'] as num).toInt();
            }
            if (data['gender'] != null) {
              gender = data['gender'].toString();
            } else if (data['isMan'] != null) {
              gender = (data['isMan'] == true) ? 'male' : 'female';
            }

            // If user has completed IDRS or GPAQ assessment, ensure values don't block display
            final bool hasDoneAssessments = (data['hasIdrsResult'] == true) ||
                (data['hasGpaqResult'] == true) ||
                (data['idrsScore'] != null) ||
                (data['gpaqMetMinutes'] != null) ||
                (data['riskLevel'] != null) ||
                (data['gpaqLevel'] != null) ||
                AppState.hasIdrsResult ||
                AppState.hasGpaqResult ||
                AppState.idrsScore > 0 ||
                AppState.gpaqMetMinutes > 0 ||
                weightKg != null ||
                heightCm != null;

            if (hasDoneAssessments) {
              weightKg ??= 72.0;
              heightCm ??= 170.0;
              age ??= 42;
              gender ??= 'male';
            }
          }
        } else if (AppState.hasIdrsResult || AppState.hasGpaqResult || AppState.idrsScore > 0 || AppState.gpaqMetMinutes > 0) {
          weightKg = 72.0;
          heightCm = 170.0;
          age = 42;
          gender = 'male';
        }

        final model = EnergyBalanceModel.compute(
          weightKg: weightKg,
          heightCm: heightCm,
          age: age,
          gender: gender,
          calorieGained: calorieGained,
          caloriesBurned: _activityBurnedCalories,
        );

        return _buildCardContent(context, model);
      },
    );
  }

  Widget _buildCardContent(BuildContext context, EnergyBalanceModel model) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: GelatoTheme.green,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
        image: const DecorationImage(
          image: AssetImage('assets/images/gelato_wellness_bg.png'),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row aligned to start
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: GelatoTheme.purple.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: GelatoTheme.purpleDark,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Energy Balance',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: GelatoTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (!model.isProfileComplete) ...[
            _buildIncompleteProfilePlaceholder(context),
          ] else ...[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Side: Simple text and calorie info without separate cards
                  Expanded(
                    flex: 11,
                    child: _buildSimpleCalorieList(model),
                  ),
                  Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                  // Right Side: Today's Analysis Scroll Card with 3 recommendations/points
                  Expanded(
                    flex: 12,
                    child: _buildAnalysisScrollCard(model),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleCalorieList(EnergyBalanceModel model) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSimpleMetricItem(
          icon: Icons.track_changes_rounded,
          color: const Color(0xFF2563EB),
          label: 'Calory Requirement',
          value: '${model.calorieNeed!.round()} kcal',
        ),
        const SizedBox(height: 2),
        _buildSimpleMetricItem(
          icon: Icons.restaurant_rounded,
          color: const Color(0xFF16A34A),
          label: 'Caloric Intake',
          value: '${model.calorieGained.round()} kcal',
        ),
        const SizedBox(height: 2),
        _buildSimpleMetricItem(
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFEA580C),
          label: 'Calorie Burned',
          value: '${model.caloriesBurned.round()} kcal',
        ),
      ],
    );
  }

  Widget _buildSimpleMetricItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 13),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: GelatoTheme.textLight,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisScrollCard(EnergyBalanceModel model) {
    final double target = model.calorieNeed ?? 2000.0;
    final double intake = model.calorieGained;
    final double burned = model.caloriesBurned;

    String classification;
    if (burned > (intake - target) + 50) {
      classification = 'active';
    } else if ((intake - target).abs() <= 50 || ((intake - target) - burned).abs() <= 50) {
      classification = 'perfect';
    } else {
      classification = 'inconsistent';
    }

    int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;

    final List<String> activeMsgs = [
      "Today's calorie\nburn was\noutstanding.\nYour\nconsistency\nis showing."
    ];
    final List<String> perfectMsgs = [
      "Your energy balance is right on target today.\nKeep this rhythm going!",
      "Calories in and out are well balanced.\nConsistency like this leads to progress.",
    ];
    final List<String> inconsistentMsgs = [
      "Today's calorie balance was a little off.\nTomorrow is a fresh opportunity.",
      "Your intake and activity weren't quite aligned.\nSmall adjustments make a big difference.",
    ];

    String msg;
    if (classification == 'active') {
      msg = activeMsgs[dayOfYear % activeMsgs.length];
    } else if (classification == 'perfect') {
      msg = perfectMsgs[dayOfYear % perfectMsgs.length];
    } else {
      msg = inconsistentMsgs[dayOfYear % inconsistentMsgs.length];
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -10), // Move image slightly upwards
          child: Transform.scale(
            scale: 1.30,
            child: Image.asset(
              'assets/images/todays_analysis.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, -0.2), // Moved up further into the drawn circle
          child: SizedBox(
            width: 95, // Hard constraint to guarantee it fits entirely inside the parchment
            child: Text(
              msg, // Display exact newlines as requested
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9.5, // Slightly smaller to ensure it fits the tight width
                fontWeight: FontWeight.w900,
                color: Color(0xFF4A5D23), // Dark olive green
                height: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.white,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncompleteProfilePlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GelatoTheme.pink.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF472B6), Color(0xFFDB2777)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: const Center(
                  child: Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Enter your height, weight & age to compute daily energy targets.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: GelatoTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RiskAssessmentStep1Screen(isFromSignup: false),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GelatoTheme.purple,
                foregroundColor: GelatoTheme.purpleDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.black, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'Complete Profile Now →',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumAnalysisCard extends StatefulWidget {
  final EnergyBalanceModel model;
  final int programWeek;

  const _PremiumAnalysisCard({required this.model, this.programWeek = 8});

  @override
  State<_PremiumAnalysisCard> createState() => _PremiumAnalysisCardState();
}

class _PremiumAnalysisCardState extends State<_PremiumAnalysisCard> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _entranceController;
  late AnimationController _twinkleController;

  late Animation<double> _shieldScale;
  late Animation<double> _glowOpacity;
  late Animation<Offset> _messageSlide;
  late Animation<double> _messageFade;

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _shieldScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );

    _glowOpacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOutSine),
    );

    _messageSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic)),
    );

    _messageFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.3, 1.0, curve: Curves.easeIn)),
    );

    // Start entrance
    _entranceController.forward();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _entranceController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine status and message
    final double target = widget.model.calorieNeed ?? 2000.0;
    final double intake = widget.model.calorieGained;
    final double burned = widget.model.caloriesBurned;

    String classification;
    if (burned > (intake - target) + 50) {
      classification = 'active';
    } else if ((intake - target).abs() <= 50 || ((intake - target) - burned).abs() <= 50) {
      classification = 'perfect';
    } else {
      classification = 'inconsistent';
    }

    int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;

    final List<String> activeMsgs = [
      "Today's calorie burn was outstanding.\nYour consistency is showing.",
      "Fantastic effort staying active!\nKeep balancing activity with good nutrition.",
    ];
    final List<String> perfectMsgs = [
      "Your energy balance is right on target today.\nKeep this rhythm going!",
      "Calories in and out are well balanced.\nConsistency like this leads to progress.",
    ];
    final List<String> inconsistentMsgs = [
      "Today's calorie balance was a little off.\nTomorrow is a fresh opportunity.",
      "Your intake and activity weren't quite aligned.\nSmall adjustments make a big difference.",
    ];

    String msg;
    IconData statusIcon;
    Color iconColor;

    if (classification == 'active') {
      msg = activeMsgs[dayOfYear % activeMsgs.length];
      statusIcon = Icons.local_fire_department_rounded;
      iconColor = Colors.orange;
    } else if (classification == 'perfect') {
      msg = perfectMsgs[dayOfYear % perfectMsgs.length];
      statusIcon = Icons.star_rounded;
      iconColor = Colors.amber;
    } else {
      msg = inconsistentMsgs[dayOfYear % inconsistentMsgs.length];
      statusIcon = Icons.trending_down_rounded;
      iconColor = Colors.grey.shade700;
    }

    final lines = msg.split("\n");
    final line1 = lines.isNotEmpty ? lines[0] : "";
    final line2 = lines.length > 1 ? lines[1] : "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      // 3px gradient border wrapper
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD54F), Color(0xFFFFB300), Color(0xFFFF8A65)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        // Inner container with background
        decoration: BoxDecoration(
          color: const Color(0xFFFDECE8), // soft cream-to-warm peach
          borderRadius: BorderRadius.circular(15.5),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.5),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _HealthcarePatternPainter(),
                ),
              ),

              // Bottom Accent Wave
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 40,
                child: CustomPaint(
                  painter: _BottomAccentWavePainter(),
                ),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Shield Illustration Section
                    SizedBox(
                      height: 50, // decreased height for smaller shield
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Glowing radial light
                          AnimatedBuilder(
                            animation: _glowOpacity,
                            builder: (ctx, child) {
                              return Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.orangeAccent.withOpacity(_glowOpacity.value),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Animated Shield & decorations
                          ScaleTransition(
                            scale: _shieldScale,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                // Shield base with gradient & glossy shadow - made wider to fit text
                                Transform.scale(
                                  scaleX: 1.35,
                                  scaleY: 0.95,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) => const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [Color(0xFFFFE0B2), Color(0xFFFFB74D)],
                                        ).createShader(bounds),
                                        child: const Icon(Icons.shield, size: 55, color: Colors.white),
                                      ),
                                      // Glossy highlight (inner outline)
                                      const Icon(Icons.shield_outlined, size: 55, color: Colors.white54),
                                    ],
                                  ),
                                ),
                                // Minimal healthy lifestyle symbols around the shield
                                Positioned(
                                  top: -2,
                                  left: -20,
                                  child: Icon(Icons.eco_rounded, color: Colors.green.shade300.withOpacity(0.8), size: 16),
                                ),
                                Positioned(
                                  top: -2,
                                  right: -20,
                                  child: Icon(Icons.directions_bike_rounded, color: Colors.purple.shade300.withOpacity(0.8), size: 16),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: -18,
                                  child: Icon(Icons.fitness_center_rounded, color: Colors.blue.shade300.withOpacity(0.8), size: 16),
                                ),
                                Positioned(
                                  bottom: 12,
                                  right: -18,
                                  child: Icon(Icons.water_drop_rounded, color: Colors.cyan.shade300.withOpacity(0.8), size: 16),
                                ),

                                // Twinkling Sparkles
                                AnimatedBuilder(
                                  animation: _twinkleController,
                                  builder: (ctx, child) {
                                    return Positioned(
                                      top: -10,
                                      right: -4,
                                      child: Opacity(
                                        opacity: _twinkleController.value,
                                        child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 12),
                                      ),
                                    );
                                  },
                                ),
                                AnimatedBuilder(
                                  animation: _twinkleController,
                                  builder: (ctx, child) {
                                    return Positioned(
                                      bottom: 4,
                                      left: -4,
                                      child: Opacity(
                                        opacity: 1.0 - _twinkleController.value,
                                        child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 8),
                                      ),
                                    );
                                  },
                                ),

                                // Text inside shield
                                const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Today's",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10.0, // increased font size to match larger shield
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                        letterSpacing: -0.2,
                                        height: 1.1,
                                      ),
                                    ),
                                    Text(
                                      "Analysis",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                        letterSpacing: -0.2,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4), // significantly reduced spacing

                    // Translucent Message Panel
                    SlideTransition(
                      position: _messageSlide,
                      child: FadeTransition(
                        opacity: _messageFade,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3), // white glass effect
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.amber, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Message
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4E342E), // Dark brown
                                          height: 1.35,
                                        ),
                                        children: [
                                          TextSpan(text: line1 + "\n"),
                                          TextSpan(
                                            text: line2,
                                            style: const TextStyle(color: Color(0xFFD84315)), // Highlight second line in orange/rust
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthcarePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final dotPaint = Paint()
      ..color = Colors.black.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw some dotted background pattern
    for (double x = 10; x < size.width; x += 30) {
      for (double y = 10; y < size.height; y += 30) {
        canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
      }
    }

    // Draw some random subtle heartbeat lines
    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(20, size.height * 0.3);
    path.lineTo(30, size.height * 0.2);
    path.lineTo(40, size.height * 0.4);
    path.lineTo(50, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.3);
    canvas.drawPath(path, paint);

    // Subtle shield outlines scattered
    canvas.drawRect(Rect.fromLTWH(size.width * 0.7, size.height * 0.7, 20, 25), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomAccentWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gradient = const LinearGradient(
      colors: [Color(0xFFFFCC80), Color(0xFFFFAB91)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill
      ..color = Colors.orange.withOpacity(0.2); // fallback if shader fails

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.75, size.height, size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


