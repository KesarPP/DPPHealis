import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import 'package:intl/intl.dart';

const _brandColor = Color(0xFF4A1E63);
const _slateGrey = Color(0xFF6B7C93);

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final ChatRepository _chatRepository = ChatRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _brandColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat History',
          style: TextStyle(
            color: _brandColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1.0,
          ),
        ),
      ),
      body: StreamBuilder<List<ChatMessage>>(
        stream: _chatRepository.getMessagesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _brandColor));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading history: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          
          final messages = snapshot.data ?? [];
          
          if (messages.isEmpty) {
            return const Center(
              child: Text(
                'No past conversations found.',
                style: TextStyle(color: _slateGrey, fontSize: 16),
              ),
            );
          }

          // Group messages by date
          final Map<String, List<ChatMessage>> groupedMessages = {};
          for (var msg in messages) {
            final dateKey = DateFormat('MMM d, yyyy').format(msg.timestamp);
            if (!groupedMessages.containsKey(dateKey)) {
              groupedMessages[dateKey] = [];
            }
            groupedMessages[dateKey]!.add(msg);
          }

          final dates = groupedMessages.keys.toList().reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final dateKey = dates[index];
              final dayMessages = groupedMessages[dateKey]!;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                elevation: 0,
                color: Colors.white,
                child: ExpansionTile(
                  title: Text(
                    dateKey,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: _brandColor),
                  ),
                  leading: const Icon(Icons.calendar_today_rounded, color: _brandColor, size: 20),
                  iconColor: _brandColor,
                  collapsedIconColor: _slateGrey,
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: dayMessages.map((msg) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildBubble(msg, msg.isUser),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
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
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }

  Widget _buildBubble(ChatMessage msg, bool isUserMsg) {
    return Align(
      alignment: isUserMsg ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUserMsg ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isUserMsg ? const Color(0xFFEBF2FA) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUserMsg ? 16 : 4),
                bottomRight: Radius.circular(isUserMsg ? 4 : 16),
              ),
              border: Border.all(
                color: isUserMsg ? const Color(0xFFDCCCEC) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              msg.text,
              style: const TextStyle(
                fontSize: 14,
                color: _brandColor,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUserMsg) const Icon(Icons.auto_awesome, size: 12, color: _brandColor),
              if (!isUserMsg) const SizedBox(width: 4),
              Text(
                '${msg.time} ${DateFormat('MM/dd').format(msg.timestamp)}',
                style: const TextStyle(fontSize: 11, color: _slateGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
