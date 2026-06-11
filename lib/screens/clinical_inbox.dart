import 'package:flutter/material.dart';
import 'package:dpp_app/screens/clinician_dashboard_screen.dart';
import 'package:dpp_app/screens/clinician_profile_screen.dart';
import 'package:dpp_app/screens/patient_chat_screen.dart';

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

  // All inbox entries in one place — easy to extend
  final List<_InboxEntry> _entries = const [
    _InboxEntry(
      name: 'Sara Sanders',
      initials: 'SS',
      preview: 'Glucose levels seem stable af...',
      time: '12:35',
      avatarBg: Color(0xFFE3F2FD),
      avatarFg: Color(0xFF4A88C5),
      badgeCount: 100,
    ),
    _InboxEntry(
      name: 'Doris Diaz',
      initials: 'DD',
      preview: "I've attached the new laborat...",
      time: '12:35',
      avatarBg: Color(0xFFEDE7F6),
      avatarFg: Color(0xFF7B1FA2),
      badgeCount: 99,
    ),
    _InboxEntry(
      name: 'Dorothy Oliver',
      initials: 'DO',
      preview: 'Thank you for the dietary ...',
      time: '12:35',
      avatarBg: Color(0xFFE8F5E9),
      avatarFg: Color(0xFF388E3C),
      isActive: true,
    ),
    _InboxEntry(
      name: 'Rebecca Fox',
      initials: 'RF',
      preview: 'What do you need for the next ap...',
      time: '12:35',
      avatarBg: Color(0xFFFFF3E0),
      avatarFg: Color(0xFFF57C00),
    ),
    _InboxEntry(
      name: 'Louisa McCoy',
      initials: 'LM',
      preview: 'My insulin levels were higher this ...',
      time: '12:35',
      avatarBg: Color(0xFFE3F2FD),
      avatarFg: Color(0xFF4A88C5),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(_InboxEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientChatScreen(
          patientName: entry.name,
          patientInitials: entry.initials,
          avatarBg: entry.avatarBg,
          avatarFg: entry.avatarFg,
        ),
      ),
    );
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

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Title + Online toggle
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
                        GestureDetector(
                          onTap: () => setState(() => _isOnline = !_isOnline),
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
                                  child:
                                      Text(_isOnline ? 'Online' : 'Offline'),
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
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return _buildMessageRow(_entries[index]);
                      },
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
                  _buildNavDestination(
                    1,
                    Icons.home_rounded,
                    'Home',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ClinicianDashboardScreen()),
                      );
                    },
                  ),
                  _buildNavDestination(2, Icons.mail_outline_rounded, 'Inbox'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageRow(_InboxEntry entry) {
    return GestureDetector(
      onTap: () => _openChat(entry),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: entry.avatarBg,
              child: Text(
                entry.initials,
                style: TextStyle(
                  color: entry.avatarFg,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                    mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _brandColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.preview,
                    style: const TextStyle(fontSize: 13, color: _slateGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.time,
                  style:
                      const TextStyle(fontSize: 12, color: _slateGrey),
                ),
                const SizedBox(height: 4),
                if (entry.badgeCount != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _borderBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      entry.badgeCount! > 99
                          ? '99+'
                          : '${entry.badgeCount}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (entry.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? _brandColor : _slateGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// Simple immutable data model for inbox entries
class _InboxEntry {
  final String name;
  final String initials;
  final String preview;
  final String time;
  final Color avatarBg;
  final Color avatarFg;
  final int? badgeCount;
  final bool isActive;

  const _InboxEntry({
    required this.name,
    required this.initials,
    required this.preview,
    required this.time,
    required this.avatarBg,
    required this.avatarFg,
    this.badgeCount,
    this.isActive = false,
  });
}