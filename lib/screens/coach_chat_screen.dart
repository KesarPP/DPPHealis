import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import 'coach_profile_screen.dart';

class CoachChatScreen extends StatefulWidget {
  const CoachChatScreen({super.key});

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'isUser': false,
      'text': 'Hi Jannice! I am Dr. Sarah Mitchell, your dedicated health coach. How are you feeling today?',
      'time': '09:00 AM',
    },
    {
      'isUser': true,
      'text': 'I am feeling great, but a little hungry!',
      'time': '09:05 AM',
    },
    {
      'isUser': false,
      'text': 'It is totally normal! Remember your goals, you can have a healthy snack like almonds or an apple.',
      'time': '09:06 AM',
    },
  ];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    _handleNewUserMessage(text);
  }

  void _handleNewUserMessage(String text) {
    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
        'time': _getCurrentTime(),
      });
    });
    _scrollToBottom();
    _simulateResponse(text);
  }

  String _getCurrentTime() {
    final now = DateTime.now();
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

void _simulateResponse(String userText) {
  setState(() {
    _isTyping = true;
  });
  _scrollToBottom();

  String responseText = "Thanks for letting me know! Let's continue working on your health targets. Let me know if you have any questions.";
  final lowerText = userText.toLowerCase();

  if (lowerText.contains('meal') || lowerText.contains('food') || lowerText.contains('snack') || lowerText.contains('hungry')) {
    responseText = "Eating regular, nutrient-dense meals is key. I'd love to review your food logs. Make sure to pair carbohydrates with healthy fats or proteins (like Greek yogurt or nuts) to keep blood sugar stable!";
  } else if (lowerText.contains('glucose') || lowerText.contains('sugar') || lowerText.contains('blood')) {
    responseText = "Tracking your glucose levels consistently gives us great insights. A quick 10-15 minute walk right after meals can significantly blunt any post-meal glucose spikes. Try it out today!";
  } else if (lowerText.contains('activity') || lowerText.contains('goal') || lowerText.contains('exercise') || lowerText.contains('walk')) {
    responseText = "To help lower your insulin resistance, we target 150 minutes of moderate activity weekly. Let's adjust your current plan slightly—maybe adding 5 minutes to each session this week?";
  } else if (lowerText.contains('motivation') || lowerText.contains('unmotivated') || lowerText.contains('hard') || lowerText.contains('tired')) {
    responseText = "Be kind to yourself! Progress is not linear. Even small adjustments like choosing water over juice or standing up every hour makes a huge difference. You've got this, Jannice!";
  }

  Future.delayed(const Duration(seconds: 2), () {
    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add({
        'isUser': false,
        'text': responseText,
        'time': _getCurrentTime(),
      });
    });
    _scrollToBottom();
  });
}

@override
void dispose() {
  _messageController.dispose();
  _scrollController.dispose();
  super.dispose();
}

@override
Widget build(BuildContext context) {
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
            MaterialPageRoute(builder: (_) => const CoachProfileScreen()),
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
                    child: Image.asset(
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Coach',
                      style: TextStyle(
                        color: GelatoTheme.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.verified_rounded, color: GelatoTheme.purpleDark, size: 14),
                  ],
                ),
                Text(
                  'Online',
                  style: TextStyle(
                    color: GelatoTheme.greenDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Starting voice call with Dr. Sarah Mitchell...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: GelatoTheme.textDark, size: 22),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Starting video call with Dr. Sarah Mitchell...'),
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
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _messages.length + 1, // +1 for the welcome header card
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildWelcomeCard();
              }
              final message = _messages[index - 1];
              final isUser = message['isUser'] as bool;
              return _buildChatBubble(
                message['text'] as String,
                isUser,
                message['time'] as String,
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

Widget _buildWelcomeCard() {
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
        const Text(
          'Dr. Mitchell is here to guide you through your Diabetes Prevention Program. Ask about meal planning, increasing fitness, or review metabolic health insights together.',
          style: TextStyle(
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Dr. Sarah is typing',
            style: TextStyle(
              color: GelatoTheme.textLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
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
          onTap: () => _handleNewUserMessage(chip['label']!),
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
