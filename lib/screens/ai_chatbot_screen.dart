import 'package:flutter/material.dart';

const _brandColor = Color(0xFF4A1E63); // Matches the AI button color
const _slateGrey = Color(0xFF6B7C93);

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Initial greeting message
    _messages.add(
      ChatMessage(
        text: 'Hello! I am your AI Chatbot. How can I assist you with your health and diet today?',
        isUser: false,
        time: _currentTime(),
      ),
    );
  }

  String _currentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour == 0 ? 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
          time: _currentTime(),
        ),
      );
      _isTyping = true;
    });
    
    _messageController.clear();
    _scrollToBottom();

    // Mock AI response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: _getMockResponse(text),
              isUser: false,
              time: _currentTime(),
            ),
          );
        });
        _scrollToBottom();
      }
    });
  }

  String _getMockResponse(String query) {
    query = query.toLowerCase();
    if (query.contains('diet') || query.contains('food')) {
      return 'Eating a balanced diet is key. Try incorporating more vegetables, lean proteins, and whole grains into your meals.';
    } else if (query.contains('exercise') || query.contains('workout')) {
      return 'Aim for at least 150 minutes of moderate aerobic activity or 75 minutes of vigorous activity a week.';
    } else if (query.contains('sugar') || query.contains('diabetes')) {
      return 'To manage blood sugar, focus on complex carbohydrates and avoid sugary drinks. Regular monitoring is also important.';
    } else {
      return 'That is a great question. As your AI Chatbot, I recommend discussing specific medical concerns with your healthcare provider, but I can help you find general wellness tips!';
    }
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
    _messageController.dispose();
    _scrollController.dispose();
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
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _brandColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Avatar
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFDCCCEC),
                    child: Icon(
                      Icons.auto_awesome,
                      color: _brandColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Name + online indicator
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI chatbot',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _brandColor,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF388E3C),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isTyping ? 'Typing...' : 'Active now',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF388E3C),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Info icon
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This is a mock AI interface.')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF2FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: _brandColor,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Messages area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final showDateLabel = index == 0;
                  return Column(
                    children: [
                      if (showDateLabel) ...[
                        _buildDateLabel('Today'),
                        const SizedBox(height: 12),
                      ],
                      _buildBubble(msg),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),

            // Message input bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  // Attachment icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF2FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.attach_file_rounded,
                      color: _brandColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(
                          color: _brandColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle: TextStyle(
                            color: _slateGrey,
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Send button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _brandColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateLabel(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _slateGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUserMsg = msg.isUser;
    return Align(
      alignment: isUserMsg ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isUserMsg ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUserMsg ? _brandColor : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUserMsg ? 18 : 4),
                bottomRight: Radius.circular(isUserMsg ? 4 : 18),
              ),
              border: isUserMsg
                  ? null
                  : Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                fontSize: 14,
                color: isUserMsg ? Colors.white : _brandColor,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            msg.time,
            style: const TextStyle(
              fontSize: 11,
              color: _slateGrey,
            ),
          ),
        ],
      ),
    );
  }
}
