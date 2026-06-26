import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clinician_dashboard_screen.dart'; // To import the Patient model
import 'patient_chat_screen.dart';

const _navy = Color(0xFF1B3D6D);

class PatientProfileScreen extends StatelessWidget {
  final Patient patient;
  final VoidCallback onBack;

  const PatientProfileScreen({
    super.key,
    required this.patient,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileSummaryCard(),
                    const SizedBox(height: 12),
                    _buildIdrsCard(),
                    const SizedBox(height: 12),
                    _buildWeightLossCard(),
                    const SizedBox(height: 12),
                    _buildActivityTrackerCard(),
                    const SizedBox(height: 12),
                    _buildCurriculumCard(),
                    const SizedBox(height: 12),
                    _buildFoodLogCard(),
                    const SizedBox(height: 12),
                    _buildConsistencyCard(),
                    const SizedBox(height: 80), // extra padding for FAB
                  ],
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PatientChatScreen(
                          patientName: patient.name,
                          patientInitials: patient.initials,
                          avatarBg: patient.avatarBg,
                          avatarFg: patient.avatarFg,
                        ),
                      ),
                    );
                  },
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  child: const Icon(Icons.chat_bubble_outline_rounded),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_back_rounded, color: _navy),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Patient Profile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navy),
              ),
            ),
          ),
          const Icon(Icons.more_vert_rounded, color: _navy),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard() {
    Color riskColor;
    Color riskBg;
    if (patient.riskLevel == 'HIGH RISK' || patient.riskLevel == 'HIGH') {
      riskColor = const Color(0xFF991B1B);
      riskBg = const Color(0xFFFECACA);
    } else if (patient.riskLevel == 'LOW RISK' || patient.riskLevel == 'LOW') {
      riskColor = const Color(0xFF065F46);
      riskBg = const Color(0xFF6EE7B7);
    } else {
      riskColor = const Color(0xFF9A3412);
      riskBg = const Color(0xFFFFEDD5);
    }

    return _ProfileCard(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _navy,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Center(
                  child: Text(
                    patient.initials,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6EE7B7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Text('ACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                patient.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: riskBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(patient.riskLevel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: riskColor)),
              )
            ],
          ),
          const SizedBox(height: 4),
          Text('ID #${patient.id.length > 6 ? patient.id.substring(0, 6).toUpperCase() : patient.id}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('OVERALL PROGRAM COMPLETION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black54)),
              Text('45%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _navy)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.45,
              backgroundColor: _navy.withValues(alpha: 0.1),
              color: _navy,
              minHeight: 6,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIdrsCard() {
    final int score = patient.idrsScore ?? 45;
    final String riskText = score >= 60 ? 'HIGH RISK' : score >= 30 ? 'MODERATE RISK' : 'LOW RISK';
    final Color riskColor = score >= 60 ? const Color(0xFFB91C1C) : score >= 30 ? const Color(0xFF9A3412) : const Color(0xFF0F766E);
    final Color riskBg = score >= 60 ? const Color(0xFFFEF2F2) : score >= 30 ? const Color(0xFFFFF7ED) : const Color(0xFFCCFBF1);

    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('IDRS Assessment Score', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: riskBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: riskColor.withValues(alpha: 0.2)),
                ),
                child: Text(riskText, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: riskColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$score', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.black)),
              const Text(' / 100', style: TextStyle(fontSize: 16, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Based on age, family history, waist circumference, and physical activity.', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100.0,
              backgroundColor: const Color(0xFFE5E7EB),
              color: riskColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightLossCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(patient.id).collection('weight_history').orderBy('date', descending: false).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        double startWeight = patient.currentWeight ?? 88.5;
        double currWeight = patient.currentWeight ?? 84.3;
        if (docs.isNotEmpty) {
          startWeight = (docs.first.data() as Map<String, dynamic>)['weight'] as double? ?? startWeight;
          currWeight = (docs.last.data() as Map<String, dynamic>)['weight'] as double? ?? currWeight;
        }

        final double totalLost = startWeight - currWeight;
        final double targetLost = startWeight * 0.07;
        final double pctGoal = targetLost > 0 ? (totalLost / targetLost).clamp(0.0, 1.0) : 0.68;
        final int pctGoalInt = (pctGoal * 100).round();

        return _ProfileCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Weight Loss', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Icon(Icons.hourglass_bottom_rounded, color: _navy, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Starting', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: startWeight.toStringAsFixed(1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                              const TextSpan(text: ' kg', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: Colors.black12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Current', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(text: currWeight.toStringAsFixed(1), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                              const TextSpan(text: ' kg', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.5)),
                ),
                child: Center(
                  child: Text('${totalLost >= 0 ? '-' : '+'}${totalLost.abs().toStringAsFixed(1)} kg lost', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TARGET: 7% (${targetLost.toStringAsFixed(1)} KG)', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text('$pctGoalInt% OF GOAL', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pctGoal,
                  backgroundColor: const Color(0xFFE5E7EB),
                  color: const Color(0xFF059669),
                  minHeight: 6,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTrackerCard() {
    final metMins = patient.gpaqMetMinutes ?? 440;
    final level = patient.gpaqLevel ?? 'Moderate Activity';
    final progress = (metMins / 600).clamp(0.0, 1.0);

    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Activity Tracker', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Icon(Icons.directions_run_rounded, color: _navy, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 70,
                width: 70,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: const Color(0xFFE5E7EB),
                      color: _navy,
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$metMins', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _navy, height: 1.1)),
                          const Text('/ 600 MET', style: TextStyle(fontSize: 7, color: Colors.black87, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Activity Level:', style: TextStyle(fontSize: 11, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(level, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 12, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text('$metMins MET-mins / week', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCurriculumCard() {
    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Curriculum: Session 4 of 16', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text('VIEW PROGRAM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _navy)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSessionCircle('S1', isCompleted: true),
              _buildSessionCircle('S2', isCompleted: true),
              _buildSessionCircle('S3', isCompleted: true),
              _buildSessionCircle('CURRENT', isCurrent: true, label: '4'),
              _buildSessionCircle('S5', isLocked: true),
              _buildSessionCircle('S6', isLocked: true),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
              border: const Border(left: BorderSide(color: _navy, width: 4)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.assignment_rounded, color: _navy, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACTION ITEM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
                      SizedBox(height: 4),
                      Text('"Walk for 20 mins after dinner daily"', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87)),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSessionCircle(String text, {bool isCompleted = false, bool isCurrent = false, bool isLocked = false, String? label}) {
    Color bgColor = const Color(0xFFF3F4F6);
    Widget child = Text(text, style: const TextStyle(fontSize: 10, color: Colors.black45));

    if (isCompleted) {
      bgColor = const Color(0xFF059669);
      child = const Icon(Icons.check_rounded, color: Colors.white, size: 16);
    } else if (isCurrent) {
      bgColor = _navy;
      child = Text(label ?? text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white));
    } else if (isLocked) {
      child = const Icon(Icons.lock_outline_rounded, color: Colors.black38, size: 14);
    }

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: isLocked ? Border.all(color: Colors.black12) : null,
          ),
          child: Center(child: child),
        ),
        const SizedBox(height: 6),
        Text(
          isCurrent ? 'CURRENT' : text,
          style: TextStyle(fontSize: 9, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: isCurrent ? _navy : Colors.black54),
        )
      ],
    );
  }

  Widget _buildFoodLogCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('logs').doc(patient.id).collection('food_entries').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        double totalCalories = 1450;
        bool hasBreakfast = true;
        bool hasLunch = true;
        bool hasDinner = false;

        if (docs.isNotEmpty) {
          final latestDoc = docs.last.data() as Map<String, dynamic>;
          totalCalories = (latestDoc['totalCalories'] as num? ?? 1450).toDouble();
          final entries = latestDoc['entries'] as List<dynamic>? ?? [];
          hasBreakfast = entries.any((e) => e['mealType'] == 'Breakfast');
          hasLunch = entries.any((e) => e['mealType'] == 'Lunch');
          hasDinner = entries.any((e) => e['mealType'] == 'Dinner');
        }

        return _ProfileCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Food Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: totalCalories.round().toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _navy)),
                            const TextSpan(text: ' kcal', style: TextStyle(fontSize: 11, color: _navy)),
                          ],
                        ),
                      ),
                      const Text('Weekly Avg | 42g Fat', style: TextStyle(fontSize: 9, color: Colors.black54)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Text('TODAY\'S LOG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 0.5)),
              const SizedBox(height: 12),
              _buildMealRow('Breakfast', hasBreakfast ? '08:15 AM' : '', hasBreakfast),
              const SizedBox(height: 8),
              _buildMealRow('Lunch', hasLunch ? '12:40 PM' : '', hasLunch),
              const SizedBox(height: 8),
              _buildMealRow('Dinner', hasDinner ? '07:30 PM' : '', hasDinner),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealRow(String meal, String time, bool isLogged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLogged ? const Color(0xFFF3F4F6) : Colors.white,
        border: isLogged ? null : Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isLogged ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_rounded,
            color: isLogged ? const Color(0xFF059669) : Colors.black38,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(meal, style: TextStyle(fontSize: 13, color: isLogged ? Colors.black87 : Colors.black54)),
          const Spacer(),
          if (time.isNotEmpty)
            Text(time, style: const TextStyle(fontSize: 11, color: Colors.black54))
          else
            const Icon(Icons.add_circle_outline_rounded, color: Colors.black26, size: 16)
        ],
      ),
    );
  }

  Widget _buildConsistencyCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('logs').doc(patient.id).collection('food_entries').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final int streak = docs.isNotEmpty ? docs.length : 12;
        final double loggingRate = docs.isNotEmpty ? (docs.length / 14.0 * 100).clamp(0, 100) : 86;

        return _ProfileCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Consistency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6CC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Color(0xFFC2410C), size: 14),
                        const SizedBox(width: 4),
                        Text('$streak Days', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF78350F))),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Text('Last 14 Days Activity', style: TextStyle(fontSize: 10, color: Colors.black54)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(14, (index) {
                  bool isLogged = index < streak;
                  return Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isLogged ? _navy : const Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                      border: isLogged ? null : Border.all(color: Colors.black12),
                    ),
                    child: isLogged
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                        : null,
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('${loggingRate.round()}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 2),
                        const Text('Logging Rate', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: Colors.black12),
                  const Expanded(
                    child: Column(
                      children: [
                        Text('14/14', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 2),
                        const Text('Med Compliance', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final Widget child;
  const _ProfileCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}
