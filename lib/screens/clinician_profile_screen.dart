import 'package:flutter/material.dart';
import 'login_screen.dart';

const _brandColor = Color(0xFF1B3D6D);
const _slateGrey = Color(0xFF6B7C93);
const _borderBlue = Color(0xFF4A88C5);

class ClinicianProfileScreen extends StatelessWidget {
  const ClinicianProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'Clinician Profile',
          style: TextStyle(color: _brandColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: _brandColor),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // ── Doctor Banner Card ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/clinician_avatar.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return CircleAvatar(
                        radius: 36,
                        backgroundColor: _brandColor.withValues(alpha: 0.1),
                        child: const Icon(Icons.person_rounded, size: 36, color: _brandColor),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dr. Alexander Ross',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _brandColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Lead Lifestyle Interventionist',
                        style: TextStyle(
                          fontSize: 14,
                          color: _slateGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'DiaPrevent Health Center',
                        style: TextStyle(
                          fontSize: 13,
                          color: _slateGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Metrics Statistics Grid ─────────────────────────────
          const _SectionHeader(title: 'Overview Metrics'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: 'Patients',
                  value: '42 Active',
                  icon: Icons.people_rounded,
                  iconColor: _borderBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricItem(
                  title: 'Completion',
                  value: '84% Avg',
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF388E3C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Assigned Cohorts ──────────────────────────────────
          const _SectionHeader(title: 'Assigned Cohorts'),
          const SizedBox(height: 8),
          _buildItemCard(
            icon: Icons.group_work_rounded,
            iconColor: const Color(0xFF8D6E63),
            title: 'DPP Cohort 3',
            subtitle: '18 active patient plans • 88% completion rate',
          ),
          _buildItemCard(
            icon: Icons.group_work_rounded,
            iconColor: const Color(0xFF8D6E63),
            title: 'Pre-Diabetes Support Group 1',
            subtitle: '24 active patient plans • 80% completion rate',
          ),
          const SizedBox(height: 24),

          // ── Settings & Preferences ────────────────────────────
          const _SectionHeader(title: 'Preferences'),
          const SizedBox(height: 8),
          _buildItemCard(
            icon: Icons.notifications_none_rounded,
            iconColor: _borderBlue,
            title: 'Notification Schedule',
            subtitle: 'Daily morning highlights & high-risk alerts',
          ),
          _buildItemCard(
            icon: Icons.security_outlined,
            iconColor: _borderBlue,
            title: 'Security & Consent',
            subtitle: 'Secure HIPAA compliant encryption details',
          ),
          const SizedBox(height: 24),

          // ── Sign Out Button ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F)),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFD32F2F),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                // Clear navigator state and route back to Login screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Helper to build metrics details
  Widget _buildMetricItem({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _slateGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _brandColor,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build lists or selections card
  Widget _buildItemCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _brandColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _slateGrey,
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

// Section Header Helper
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: _slateGrey,
        letterSpacing: 0.5,
      ),
    );
  }
}
