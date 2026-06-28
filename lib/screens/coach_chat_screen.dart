import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/gelato_theme.dart';
import 'coach_profile_screen.dart';
import 'coach_selection_screen.dart';
import '../services/auth_service.dart';
import '../models/coach_profile.dart';
import '../services/chat_service.dart';

class CoachChatScreen extends StatefulWidget {
  const CoachChatScreen({super.key});

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  String? _assignedCoachId;
  bool _isLoadingStatus = true;
  CoachProfile? _coachProfile;

  StreamSubscription<DocumentSnapshot>? _userSubscription;

  @override
  void initState() {
    super.initState();
    _listenToUserDoc();
  }

  void _listenToUserDoc() {
    final user = AuthService().currentUser;
    if (user != null) {
      _userSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) async {
        if (doc.exists) {
          final newAssignedCoachId = doc.data()?['assignedCoachId'] as String?;
          
          if (newAssignedCoachId != _assignedCoachId) {
            _assignedCoachId = newAssignedCoachId;
            
            if (_assignedCoachId != null && _assignedCoachId != 'ADMIN_PENDING') {
              final profile = await AuthService().getCoachProfile(_assignedCoachId!);
              if (mounted) {
                setState(() {
                  _coachProfile = profile;
                  _isLoadingStatus = false;
                });
              }
            } else {
              if (mounted) {
                setState(() {
                  _coachProfile = null;
                  _isLoadingStatus = false;
                });
              }
            }
          } else if (mounted && _isLoadingStatus) {
            setState(() {
              _isLoadingStatus = false;
            });
          }
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _isLoadingStatus = false;
        });
      }
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _assignedCoachId == null) return;
    _messageController.clear();
    
    final currentUserId = AuthService().currentUser?.uid;
    if (currentUserId == null) return;

    await ChatService.sendMessage(
      patientId: currentUserId,
      coachId: _assignedCoachId!,
      text: text,
      senderId: currentUserId,
      isFromPatient: true,
    );
    _scrollToBottom();
  }

  void _sendDirectMessage(String text) async {
    if (text.isEmpty || _assignedCoachId == null) return;
    
    final currentUserId = AuthService().currentUser?.uid;
    if (currentUserId == null) return;

    await ChatService.sendMessage(
      patientId: currentUserId,
      coachId: _assignedCoachId!,
      text: text,
      senderId: currentUserId,
      isFromPatient: true,
    );
    _scrollToBottom();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final now = timestamp.toDate();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour == 0 ? 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

@override
void dispose() {
  _userSubscription?.cancel();
  _messageController.dispose();
  _scrollController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
  if (_isLoadingStatus) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      body: const Center(child: CircularProgressIndicator(color: GelatoTheme.purpleDark)),
    );
  }

  if (_assignedCoachId == null || _assignedCoachId!.isEmpty) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Your Coach',
          style: TextStyle(color: GelatoTheme.textDark, fontWeight: FontWeight.w900),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off_rounded, size: 80, color: Colors.black26),
              const SizedBox(height: 16),
              const Text(
                'No coach assigned or selected.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GelatoTheme.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CoachSelectionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GelatoTheme.purple,
                  foregroundColor: GelatoTheme.purpleDark,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Colors.black, width: 2.0),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select a Coach',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  if (_assignedCoachId == 'ADMIN_PENDING') {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Your Coach',
          style: TextStyle(color: GelatoTheme.textDark, fontWeight: FontWeight.w900),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_empty_rounded, size: 80, color: GelatoTheme.orangeDark),
              const SizedBox(height: 16),
              const Text(
                'You will soon be assigned a coach.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GelatoTheme.textDark),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Our team is matching you with the best professional for your needs.',
                style: TextStyle(fontSize: 14, color: GelatoTheme.textLight),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  return Scaffold(
    backgroundColor: GelatoTheme.bg,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CoachProfileScreen(coachId: _assignedCoachId)),
          );
        },
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black87, width: 1.5),
                  ),
                  child: ClipOval(
                    child: (_coachProfile?.localImagePath != null && _coachProfile!.localImagePath!.startsWith('avatar_'))
                        ? Image.asset(
                            'assets/images/coaches/coach_${(int.tryParse(_coachProfile!.localImagePath!.replaceFirst('avatar_', '')) ?? 0) + 1}.png',
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          )
                        : (_coachProfile?.localImagePath != null && File(_coachProfile!.localImagePath!).existsSync())
                            ? Image.file(
                                File(_coachProfile!.localImagePath!),
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/clinician_avatar.png',
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const CircleAvatar(
                                  radius: 19,
                                  backgroundColor: GelatoTheme.purple,
                                  child: Icon(Icons.person_rounded, color: GelatoTheme.textDark, size: 22),
                                ),
                              ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: GelatoTheme.purple,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87, width: 1.2),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: GelatoTheme.purpleDark,
                      size: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Coach',
                      style: TextStyle(
                        color: GelatoTheme.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, color: GelatoTheme.purpleDark, size: 14),
                  ],
                ),
                StreamBuilder<bool>(
                  stream: _assignedCoachId != null
                      ? ChatService.getCoachOnlineStatusStream(_assignedCoachId!)
                      : Stream.value(true),
                  builder: (context, snapshot) {
                    final isOnline = snapshot.data ?? true;
                    return Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isOnline ? GelatoTheme.greenDark : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: isOnline ? GelatoTheme.greenDark : Colors.grey,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: GelatoTheme.textDark, size: 22),
          onPressed: () {
            final name = _coachProfile?.name ?? 'Dr. Sarah Mitchell';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Starting voice call with $name...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: GelatoTheme.textDark, size: 22),
          onPressed: () {
            final name = _coachProfile?.name ?? 'Dr. Sarah Mitchell';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Starting video call with $name...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: Container(color: Colors.black87, height: 2.0),
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _assignedCoachId != null
                ? ChatService.getChatStream(AuthService().currentUser!.uid, _assignedCoachId!)
                : const Stream.empty(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData && _assignedCoachId != null) {
                // Clear the unread count since we are viewing the chat
                ChatService.markChatAsRead(
                  patientId: AuthService().currentUser!.uid,
                  coachId: _assignedCoachId!,
                  isCoach: false,
                );
              }

              final docs = snapshot.data?.docs ?? [];
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: docs.length + 1, // +1 for the welcome header card
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildWelcomeCard(_coachProfile?.name ?? 'Dr. Sarah Mitchell');
                  }
                  final data = docs[index - 1].data() as Map<String, dynamic>;
                  final isUser = data['isFromPatient'] as bool? ?? false;
                  final timeStr = _formatTimestamp(data['timestamp'] as Timestamp?);

                  return _buildChatBubble(
                    data['text'] as String? ?? '',
                    isUser,
                    timeStr,
                  );
                },
              );
            },
          ),
        ),
        if (_isTyping) _buildTypingIndicator(),
        _buildQuickChips(),
        _buildMessageInput(),
      ],
    ),
  );
}

