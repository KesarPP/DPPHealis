import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';

const _brandColor = Color(0xFF1B3D6D);
const _slateGrey = Color(0xFF6B7C93);

class PatientChatScreen extends StatefulWidget {
  final String patientUid;
  final String patientName;
  final String patientInitials;
  final Color avatarBg;
  final Color avatarFg;

  const PatientChatScreen({
    super.key,
    required this.patientUid,
    required this.patientName,
    required this.patientInitials,
    required this.avatarBg,
    required this.avatarFg,
  });

  @override
  State<PatientChatScreen> createState() => _PatientChatScreenState();
}

class _PatientChatScreenState extends State<PatientChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedAttachmentName;
  String? _selectedAttachmentType;
  String? _selectedAttachmentPath;

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedAttachmentName == null) return;
    _messageController.clear();
    
    final currentCoachId = AuthService().currentUser?.uid;
    if (currentCoachId == null) return;

    final attachmentName = _selectedAttachmentName;
    final attachmentType = _selectedAttachmentType;
    final attachmentPath = _selectedAttachmentPath;

    setState(() {
      _selectedAttachmentName = null;
      _selectedAttachmentType = null;
      _selectedAttachmentPath = null;
    });

    await ChatService.sendMessage(
      patientId: widget.patientUid,
      coachId: currentCoachId,
      text: text.isEmpty ? (attachmentType == 'image' ? 'Sent an image' : 'Sent a document') : text,
      senderId: currentCoachId,
      isFromPatient: false,
      attachmentName: attachmentName,
      attachmentType: attachmentType,
      attachmentPath: attachmentPath,
    );

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

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image_outlined, color: _brandColor),
                title: const Text('Pick Image from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(context);
                  _pickImageAttachment();
                },
              ),
              ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined, color: _brandColor),
                title: const Text('Attach Document (PDF, Word, etc.)', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocumentAttachment();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageAttachment() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedAttachmentName = image.name;
          _selectedAttachmentType = 'image';
          _selectedAttachmentPath = image.path;
        });
      }
    } catch (_) {}
  }

  Future<void> _pickDocumentAttachment() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        setState(() {
          _selectedAttachmentName = file.name;
          _selectedAttachmentType = 'document';
          _selectedAttachmentPath = file.path;
        });
      }
    } catch (_) {}
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final now = timestamp.toDate();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour == 0 ? 12 : now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: widget.avatarBg,
                    child: Text(
                      widget.patientInitials,
                      style: TextStyle(
                        color: widget.avatarFg,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Name + online indicator
                  Expanded(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patientName,
                          style: const TextStyle(
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
                            const Text(
                              'Active now',
                              style: TextStyle(
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
                  // Call icon
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF2FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.call_outlined,
                      color: _brandColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Messages area
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: ChatService.getChatStream(widget.patientUid, AuthService().currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData) {
                    ChatService.markChatAsRead(
                      patientId: widget.patientUid,
                      coachId: AuthService().currentUser!.uid,
                      isCoach: true,
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final showDateLabel = index == 0;
                      
                      final msg = _ChatMessage(
                        text: data['text'] as String? ?? '',
                        isFromPatient: data['isFromPatient'] as bool? ?? true,
                        time: _formatTimestamp(data['timestamp'] as Timestamp?),
                        attachmentName: data['attachmentName'] as String?,
                        attachmentType: data['attachmentType'] as String?,
                        attachmentPath: data['attachmentPath'] as String?,
                      );

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
                  );
                },
              ),
            ),

             // Message input bar
            Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedAttachmentName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7F9FC),
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedAttachmentType == 'image'
                                ? Icons.image_rounded
                                : Icons.insert_drive_file_rounded,
                            color: _brandColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedAttachmentName!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _brandColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAttachmentName = null;
                                _selectedAttachmentType = null;
                                _selectedAttachmentPath = null;
                              });
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.red,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Row(
                      children: [
                        // Attachment icon
                        GestureDetector(
                          onTap: _showAttachmentOptions,
                          child: Container(
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
                                hintText: 'Type a message...',
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

  Widget _buildBubble(_ChatMessage msg) {
    final isClinicianMsg = !msg.isFromPatient;
    return Align(
      alignment: isClinicianMsg ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isClinicianMsg ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isClinicianMsg ? _brandColor : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isClinicianMsg ? 18 : 4),
                bottomRight: Radius.circular(isClinicianMsg ? 4 : 18),
              ),
              border: isClinicianMsg
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (msg.attachmentName != null) ...[
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening attachment: ${msg.attachmentName}'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isClinicianMsg ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isClinicianMsg ? Colors.white30 : const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            msg.attachmentType == 'image'
                                ? Icons.image_rounded
                                : Icons.insert_drive_file_rounded,
                            color: isClinicianMsg ? Colors.white : _brandColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg.attachmentName!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: isClinicianMsg ? Colors.white : _brandColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  msg.attachmentType == 'image' ? 'Image File' : 'PDF Document',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isClinicianMsg ? Colors.white70 : _slateGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                Text(
                  msg.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isClinicianMsg ? Colors.white : _brandColor,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
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

class _ChatMessage {
  final String text;
  final bool isFromPatient;
  final String time;
  final String? attachmentName;
  final String? attachmentType;
  final String? attachmentPath;

  _ChatMessage({
    required this.text,
    required this.isFromPatient,
    required this.time,
    this.attachmentName,
    this.attachmentType,
    this.attachmentPath,
  });
}