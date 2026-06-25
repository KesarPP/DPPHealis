import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'clinician_profile_screen.dart';
import 'clinical_inbox.dart';
import 'patient_chat_screen.dart';
import 'patient_profile_screen.dart';
import '../services/auth_service.dart';
import '../models/coach_profile.dart';

// Brand colors
const _navy     = Color(0xFF1B3D6D);
const _slate    = Color(0xFF6B7C93);
const _pageBg   = Color(0xFFF0F4F8);

// ─────────────────────────────────────────────────────────────────────────────
// Mock Data for the Patient List
// ─────────────────────────────────────────────────────────────────────────────
class Patient {
  final String name;
  final String initials;
  final Color avatarBg;
  final Color avatarFg;
  final int sessionNumber;
  final String sessionTitle;
  final String riskLevel;

  const Patient({
    required this.name,
    required this.initials,
    required this.avatarBg,
    required this.avatarFg,
    required this.sessionNumber,
    required this.sessionTitle,
    required this.riskLevel,
  });
}


// ─────────────────────────────────────────────────────────────────────────────
// Main Screen
// ─────────────────────────────────────────────────────────────────────────────
class ClinicianDashboardScreen extends StatefulWidget {
  final int initialTabIndex;

  const ClinicianDashboardScreen({
    super.key,
    this.initialTabIndex = 1,
  });

  @override
  State<ClinicianDashboardScreen> createState() => _ClinicianDashboardScreenState();
}

