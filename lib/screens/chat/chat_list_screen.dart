import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../data/dummy_chats.dart';
import '../../data/dummy_messages.dart';
import '../../models/chat_model.dart';
import '../../utils/routes.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ChatModel> chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when coming back from individual chat
    _loadChats();
  }

  void _loadChats() {
    // Get only current user's chats
    final currentUserChats = getCurrentUserChats();

    // Update unread counts for each chat
    for (int i = 0; i < currentUserChats.length; i++) {
      final chat = currentUserChats[i];
      final unreadCount = getUnreadCountForChat(chat.id);

      // Update unread count in the chat object
      if (chat.unread != unreadCount) {
        final chatIndex = dummyChats.indexWhere((c) => c.id == chat.id);
        if (chatIndex != -1) {
          dummyChats[chatIndex] = chat.copyWith(unread: unreadCount);
        }
      }
    }

    setState(() {
      // Get fresh list after updates
      chats = List.from(getCurrentUserChats());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Gradient Header
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messages',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Chat with your ride partners',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: chats.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatCard(context, chat);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation by requesting a ride',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(BuildContext context, ChatModel chat) {
    return InkWell(
      onTap: () async {
        // Reset unread count when opening chat
        resetUnreadCount(chat.id);

        // Navigate to individual chat
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.individualChat,
          arguments: chat.id, // Pass chat ID instead of full object
        );

        // Refresh chat list when coming back
        if (result == true) {
          _loadChats();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Profile Photo with Unread Badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: chat.userPhoto.isNotEmpty
                      ? NetworkImage(chat.userPhoto)
                      : null,
                  onBackgroundImageError: (_, _) {},
                  child: chat.userPhoto.isEmpty
                      ? Text(
                    chat.userName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                      : null,
                ),
                // Unread Badge - ONLY on profile circle
                if (chat.unread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          chat.unread > 9 ? '9+' : '${chat.unread}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.userName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        chat.timestamp,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage.isEmpty
                              ? 'No messages yet'
                              : chat.lastMessage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: chat.unread > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: chat.unread > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}