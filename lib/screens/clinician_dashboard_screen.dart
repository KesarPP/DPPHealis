import 'package:flutter/material.dart';
import 'clinician_profile_screen.dart';
import "clinical_inbox.dart";

// Brand colors
const _brandColor = Color(0xFF1B3D6D);
const _slateGrey = Color(0xFF6B7C93);
const _borderBlue = Color(0xFF4A88C5);

class ClinicianDashboardScreen extends StatefulWidget {
  const ClinicianDashboardScreen({super.key});

  @override
  State<ClinicianDashboardScreen> createState() => _ClinicianDashboardScreenState();
}

class _ClinicianDashboardScreenState extends State<ClinicianDashboardScreen> {
  int _currentTabIndex = 0;
  String _selectedFilter = 'All'; // 'All', 'High Risk', 'Session Delay'
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ClinicianProfileScreen()),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/clinician_avatar.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return CircleAvatar(
                            radius: 22,
                            backgroundColor: _brandColor.withValues(alpha: 0.1),
                            child: const Icon(Icons.person_rounded, color: _brandColor),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'DPP Connect',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _brandColor,
                    ),
                  ),
                  const Spacer(),
                  // Notification bell
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: _brandColor,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Clinician Dashboard Title & Subtitle
                    const Text(
                      'Clinician Dashboard',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _brandColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Monitoring 42 active lifestyle intervention patients.',
                      style: TextStyle(
                        fontSize: 15,
                        color: _slateGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // KPI Cards Row
                    Row(
                      children: [
                        // Active Risk Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFEBF2FA), width: 1.5),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ACTIVE RISK',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _slateGrey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '08',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFD32F2F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Avg Completion Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFEBF2FA), width: 1.5),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AVG COMPLETION',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _slateGrey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '84%',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF388E3C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Filter By Header
                    const Text(
                      'FILTER BY:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _slateGrey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // High Risk Filter
                          _buildFilterChip(
                            label: 'High Risk',
                            icon: Icons.warning_amber_rounded,
                            isActive: _selectedFilter == 'High Risk',
                            activeColor: const Color(0xFFD32F2F),
                            activeBg: const Color(0xFFFFEBEE),
                            onTap: () {
                              setState(() {
                                _selectedFilter =
                                _selectedFilter == 'High Risk' ? 'All' : 'High Risk';
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          // Session Delay Filter
                          _buildFilterChip(
                            label: 'Session Delay',
                            icon: Icons.access_time_rounded,
                            isActive: _selectedFilter == 'Session Delay',
                            activeColor: const Color(0xFF8D6E63),
                            activeBg: const Color(0xFFEFEBE9),
                            onTap: () {
                              setState(() {
                                _selectedFilter =
                                _selectedFilter == 'Session Delay' ? 'All' : 'Session Delay';
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          // All Patients Filter
                          _buildFilterChip(
                            label: 'All Patients',
                            icon: null,
                            isActive: _selectedFilter == 'All',
                            activeColor: _borderBlue,
                            activeBg: const Color(0xFFE3F2FD),
                            onTap: () {
                              setState(() {
                                _selectedFilter = 'All';
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Search Patients Textfield
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                            color: _brandColor, fontWeight: FontWeight.w500),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded, color: _slateGrey),
                          hintText: 'Search patients...',
                          hintStyle:
                          TextStyle(color: _slateGrey, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                          contentPadding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Patients List Header Block
                    Container(
                      padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEBF2FA),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              'PATIENT NAME',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _brandColor),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'RISK STATUS',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _brandColor),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'WEIGHT (30D)',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _brandColor),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Patients List Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          // Elena Martinez Row
                          if (_selectedFilter == 'All' ||
                              _selectedFilter == 'High Risk')
                            _buildPatientRow(
                              initials: 'EM',
                              name: 'Elena Martinez',
                              id: 'ID: #DPP-9210',
                              riskLabel: 'HIGH',
                              riskSubLabel: 'RISK',
                              isHighRisk: true,
                              avatarBg: const Color(0xFFE3F2FD),
                              avatarFg: _borderBlue,
                              sparklinePoints: [30.0, 32.0, 31.0, 34.0, 33.0, 35.0, 34.0],
                              sparklineColor: const Color(0xFFD32F2F),
                            ),
                          // Divider
                          if (_selectedFilter == 'All')
                            const Divider(
                                height: 1,
                                color: Color(0xFFE2E8F0),
                                thickness: 1),
                          // James Blackwell Row
                          if (_selectedFilter == 'All' ||
                              _selectedFilter == 'Session Delay')
                            _buildPatientRow(
                              initials: 'JB',
                              name: 'James Blackwell',
                              id: 'ID: #DPP-8832',
                              riskLabel: 'ON',
                              riskSubLabel: 'TRACK',
                              isHighRisk: false,
                              avatarBg: const Color(0xFFE8F5E9),
                              avatarFg: const Color(0xFF388E3C),
                              sparklinePoints: [35.0, 34.0, 33.0, 31.0, 30.0, 29.0, 28.0],
                              sparklineColor: const Color(0xFF388E3C),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavDestination(0, Icons.people_outline_rounded, 'Patients'),
                  _buildNavDestination(1, Icons.home_rounded, 'Home'),
                  _buildNavDestination(
                    2,
                    Icons.mail_outline_rounded,
                    'Inbox',
                    onTap: () {
                      setState(() => _currentTabIndex = 2);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ClinicalInboxScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build filter chips
  Widget _buildFilterChip({
    required String label,
    required IconData? icon,
    required bool isActive,
    required Color activeColor,
    required Color activeBg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? activeColor
                : const Color(0xFF8D6E63).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 18,
                  color: isActive ? activeColor : const Color(0xFF8D6E63)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? activeColor : const Color(0xFF8D6E63),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build each patient row
  Widget _buildPatientRow({
    required String initials,
    required String name,
    required String id,
    required String riskLabel,
    required String riskSubLabel,
    required bool isHighRisk,
    required Color avatarBg,
    required Color avatarFg,
    required List<double> sparklinePoints,
    required Color sparklineColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: avatarBg,
            child: Text(
              initials,
              style: TextStyle(
                color: avatarFg,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Patient info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _brandColor,
                  ),
                ),
                Text(
                  id,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _slateGrey,
                  ),
                ),
              ],
            ),
          ),
          // Risk label
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighRisk
                      ? const Color(0xFFFFEBEE)
                      : const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      riskLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isHighRisk
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF388E3C),
                      ),
                    ),
                    Text(
                      riskSubLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isHighRisk
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF388E3C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Sparkline
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 32,
              child: CustomPaint(
                painter: _SparklinePainter(
                  points: sparklinePoints,
                  color: sparklineColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build navigation destinations
  Widget _buildNavDestination(
      int index,
      IconData icon,
      String label, {
        VoidCallback? onTap,
      }) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: onTap ??
              () {
            setState(() => _currentTabIndex = index);
          },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF69F0AE).withValues(alpha: 0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF00B0FF) : _slateGrey,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? _brandColor : _slateGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw a clean weight sparkline graph
class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;

  _SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final double stepX = size.width / (points.length - 1);

    // Find min and max to scale properly
    double minVal = points[0];
    double maxVal = points[0];
    for (var val in points) {
      if (val < minVal) minVal = val;
      if (val > maxVal) maxVal = val;
    }

    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    for (int i = 0; i < points.length; i++) {
      final double x = i * stepX;
      // Invert Y coordinate because canvas y goes downwards
      final double normY = (points[i] - minVal) / range;
      final double y =
          size.height - (normY * size.height * 0.8 + size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}