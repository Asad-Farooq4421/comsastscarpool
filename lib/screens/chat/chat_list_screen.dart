import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../data/dummy_chats.dart';
import '../../data/dummy_users.dart';
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
    _loadChats();
  }

  void _loadChats() {
    setState(() {
      chats = List.from(getCurrentUserChats());
      print('📋 Loaded ${chats.length} chats for user: ${getCurrentUserId()}');
    });
  }

  Map<String, String> _getOtherUserInfo(ChatModel chat) {
    final currentUserId = getCurrentUserId();
    final otherUserId = chat.getOtherParticipant(currentUserId);
    final user = getUserByEmail(otherUserId);

    return {
      'name': user?['name'] ?? otherUserId.split('@').first,
      'photo': user?['photo'] ?? '',
      'firstLetter': (user?['name'] ?? otherUserId.split('@').first)[0].toUpperCase(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
          Expanded(
            child: chats.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: () async {
                _loadChats();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final otherUser = _getOtherUserInfo(chat);
                  return _buildChatCard(
                    context,
                    chat,
                    otherUser['name']!,
                    otherUser['photo']!,
                    otherUser['firstLetter']!,
                  );
                },
              ),
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

  Widget _buildChatCard(BuildContext context, ChatModel chat,
      String otherUserName, String otherUserPhoto, String firstLetter) {

    // ✅ FIXED: Get unread count for CURRENT USER only
    final currentUserId = getCurrentUserId();
    final unreadCount = chat.getUnreadCount(currentUserId);

    return InkWell(
      onTap: () async {
        print('📱 Opening chat: ${chat.id}');
        resetUnreadCount(chat.id);
        final result = await Navigator.pushNamed(
          context,
          AppRoutes.individualChat,
          arguments: chat.id,
        );
        _loadChats();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                otherUserPhoto.isNotEmpty
                    ? CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: NetworkImage(otherUserPhoto),
                  onBackgroundImageError: (_, __) {},
                )
                    : CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                // ✅ FIXED: Use per-user unread count
                if (unreadCount > 0)
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
                          unreadCount > 9 ? '9+' : '$unreadCount',
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          otherUserName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        chat.lastMessageTime,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage.isEmpty ? 'No messages yet' : chat.lastMessage,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: unreadCount > 0
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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