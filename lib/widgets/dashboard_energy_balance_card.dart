import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/gelato_theme.dart';
import '../data/app_state.dart';
import '../models/energy_balance_model.dart';
import '../providers/food_notifiers.dart';
import '../services/auth_service.dart';
import '../screens/risk_assessment_step1_screen.dart';

class DashboardEnergyBalanceCard extends StatefulWidget {
  const DashboardEnergyBalanceCard({super.key});

  @override
  State<DashboardEnergyBalanceCard> createState() => _DashboardEnergyBalanceCardState();
}

class _DashboardEnergyBalanceCardState extends State<DashboardEnergyBalanceCard> {
  @override
  void initState() {
    super.initState();
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
        );

        return _buildCardContent(context, model);
      },
    );
  }

  Widget _buildCardContent(BuildContext context, EnergyBalanceModel model) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: GelatoTheme.purple.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: GelatoTheme.purpleDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Energy Balance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: GelatoTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              if (model.isProfileComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: model.caloriesToBurn == 0
                        ? GelatoTheme.green.withValues(alpha: 0.4)
                        : GelatoTheme.orange.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Text(
                    model.caloriesToBurn == 0 ? 'On Track ✅' : 'Surplus 🔥',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: model.caloriesToBurn == 0 ? GelatoTheme.greenDark : GelatoTheme.orangeDark,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (!model.isProfileComplete) ...[
            _buildIncompleteProfilePlaceholder(context),
          ] else ...[
            // Top Row: Calorie Need & Calorie Gained
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildGridTile(
                      label: 'Calorie Need',
                      subtitle: 'Daily target',
                      value: model.calorieNeed!,
                      unit: 'kcal',
                      gradientColors: const [Color(0xFF60A5FA), Color(0xFF2563EB)],
                      icon: Icons.track_changes_rounded,
                      bgColor: GelatoTheme.blue.withValues(alpha: 0.25),
                      textColor: GelatoTheme.blueDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGridTile(
                      label: 'Calorie Gained',
                      subtitle: 'Food intake',
                      value: model.calorieGained,
                      unit: 'kcal',
                      gradientColors: const [Color(0xFF4ADE80), Color(0xFF16A34A)],
                      icon: Icons.restaurant_rounded,
                      bgColor: GelatoTheme.green.withValues(alpha: 0.25),
                      textColor: GelatoTheme.greenDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Bottom Row: To Burn Tile + Heart Shaped Advice Card (4th card)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildGridTile(
                      label: 'To Burn',
                      subtitle: model.caloriesToBurn == 0 ? 'No excess' : 'Surplus calories',
                      value: model.caloriesToBurn,
                      unit: 'kcal',
                      gradientColors: const [Color(0xFFFB923C), Color(0xFFEA580C)],
                      icon: Icons.local_fire_department_rounded,
                      bgColor: GelatoTheme.orange.withValues(alpha: 0.25),
                      textColor: GelatoTheme.orangeDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHeartAdviceCard(model),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeartAdviceCard(EnergyBalanceModel model) {
    final bool isDeficit = model.caloriesToBurn == 0;
    final String adviceText = isDeficit
        ? "Healthy caloric deficit today! Great job staying on track."
        : "To burn ${model.caloriesToBurn.round()} kcal, do ~${model.activityMinutes} mins of brisk walking.";

    return CustomPaint(
      painter: _HeartCardBorderPainter(
        fillColor: isDeficit ? const Color(0xFFFCE7F3) : const Color(0xFFFFE4E6),
        borderColor: Colors.black,
      ),
      child: ClipPath(
        clipper: _HeartCardClipper(),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 26, 16, 22),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Icon(
                  isDeficit ? Icons.favorite_rounded : Icons.directions_walk_rounded,
                  color: isDeficit ? const Color(0xFFE11D48) : const Color(0xFFBE123C),
                  size: 16,
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: Center(
                  child: Text(
                    adviceText,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4C0519),
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridTile({
    required String label,
    required String subtitle,
    required double value,
    required String unit,
    String prefix = '',
    required List<Color> gradientColors,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: value),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) {
                  return Flexible(
                    child: Text(
                      '$prefix${val.round()} $unit',
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: GelatoTheme.textLight,
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

class _HeartCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    // True mathematical heart curve
    path.moveTo(w * 0.5, h * 0.18);
    // Top-left lobe down to left outer edge
    path.cubicTo(w * 0.30, 0, w * 0.02, h * 0.08, w * 0.02, h * 0.35);
    // Smooth taper from left outer edge to sharp bottom tip
    path.cubicTo(w * 0.02, h * 0.65, w * 0.30, h * 0.86, w * 0.5, h * 0.98);
    // Smooth taper from bottom tip to right outer edge
    path.cubicTo(w * 0.70, h * 0.86, w * 0.98, h * 0.65, w * 0.98, h * 0.35);
    // Top-right lobe back to cleft
    path.cubicTo(w * 0.98, h * 0.08, w * 0.70, 0, w * 0.5, h * 0.18);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _HeartCardBorderPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;

  _HeartCardBorderPainter({required this.fillColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final clipper = _HeartCardClipper();
    final path = clipper.getClip(size);

    // Shadow
    canvas.drawPath(
      path.shift(const Offset(0, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Fill
    canvas.drawPath(
      path,
      Paint()..color = fillColor,
    );

    // Border
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _HeartCardBorderPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor || oldDelegate.borderColor != borderColor;
  }
}