Widget _buildWelcomeCard(String coachName) {
  return Container(
    margin: const EdgeInsets.only(bottom: 24, top: 4),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: GelatoTheme.purple,
      borderRadius: GelatoTheme.cardRadius,
      border: GelatoTheme.cardBorder,
      boxShadow: GelatoTheme.cardShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Icon(Icons.star_rounded, color: GelatoTheme.purpleDark, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Personal Coach',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: GelatoTheme.textDark,
                    ),
                  ),
                  Text(
                    'Direct Chat Access',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: GelatoTheme.purpleDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${coachName == 'Dr. Sarah Mitchell' ? 'Dr. Mitchell' : coachName} is here to guide you through your Diabetes Prevention Program. Ask about meal planning, increasing fitness, or review metabolic health insights together.',
          style: const TextStyle(
            fontSize: 13,
            color: GelatoTheme.textDark,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

Widget _buildChatBubble(String text, bool isUser, String time) {
  return Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? GelatoTheme.blue : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 20),
              ),
              border: Border.all(color: Colors.black87, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(2.5, 2.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: GelatoTheme.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: GelatoTheme.textLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all_rounded, size: 14, color: GelatoTheme.blueDark),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildTypingIndicator() {
  return Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'typing...',
            style: const TextStyle(
              color: GelatoTheme.textLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(GelatoTheme.purpleDark),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildQuickChips() {
  final chips = [
    {'label': 'Review my meals', 'icon': '🍎'},
    {'label': 'Check my glucose', 'icon': '📈'},
    {'label': 'Adjust activity goals', 'icon': '🏃'},
    {'label': 'Feeling unmotivated', 'icon': '🧘'},
  ];

  return Container(
    height: 44,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: chips.length,
      itemBuilder: (context, index) {
        final chip = chips[index];
        return GestureDetector(
          onTap: () => _sendDirectMessage(chip['label']!),
          child: Container(
            margin: const EdgeInsets.only(right: 8, bottom: 4, top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black87, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(1.5, 1.5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Text(chip['icon']!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  chip['label']!,
                  style: const TextStyle(
                    color: GelatoTheme.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildMessageInput() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(
        top: BorderSide(color: Colors.black87, width: 2.0),
      ),
    ),
    child: SafeArea(
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File attachment selected.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GelatoTheme.orange,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(1.5, 1.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: GelatoTheme.textDark, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: GelatoTheme.bg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black87, width: 1.5),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: Colors.black38,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(
                  color: GelatoTheme.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GelatoTheme.pink,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black87, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: GelatoTheme.textDark, size: 20),
            ),
          ),
        ],
      ),
    ),
  );
}
}
