import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../data/dummy_messages.dart';
import '../../data/dummy_chats.dart';
import '../../data/dummy_users.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';

class IndividualChatScreen extends StatefulWidget {
  const IndividualChatScreen({super.key});

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  late String chatId;
  late ChatModel chat;
  List<MessageModel> messages = [];
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  String get currentUserId => getCurrentUserId();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
  }

  void _initializeChat() {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String) {
      chatId = args;
      final foundChat = getChatById(chatId);
      if (foundChat != null) {
        chat = foundChat;
        _loadMessages();
        _markMessagesAsRead();
        _scrollToBottom();
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _loadMessages() {
    setState(() {
      messages = getMessagesForChat(chatId);
    });
  }

  // ✅ FIXED: Mark messages as read and reset unread count for current user
  void _markMessagesAsRead() {
    final currentUser = currentUserId;

    // Mark all unread messages as read
    bool updated = false;
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].receiverId == currentUser && !messages[i].isRead) {
        messages[i] = messages[i].copyWith(isRead: true);
        updated = true;
      }
    }

    if (updated) {
      // Reset unread count for current user in this chat
      resetUnreadCount(chatId);
      setState(() {});
      print('✅ Messages marked as read for user: $currentUser in chat: $chatId');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && messages.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    sendMessage(
      chatId: chatId,
      text: messageText,
    );

    messageController.clear();
    _loadMessages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  String getOtherUserName() {
    final otherUserId = chat.getOtherParticipant(currentUserId);
    final user = getUserByEmail(otherUserId);
    return user?['name'] ?? otherUserId.split('@').first;
  }

  String getOtherUserPhoto() {
    final otherUserId = chat.getOtherParticipant(currentUserId);
    final user = getUserByEmail(otherUserId);
    return user?['photo'] as String? ?? '';
  }

  String getOtherUserFirstLetter() {
    final name = getOtherUserName();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final otherUserName = getOtherUserName();
    final otherUserPhoto = getOtherUserPhoto();
    final otherUserFirstLetter = getOtherUserFirstLetter();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            otherUserPhoto.isNotEmpty
                ? CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: NetworkImage(otherUserPhoto),
              onBackgroundImageError: (_, __) {},
            )
                : CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                otherUserFirstLetter,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  otherUserName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Online',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.green,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'report') {
                _showReportDialog();
              } else if (value == 'block') {
                _showBlockDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Text('Report User'),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Text('Block User', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.senderId == currentUserId;
                return _buildMessageBubble(message, isMe);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTextStyles.inputHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          border: isMe ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTimeForDisplay(message.timestamp),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : AppColors.textHint,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: isMe ? Colors.white70 : AppColors.textHint,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeForDisplay(String timestamp) {
    if (timestamp.contains(' ')) {
      final parts = timestamp.split(' ');
      if (parts.length >= 2) {
        final timeParts = parts[1].split(':');
        if (timeParts.length >= 2) {
          int hour = int.parse(timeParts[0]);
          final minute = timeParts[1];
          final amPm = hour >= 12 ? 'PM' : 'AM';
          hour = hour % 12;
          if (hour == 0) hour = 12;
          return '$hour:$minute $amPm';
        }
      }
    }
    return timestamp;
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report User'),
        content: const Text('Are you sure you want to report this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User reported successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text('Are you sure you want to block this user? You will no longer receive messages from them.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User blocked successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }
}