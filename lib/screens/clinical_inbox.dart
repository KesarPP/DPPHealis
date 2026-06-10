import 'package:flutter/material.dart';
import 'clinician_dashboard_screen.dart';
import 'clinician_profile_screen.dart';

const _brandColor = Color(0xFF1B3D6D);
const _slateGrey = Color(0xFF6B7C93);
const _borderBlue = Color(0xFF4A88C5);

class ClinicalInboxScreen extends StatefulWidget {
  const ClinicalInboxScreen({super.key});

  @override
  State<ClinicalInboxScreen> createState() => _ClinicalInboxScreenState();
}

class _ClinicalInboxScreenState extends State<ClinicalInboxScreen> {
  int _currentTabIndex = 2;
  bool _isOnline = true;
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
                        MaterialPageRoute(
                            builder: (_) => const ClinicianProfileScreen()),
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
                            child: const Icon(Icons.person_rounded,
                                color: _brandColor),
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

                    // Title row with Online/Offline toggle
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Message Inbox',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _brandColor,
                          ),
                        ),
                        const Spacer(),
                        // Online / Offline toggle pill
                        GestureDetector(
                          onTap: () {
                            setState(() => _isOnline = !_isOnline);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _isOnline
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isOnline
                                    ? const Color(0xFF388E3C)
                                    : const Color(0xFFCBD5E0),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isOnline
                                        ? const Color(0xFF388E3C)
                                        : _slateGrey,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _isOnline
                                        ? const Color(0xFF388E3C)
                                        : _slateGrey,
                                  ),
                                  child: Text(_isOnline ? 'Online' : 'Offline'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search bar
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
                          prefixIcon:
                              Icon(Icons.search_rounded, color: _slateGrey),
                          hintText: 'Filter by patient name or message...',
                          hintStyle: TextStyle(
                              color: _slateGrey, fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Message list
                    _buildMessageRow(
                      initials: 'SS',
                      name: 'Sara Sanders',
                      preview: 'Glucose levels seem stable af...',
                      time: '12:35',
                      avatarBg: const Color(0xFFE3F2FD),
                      avatarFg: _borderBlue,
                      badgeCount: 100,
                      hasPhoto: false,
                    ),
                    const SizedBox(height: 10),
                    _buildMessageRow(
                      initials: 'DD',
                      name: 'Doris Diaz',
                      preview: "I've attached the new laborat...",
                      time: '12:35',
                      avatarBg: const Color(0xFFEDE7F6),
                      avatarFg: const Color(0xFF7B1FA2),
                      badgeCount: 99,
                      hasPhoto: false,
                    ),
                    const SizedBox(height: 10),
                    _buildMessageRow(
                      initials: 'DO',
                      name: 'Dorothy Oliver',
                      preview: 'Thank you for the dietary ...',
                      time: '12:35',
                      avatarBg: const Color(0xFFE8F5E9),
                      avatarFg: const Color(0xFF388E3C),
                      badgeCount: null,
                      isActive: true,
                      hasPhoto: false,
                    ),
                    const SizedBox(height: 10),
                    _buildMessageRow(
                      initials: 'RF',
                      name: 'Rebecca Fox',
                      preview: 'What do you need for the next ap...',
                      time: '12:35',
                      avatarBg: const Color(0xFFFFF3E0),
                      avatarFg: const Color(0xFFF57C00),
                      badgeCount: null,
                      hasPhoto: false,
                    ),
                    const SizedBox(height: 10),
                    _buildMessageRow(
                      initials: 'LM',
                      name: 'Louisa McCoy',
                      preview: 'My insulin levels were higher this ...',
                      time: '12:35',
                      avatarBg: const Color(0xFFE3F2FD),
                      avatarFg: _borderBlue,
                      badgeCount: null,
                      hasPhoto: false,
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
                  _buildNavDestination(
                    0,
                    Icons.people_outline_rounded,
                    'Patients',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ClinicianDashboardScreen()),
                      );
                    },
                  ),
                  _buildNavDestination(1, Icons.home_rounded, 'Home',
                      onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ClinicianDashboardScreen()),
                    );
                  }),
                  _buildNavDestination(
                    2,
                    Icons.mail_outline_rounded,
                    'Inbox',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageRow({
    required String initials,
    required String name,
    required String preview,
    required String time,
    required Color avatarBg,
    required Color avatarFg,
    required bool hasPhoto,
    int? badgeCount,
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: avatarBg,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: avatarFg,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Name + preview
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _brandColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  preview,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _slateGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Time + badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: _slateGrey,
                ),
              ),
              const SizedBox(height: 4),
              if (badgeCount != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _borderBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              else if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF388E3C),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

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