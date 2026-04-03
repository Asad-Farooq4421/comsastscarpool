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

  String get currentUserId => getCurrentUserId();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get chat ID from route arguments (now it's a String, not ChatModel)
    chatId = ModalRoute.of(context)!.settings.arguments as String;

    // Find chat object from dummyChats
    chat = dummyChats.firstWhere((c) => c.id == chatId);

    // Load messages for this chat using the function
    _loadMessages();

    // Mark messages as read when chat opens
    _markMessagesAsRead();
  }

  void _loadMessages() {
    setState(() {
      messages = getMessagesForChat(chatId);
    });
  }

  void _markMessagesAsRead() {
    // Use the function from dummy_messages.dart
    markMessagesAsRead(chatId);

    // Update local messages list to reflect read status
    _loadMessages();

    // Update local chat object
    final updatedChat = getChatById(chatId);
    if (updatedChat != null) {
      chat = updatedChat;
    }
  }

  void _sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    // Use the function from dummy_messages.dart
    sendMessage(
      chatId: chatId,
      text: messageController.text.trim(),
    );

    // Clear input
    messageController.clear();

    // Reload messages
    _loadMessages();

    // Update local chat object
    final updatedChat = getChatById(chatId);
    if (updatedChat != null) {
      setState(() {
        chat = updatedChat;
      });
    }

    // Scroll to bottom
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
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: chat.userPhoto.isNotEmpty
                  ? NetworkImage(chat.userPhoto)
                  : null,
              child: chat.userPhoto.isEmpty
                  ? Text(
                chat.userName.isNotEmpty
                    ? chat.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.userName,
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
              } else if (value == 'ride_details') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ride details coming soon')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'ride_details',
                child: Text('View Ride Details'),
              ),
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
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Input Bar
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

  Widget _buildMessageBubble(MessageModel message) {
    final isMe = message.isMe;

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
                  message.timestamp,
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
              Navigator.pop(context, true); // Return true to refresh chat list
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