import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../../services/user_service.dart';
import '../../utils/routes.dart';
import '../../utils/time_formatter.dart';
import '../chat/individual_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  List<ChatModel> _chats = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserId = currentUser.uid;
      });
      _loadChats();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadChats() async {
    if (_currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final chats = await _chatService.getUserChats();
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading chats: $e');
      setState(() {
        _chats = [];
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getOtherUserInfo(ChatModel chat) async {
    if (_currentUserId == null) {
      return {
        'name': 'Unknown',
        'photo': '',
        'firstLetter': '?',
        'userId': '',
      };
    }

    final otherUserId = chat.getOtherParticipant(_currentUserId!);
    final userProfile = await _userService.getUserProfile(otherUserId);

    return {
      'name': userProfile?.name ?? otherUserId.split('@').first,
      'photo': userProfile?.photo ?? '',
      'firstLetter': (userProfile?.name ?? otherUserId.split('@').first)[0].toUpperCase(),
      'userId': otherUserId,
    };
  }

  Future<void> _refreshChats() async {
    await _loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _chats.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _refreshChats,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return FutureBuilder<Map<String, dynamic>>(
                    future: _getOtherUserInfo(chat),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final otherUser = snapshot.data!;
                        return _buildChatCard(
                          chat,
                          otherUser['name']!,
                          otherUser['photo']!,
                          otherUser['firstLetter']!,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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

  Widget _buildChatCard(ChatModel chat, String otherUserName, String otherUserPhoto, String firstLetter) {
    // Get unread count for current user
    final unreadCount = _currentUserId != null ? chat.getUnreadCount(_currentUserId!) : 0;

    return InkWell(
      onTap: () async {
        if (_currentUserId != null) {
          // Mark messages as read
          await _chatService.markMessagesAsRead(chat.id);

          // Navigate to chat
          if (mounted) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IndividualChatScreen(
                  chatId: chat.id,
                  rideId: chat.rideId,
                  otherUserName: otherUserName,
                ),
              ),
            );
            // Refresh chats after returning
            _loadChats();
          }
        }
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
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: NetworkImage(otherUserPhoto),
                  onBackgroundImageError: (_, __) {},
                )
                    : CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    firstLetter,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
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
                        _formatTime(chat.lastMessageTime),
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

  // ✅ Using TimeFormatter for consistent timestamp formatting
  String _formatTime(String timestamp) {
    return TimeFormatter.formatMessageTimestamp(timestamp);
  }
}