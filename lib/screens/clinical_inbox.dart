import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dpp_app/screens/clinician_dashboard_screen.dart';
import 'package:dpp_app/screens/clinician_profile_screen.dart';
import 'package:dpp_app/screens/patient_chat_screen.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../models/coach_profile.dart';

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
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    
    // Fetch initial online status
    final coachId = AuthService().currentUser?.uid;
    if (coachId != null) {
      ChatService.getCoachOnlineStatusStream(coachId).first.then((isOnline) {
        if (mounted) setState(() => _isOnline = isOnline);
      });
    }
  }

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
          patientUid: entry.uid,
          patientName: entry.name,
          patientInitials: entry.initials,
          avatarBg: entry.avatarBg,
          avatarFg: entry.avatarFg,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'CP';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
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
                      ).then((_) {
                        setState(() {});
                      });
                    },
                    child: FutureBuilder<CoachProfile>(
                      future: AuthService().getCoachProfile(AuthService().currentUser?.uid ?? 'default_coach'),
                      builder: (context, snapshot) {
                        final localPath = snapshot.data?.localImagePath;
                        final isAvatar = localPath != null && localPath.startsWith('avatar_');
                        final fileExists = localPath != null && File(localPath).existsSync();
                        if (isAvatar) {
                          final idx = int.tryParse(localPath.replaceFirst('avatar_', '')) ?? 0;
                          return Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black87, width: 1.5),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/coaches/coach_${idx + 1}.png',
                                width: 42,
                                height: 42,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          );
                        } else if (fileExists) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(localPath),
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          );
                        }

                        final initials = snapshot.data != null ? _getInitials(snapshot.data!.name) : 'CP';
                        return CircleAvatar(
                          radius: 22,
                          backgroundColor: _brandColor.withValues(alpha: 0.1),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _brandColor,
                            ),
                          ),
                        );
                      },
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
                          onTap: () async {
                            final newStatus = !_isOnline;
                            setState(() => _isOnline = newStatus);
                            final coachId = AuthService().currentUser?.uid;
                            if (coachId != null) {
                              await ChatService.setCoachOnlineStatus(coachId, newStatus);
                            }
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
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Coachuserchats')
                          .where('coachId', isEqualTo: AuthService().currentUser?.uid)
                          .orderBy('lastMessageTime', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading inbox'));
                        }

                        final docs = snapshot.data?.docs ?? [];
                        
                        if (docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: Text(
                                'No conversations yet.',
                                style: TextStyle(color: _slateGrey, fontSize: 16),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final chatDoc = docs[index];
                            final chatData = chatDoc.data() as Map<String, dynamic>;
                            final patientId = chatData['patientId'] as String? ?? '';
                            final badgeCount = chatData['unreadByCoach'] as int? ?? 0;
                            final preview = chatData['lastMessageText'] as String? ?? 'No messages yet';
                            
                            // We use a FutureBuilder to get the patient's name
                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('users').doc(patientId).get(),
                              builder: (context, userSnapshot) {
                                if (!userSnapshot.hasData) return const SizedBox();
                                
                                final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
                                final name = userData?['name'] as String? ?? 'Unknown Patient';
                                
                                // Filter by search query if any
                                final query = _searchController.text.trim().toLowerCase();
                                if (query.isNotEmpty && !name.toLowerCase().contains(query) && !preview.toLowerCase().contains(query)) {
                                  return const SizedBox();
                                }
                                
                                final initials = _getInitials(name);
                                final avatarBg = const Color(0xFFE3F2FD);
                                final avatarFg = const Color(0xFF4A88C5);

                                final entry = _InboxEntry(
                                  uid: patientId,
                                  name: name,
                                  initials: initials,
                                  preview: preview,
                                  time: '', // We could format lastMessageTime if needed
                                  avatarBg: avatarBg,
                                  avatarFg: avatarFg,
                                  badgeCount: badgeCount,
                                );

                                return _buildMessageRow(entry);
                              },
                            );
                          },
                        );
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
                    Icons.people_rounded,
                    'Patients',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ClinicianDashboardScreen(initialTabIndex: 0)),
                      );
                    },
                  ),
                  _buildNavDestination(
                    1,
                    Icons.home_outlined,
                    Icons.home_rounded,
                    'Home',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ClinicianDashboardScreen(initialTabIndex: 1)),
                      );
                    },
                  ),
                  _buildNavDestination(
                    2,
                    Icons.mail_outline_rounded,
                    Icons.mail_rounded,
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
                if (entry.badgeCount != null && entry.badgeCount! > 0)
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
                else
                  const SizedBox(height: 24),
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
    IconData selectedIcon,
    String label, {
    VoidCallback? onTap,
  }) {
    final isSelected = _currentTabIndex == index;
    return GestureDetector(
      onTap: onTap ??
          () {
            setState(() => _currentTabIndex = index);
          },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _brandColor.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? _brandColor : _slateGrey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? _brandColor : _slateGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxEntry {
  final String uid;
  final String name;
  final String initials;
  final String preview;
  final String time;
  final Color avatarBg;
  final Color avatarFg;
  final int? badgeCount;

  const _InboxEntry({
    required this.uid,
    required this.name,
    required this.initials,
    required this.preview,
    required this.time,
    required this.avatarBg,
    required this.avatarFg,
    this.badgeCount,
  });
}