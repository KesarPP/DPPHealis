import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import 'chat_history_screen.dart';

const _brandColor = Color(0xFF4A1E63); // Matches the AI button color
const _slateGrey = Color(0xFF6B7C93);

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatRepository _chatRepository = ChatRepository();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  
  bool _isTyping = false;
  bool _isListening = false;

  final Map<String, String> _qaMap = {
    "What is prediabetes?": "Prediabetes means your blood sugar levels are higher than normal, but not yet high enough to be diagnosed as type 2 diabetes. It is a warning sign, but it can be reversed with lifestyle changes.",
    "How can I lower my blood sugar naturally?": "You can lower your blood sugar naturally by exercising regularly, eating more fiber, staying hydrated, managing stress, and getting enough sleep.",
    "What are the best foods for a diabetic diet?": "Focus on whole, unprocessed foods. Leafy greens, whole grains, lean proteins, beans, and healthy fats like avocados and nuts are excellent choices.",
    "How much exercise do I need each week?": "It is recommended to get at least 150 minutes of moderate aerobic activity (like brisk walking) per week, spread across multiple days.",
    "What are the early symptoms of diabetes?": "Common early symptoms include frequent urination, excessive thirst, feeling very hungry, extreme fatigue, blurry vision, and cuts that are slow to heal.",
  };

  final List<ChatMessage> _currentSessionMessages = [];

  @override
  void initState() {
    super.initState();
    _currentSessionMessages.add(
      ChatMessage(
        text: 'Hello! I am your AI Chatbot. I can answer specific questions about diabetes prevention.',
        isUser: false,
        time: _currentTime(),
        timestamp: DateTime.now(),
      ),
    );
  }

  void _toggleListening() async {
    if (_isListening) {
      _stopListening();
      return;
    }

    try {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        bool available = await _speechToText.initialize(
          onError: (val) {
            debugPrint('onError: $val');
            if (mounted) setState(() => _isListening = false);
          },
          onStatus: (val) {
            debugPrint('onStatus: $val');
            if (val == 'done' || val == 'notListening') {
              if (mounted) setState(() => _isListening = false);
            }
          },
        );
        if (available) {
          setState(() => _isListening = true);
          _speechToText.listen(
            onResult: (result) {
              setState(() {
                _messageController.text = result.recognizedWords;
              });
              if (result.finalResult) {
                if (mounted) setState(() => _isListening = false);
              }
            },
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Speech recognition is not available. Please check device settings.')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required to use voice chat.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting microphone: $e')),
        );
      }
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  String _currentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour == 0 ? 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // ─── VERCEL AI BACKEND CONFIGURATION ───────────────────────────────────────
  // Paste your deployed Vercel URL here (e.g., https://my-dpp-backend.vercel.app/api/chat)
  final String _vercelEndpoint = "https://your-vercel-app.vercel.app/api/chat";

  Future<String> _getVercelResponse(String query) async {
    // If the Vercel endpoint hasn't been configured yet, fallback to mock response
    if (_vercelEndpoint.contains('your-vercel-app')) {
      return _getMockResponse(query);
    }

    try {
      final response = await http.post(
        Uri.parse(_vercelEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': query,
          'user_id': 'dpp_user', // Optional user identifier for context
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          return data['response'] ?? data['reply'] ?? data['answer'] ?? data['message'] ?? response.body;
        }
        return response.body;
      } else {
        debugPrint('Vercel Error: ${response.statusCode} - ${response.body}');
        return 'I am having trouble connecting to my Vercel backend server (Error ${response.statusCode}). Please check your Vercel deployment logs and API keys.';
      }
    } catch (e) {
      debugPrint('Vercel Exception: $e');
      return 'Could not connect to the Vercel AI server. Please verify your Vercel deployment URL and network connection.';
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      time: _currentTime(),
      timestamp: DateTime.now(),
    );

    setState(() {
      _currentSessionMessages.add(userMessage);
      _isTyping = true;
    });
    
    _scrollToBottom();

    await _chatRepository.saveMessage(userMessage);

    // Fetch dynamic response from Vercel backend (Groq Primary -> Gemini Fallback)
    final aiResponseText = await _getVercelResponse(text);

    if (mounted) {
      final aiMessage = ChatMessage(
        text: aiResponseText,
        isUser: false,
        time: _currentTime(),
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _currentSessionMessages.add(aiMessage);
        _isTyping = false;
      });
      
      _scrollToBottom();
      
      await _chatRepository.saveMessage(aiMessage);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getMockResponse(String query) {
    if (_qaMap.containsKey(query)) {
      return _qaMap[query]!;
    }
    
    String normalized = query.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    
    if (normalized.contains('prediabetes')) {
      return _qaMap["What is prediabetes?"]!;
    } else if (normalized.contains('lower') && (normalized.contains('sugar') || normalized.contains('glucose'))) {
      return _qaMap["How can I lower my blood sugar naturally?"]!;
    } else if (normalized.contains('food') || normalized.contains('diet') || normalized.contains('eat')) {
      return _qaMap["What are the best foods for a diabetic diet?"]!;
    } else if (normalized.contains('exercise') || normalized.contains('workout') || normalized.contains('activity')) {
      return _qaMap["How much exercise do I need each week?"]!;
    } else if (normalized.contains('symptom') || normalized.contains('sign')) {
      return _qaMap["What are the early symptoms of diabetes?"]!;
    }
    
    return 'I can only answer specific questions about diabetes prevention. Please choose one of the suggested questions above, or ask me about diet, exercise, or symptoms!';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speechToText.stop();
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
                  // History icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChatHistoryScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF2FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
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
                itemCount: _currentSessionMessages.length,
                itemBuilder: (context, index) {
                  final msg = _currentSessionMessages[index];
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

            // Suggestion Chips
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _qaMap.length,
                itemBuilder: (context, index) {
                  final question = _qaMap.keys.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(
                        question,
                        style: const TextStyle(fontSize: 12, color: _brandColor, fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: const Color(0xFFEBF2FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFDCCCEC)),
                      ),
                      onPressed: () {
                        _messageController.text = question;
                        _sendMessage();
                      },
                    ),
                  );
                },
              ),
            ),

            // Message input bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
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
                          GestureDetector(
                            onTap: _toggleListening,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening ? Colors.red : _brandColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
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
