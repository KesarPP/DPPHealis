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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F8EA), // Gelato Days soft green tone
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Row centered in middle of card
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
        const SizedBox(height: 6),
        _buildSimpleMetricItem(
          icon: Icons.restaurant_rounded,
          color: const Color(0xFF16A34A),
          label: 'Caloric Intake',
          value: '${model.calorieGained.round()} kcal',
        ),
        const SizedBox(height: 6),
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
    final double net = intake - burned;
    final bool isDeficit = net <= target;

    String p1 = "1. Target: ${target.round()} kcal daily.";
    String p2 = "2. Logged: ${intake.round()} in, ${burned.round()} out.";
    String p3 = isDeficit
        ? "3. Status: Great deficit! Keep up brisk activity."
        : "3. Recommendation: Surplus! Add 20m brisk walk.";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Golden/Wooden Roller with finials and patterned ribbon
          SizedBox(
            height: 18,
            child: CustomPaint(
              painter: _VintageRollerPainter(isTop: true),
            ),
          ),
          // Scroll Parchment Body with Ornate Side Borders
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10), // inset so rollers protrude past paper edges
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAEDE3), // Vintage blush parchment tone
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: CustomPaint(
                  painter: _VintageParchmentAndBordersPainter(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 6), // space inside decorative side borders
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history_edu_rounded, color: Color(0xFF8B2635), size: 16),
                            const SizedBox(width: 5),
                            const Expanded(
                              child: Text(
                                "Today's Analysis",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF7A1F2D),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p1, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF5A2A27))),
                              Text(p2, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF5A2A27))),
                              Text(p3, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF8B2635))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom Golden/Wooden Roller with finials and patterned ribbon
          SizedBox(
            height: 18,
            child: CustomPaint(
              painter: _VintageRollerPainter(isTop: false),
            ),
          ),
        ],
      ),
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

class _VintageRollerPainter extends CustomPainter {
  final bool isTop;
  _VintageRollerPainter({required this.isTop});

  @override
  void paint(Canvas canvas, Size size) {
    // Roller spans width 0 to size.width, height 0 to size.height (18px)
    // Cylinder rod runs from x = 12 to x = size.width - 12
    final Rect rodRect = Rect.fromLTRB(12, 2, size.width - 12, size.height - 2);
    final Paint rodPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF8C5008), // Dark golden brown edge
          Color(0xFFE5A93B), // Gold gleam
          Color(0xFFFDE08D), // Highlight
          Color(0xFFB87311), // Mid gold
          Color(0xFF6B3C05), // Shadow edge
        ],
      ).createShader(rodRect);
    
    final RRect rrod = RRect.fromRectAndRadius(rodRect, const Radius.circular(5));
    canvas.drawRRect(rrod, rodPaint);
    canvas.drawRRect(rrod, Paint()..color = const Color(0xFF4A2600)..style = PaintingStyle.stroke..strokeWidth = 1);

    // Draw Ornate Red/Orange Patterned Bands near ends (mimicking scroll bands)
    final Paint bandBg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFB71C1C), Color(0xFFFF5722), Color(0xFFD84315)],
      ).createShader(rodRect);
    
    void drawBand(double xLeft, double xRight) {
      final Rect bandRect = Rect.fromLTRB(xLeft, 2, xRight, size.height - 2);
      canvas.drawRect(bandRect, bandBg);
      final Paint ringPaint = Paint()..color = const Color(0xFFFFD54F)..strokeWidth = 1.2;
      canvas.drawLine(Offset(xLeft, 2), Offset(xLeft, size.height - 2), ringPaint);
      canvas.drawLine(Offset(xRight, 2), Offset(xRight, size.height - 2), ringPaint);
      final Paint dotPaint = Paint()..color = const Color(0xFFFFE082);
      for (double y = 4; y < size.height - 3; y += 4) {
        canvas.drawCircle(Offset((xLeft + xRight) / 2, y), 1.0, dotPaint);
      }
    }
    drawBand(16, 23);
    drawBand(size.width - 23, size.width - 16);

    // Draw Golden Finials / Carved End Caps (Triangles/Knobs on both ends)
    void drawFinial(double xStart, double xTip, bool isLeft) {
      final Path path = Path();
      final double midY = size.height / 2;
      path.moveTo(xStart, 3);
      path.lineTo(xTip, midY);
      path.lineTo(xStart, size.height - 3);
      path.close();

      final Paint finialPaint = Paint()
        ..shader = LinearGradient(
          colors: [const Color(0xFFFFD54F), const Color(0xFFB87311)],
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        ).createShader(Rect.fromLTRB(math.min(xStart, xTip), 0, math.max(xStart, xTip), size.height));

      canvas.drawPath(path, finialPaint);
      canvas.drawPath(path, Paint()..color = const Color(0xFF5C3000)..style = PaintingStyle.stroke..strokeWidth = 1);
      canvas.drawCircle(Offset((xStart + xTip) / 2, midY), 1.8, Paint()..color = const Color(0xFFFFF8E1));
    }
    drawFinial(12, 1, true);
    drawFinial(size.width - 12, size.width - 1, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VintageParchmentAndBordersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw decorative left and right border strips (width 14)
    final Paint borderBg = Paint()..color = const Color(0xFFF7DAC8);
    canvas.drawRect(Rect.fromLTRB(0, 0, 14, size.height), borderBg);
    canvas.drawRect(Rect.fromLTRB(size.width - 14, 0, size.width, size.height), borderBg);

    final Paint borderLine = Paint()..color = const Color(0xFFE65100)..strokeWidth = 1.0;
    canvas.drawLine(Offset(14, 0), Offset(14, size.height), borderLine);
    canvas.drawLine(Offset(size.width - 14, 0), Offset(size.width - 14, size.height), borderLine);
    canvas.drawLine(Offset(2, 0), Offset(2, size.height), borderLine);
    canvas.drawLine(Offset(size.width - 2, 0), Offset(size.width - 2, size.height), borderLine);

    final Paint patternPaint = Paint()..color = const Color(0xFFD84315)..strokeWidth = 0.9..style = PaintingStyle.stroke;
    final Paint dotPaint = Paint()..color = const Color(0xFFBF360C);

    void drawLatticeColumn(double centerX) {
      for (double y = 7; y < size.height - 4; y += 11) {
        final Path diamond = Path()
          ..moveTo(centerX, y - 3.5)
          ..lineTo(centerX + 3.0, y)
          ..lineTo(centerX, y + 3.5)
          ..lineTo(centerX - 3.0, y)
          ..close();
        canvas.drawPath(diamond, patternPaint);
        canvas.drawCircle(Offset(centerX, y), 0.7, dotPaint);
      }
    }
    drawLatticeColumn(8);
    drawLatticeColumn(size.width - 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