class _ClinicianDashboardScreenState extends State<ClinicianDashboardScreen> {
  late int _currentTabIndex;
  Patient? _selectedPatient;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            if (_currentTabIndex != 0) _buildHeader(),
            Expanded(
              child: _currentTabIndex == 1
                  ? _buildHomeDashboard()
                  : _currentTabIndex == 0
                      ? (_selectedPatient != null
                          ? PatientProfileScreen(
                              patient: _selectedPatient!,
                              onBack: () => setState(() => _selectedPatient = null),
                            )
                          : PatientsListScreen(
                              onPatientTap: (patient) => setState(() => _selectedPatient = patient),
                              onBackTap: () => setState(() => _currentTabIndex = 1),
                            ))
                      : const Center(child: Text('Inbox Screen placeholder')),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Header bar ────────────────────────────────────────────────────────────────
  String _getInitials(String name) {
    if (name.isEmpty) return 'CP';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Widget _buildHeader() {
    final uid = AuthService().currentUser?.uid ?? 'default_coach';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ClinicianProfileScreen())).then((_) {
                  setState(() {});
                }),
            child: FutureBuilder<CoachProfile>(
              future: AuthService().getCoachProfile(uid),
              builder: (context, snapshot) {
                final localPath = snapshot.data?.localImagePath;
                final fileExists = localPath != null && File(localPath).existsSync();
                if (fileExists) {
                  return CircleAvatar(
                    radius: 21,
                    backgroundColor: Colors.transparent,
                    backgroundImage: FileImage(File(localPath)),
                  );
                }
                
                final initials = snapshot.data != null ? _getInitials(snapshot.data!.name) : 'CP';
                return CircleAvatar(
                  radius: 21,
                  backgroundColor: _navy.withValues(alpha: 0.1),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _navy,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'DPP Connect',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _navy),
          ),
        ],
      ),
    );
  }

  // ── Home Dashboard (The middle section mockup) ────────────────────────────────
  Widget _buildHomeDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 20),
          _buildTotalParticipantsCard(),
          const SizedBox(height: 16),
          _buildCurriculumProgressCard(),
          const SizedBox(height: 16),
          _buildFoodLogCard(),
          const SizedBox(height: 16),
          _buildWeeklyActivityCard(),
          const SizedBox(height: 16),
          _buildConsistencyCard(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildTotalParticipantsCard() {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL ACTIVE PARTICIPANTS',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF6B7280), letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          const Text(
            '30',
            style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.black, height: 1.0),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildRiskBox('High Risk', '10', const Color(0xFFB91C1C), const Color(0xFFB91C1C), const Color(0xFFFEF2F2)),
              _buildRiskBox('Moderate', '15', const Color(0xFF9A3412), const Color(0xFF9A3412), const Color(0xFFFFF7ED)),
              _buildRiskBox('Low Risk', '5', const Color(0xFF0F766E), const Color(0xFF0F766E), const Color(0xFFCCFBF1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBox(String title, String count, Color titleColor, Color countColor, Color bgColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: titleColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: titleColor, fontSize: 10, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(color: countColor, fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurriculumProgressCard() {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Curriculum Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              Text('85%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F766E))),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cohort pace tracking', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              Text('Up to Date', style: TextStyle(fontSize: 11, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressBar('Weeks 1-4', '12 Patients', 0.4, const Color(0xFF0F766E)),
          const SizedBox(height: 12),
          _buildProgressBar('Weeks 5-8', '15 Patients', 0.5, const Color(0xFF0F766E)),
          const SizedBox(height: 16),
          _buildProgressBar('⚠️ Behind Schedule', '3 Patients', 0.1, const Color(0xFFD97706), isWarning: true),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, String trailing, double progress, Color color, {bool isWarning = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: isWarning ? color : Colors.black, fontSize: 11, fontWeight: FontWeight.w800)),
            Text(trailing, style: TextStyle(color: isWarning ? color : Colors.black, fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildFoodLogCard() {
    return _DashboardCard(
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.fastfood_rounded, size: 140, color: Colors.grey.withValues(alpha: 0.06)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.restaurant_menu_rounded, color: Color(0xFF0F766E), size: 20),
                  SizedBox(width: 8),
                  Text('Food Log Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('24', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.black)),
                  Text(' / 30', style: TextStyle(fontSize: 18, color: Color(0xFF6B7280))),
                ],
              ),
              const Text('Patients logged food today', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildMealStat(Icons.wb_sunny_outlined, 'Breakfast', '92%'),
                  _buildVDivider(),
                  _buildMealStat(Icons.wb_sunny_rounded, 'Lunch', '85%'),
                  _buildVDivider(),
                  _buildMealStat(Icons.nights_stay_outlined, 'Dinner', '70%'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealStat(IconData icon, String meal, String pct) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF0F766E), size: 22),
          const SizedBox(height: 8),
          Text(meal, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(pct, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildVDivider() {
    return Container(width: 1, height: 40, color: Colors.grey.withValues(alpha: 0.2));
  }

  Widget _buildWeeklyActivityCard() {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fitness_center_rounded, color: Color(0xFF0F766E), size: 20),
              SizedBox(width: 8),
              Text('Weekly Activity Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          const SizedBox(height: 32),
          const Center(
            child: SizedBox(
              height: 160,
              width: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 0.72,
                    strokeWidth: 16,
                    backgroundColor: Color(0xFFE5E7EB),
                    color: Color(0xFF0F766E),
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('72%', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.black, height: 1.1)),
                        SizedBox(height: 2),
                        Text('Hit Weekly Goal', style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildGoalRow(const Color(0xFF0F766E), 'Goal Achieved (150+ min)', '18'),
          _buildGoalRow(const Color(0xFF5EEAD4), 'In Progress (60-149 min)', '8'),
          _buildGoalRow(const Color(0xFFDC2626), 'Critically Low (<30 min)', '4', isWarning: true),
        ],
      ),
    );
  }

  Widget _buildGoalRow(Color dotColor, String label, String count, {bool isWarning = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: dotColor),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
          const Spacer(),
          if (isWarning) const Icon(Icons.access_time_rounded, color: Color(0xFFDC2626), size: 14),
          if (isWarning) const SizedBox(width: 4),
          Text(count, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isWarning ? const Color(0xFFDC2626) : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildConsistencyCard(BuildContext context) {
    return _DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_outlined, color: Color(0xFF0F766E), size: 22),
              const SizedBox(width: 8),
              const Text('Consistency', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6EE7B7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text('Avg: 6 Days', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF064E3B))),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStreakBox(Icons.local_fire_department_rounded, const Color(0xFFEA580C), '12', 'Super Loggers', '7+ Day Streak'),
              const SizedBox(width: 12),
              _buildStreakBox(Icons.local_fire_department_outlined, Colors.grey.shade400, '5', 'At Risk', 'Dropped to 0'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Clicking this sets the tab to the 'Patients' list (tab 0)
                setState(() {
                  _currentTabIndex = 0;
                  _selectedPatient = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('VIEW ALL PARTICIPANT LISTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBox(IconData icon, Color iconColor, String count, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 12),
            Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: iconColor)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
          ],
        ),
      ),
    );
  }

  // ── Bottom nav ────────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            index: 0,
            icon: Icons.people_outline_rounded,
            selectedIcon: Icons.people_rounded,
            label: 'Patients',
            currentIndex: _currentTabIndex,
            onTap: () => setState(() {
              _currentTabIndex = 0;
              _selectedPatient = null;
            }),
          ),
          _NavItem(
            index: 1,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Home',
            currentIndex: _currentTabIndex,
            onTap: () => setState(() => _currentTabIndex = 1),
          ),
          _NavItem(
            index: 2,
            icon: Icons.mail_outline_rounded,
            selectedIcon: Icons.mail_rounded,
            label: 'Inbox',
            currentIndex: _currentTabIndex,
            onTap: () {
              setState(() => _currentTabIndex = 2);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClinicalInboxScreen()),
              ).then((_) {
                if (mounted) setState(() => _currentTabIndex = 1);
              });
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav Item widget
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int currentIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _navy.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? selectedIcon : icon, color: isSelected ? _navy : _slate, size: 24),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? _navy : _slate,
                )),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final Widget child;
  const _DashboardCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Patients List Content (Tab 0)
// ─────────────────────────────────────────────────────────────────────────────
class PatientsListScreen extends StatelessWidget {
  final void Function(Patient) onPatientTap;
  final VoidCallback onBackTap;
  const PatientsListScreen({super.key, required this.onPatientTap, required this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: const Color(0xFFF8FAFC),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBackTap,
                child: const Icon(Icons.arrow_back_rounded, color: _navy),
              ),
              const SizedBox(width: 12),
              const Text(
                'Patients',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _navy),
              ),
              const Spacer(),
              const Icon(Icons.search_rounded, color: Colors.black54),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.black12),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'user').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Error loading patients'));
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(child: Text('No patients found'));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final name = data['name'] as String? ?? 'Unknown Patient';
                  
                  String getInitials(String n) {
                    if (n.isEmpty) return '??';
                    final parts = n.trim().split(' ');
                    if (parts.length > 1) {
                      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
                    }
                    return parts[0][0].toUpperCase();
                  }

                  final p = Patient(
                    name: name,
                    initials: getInitials(name),
                    avatarBg: _navy,
                    avatarFg: Colors.white,
                    sessionNumber: 1,
                    sessionTitle: '',
                    riskLevel: 'MODERATE',
                  );
              Color riskColor;
              Color riskBg;
              if (p.riskLevel == 'HIGH RISK') {
                riskColor = const Color(0xFF991B1B);
                riskBg = const Color(0xFFFECACA);
              } else if (p.riskLevel == 'LOW RISK') {
                riskColor = const Color(0xFF065F46);
                riskBg = const Color(0xFF6EE7B7);
              } else {
                riskColor = const Color(0xFF9A3412);
                riskBg = const Color(0xFFFFEDD5);
              }

              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => onPatientTap(p),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: p.avatarBg,
                          child: Text(p.initials, style: TextStyle(color: p.avatarFg, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Participant • Session ${p.sessionNumber}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: riskBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(p.riskLevel, style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 9)),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PatientChatScreen(
                                  patientName: p.name,
                                  patientInitials: p.initials,
                                  avatarBg: p.avatarBg,
                                  avatarFg: p.avatarFg,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.black87, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}