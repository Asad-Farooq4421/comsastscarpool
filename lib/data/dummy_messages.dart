import '../models/message_model.dart';
import 'dummy_users.dart';
import 'dummy_chats.dart';

// Get current user ID
String _getCurrentUserId() {
  return getCurrentUserId();
}

// All messages data
List<MessageModel> dummyMessages = [
  MessageModel(
    id: 'm1',
    chatId: 'chat1',
    senderId: 'ali@isbstudent.comsats.edu.pk',
    text: 'Hey, are you coming?',
    timestamp: '10:25 AM',
    isRead: true,
    isMe: false,
  ),
  MessageModel(
    id: 'm2',
    chatId: 'chat1',
    senderId: 'ali@isbstudent.comsats.edu.pk',
    text: 'Okay, see you at 5pm',
    timestamp: '10:30 AM',
    isRead: false,
    isMe: false,
  ),
  MessageModel(
    id: 'm3',
    chatId: 'chat2',
    senderId: 'sara@isbstudent.comsats.edu.pk',
    text: 'How much for the ride?',
    timestamp: '9:45 AM',
    isRead: true,
    isMe: false,
  ),
  MessageModel(
    id: 'm4',
    chatId: 'chat3',
    senderId: 'bilal@isbstudent.comsats.edu.pk',
    text: 'I\'m at the gate',
    timestamp: '8:20 AM',
    isRead: false,
    isMe: false,
  ),
];

// ==================== MESSAGE QUERIES ====================

// Get all messages for a specific chat
List<MessageModel> getMessagesForChat(String chatId) {
  return dummyMessages
      .where((msg) => msg.chatId == chatId)
      .toList()
      .map((msg) {
    // Mark if message is from current user
    final isMe = msg.senderId == _getCurrentUserId();
    return MessageModel(
      id: msg.id,
      chatId: msg.chatId,
      senderId: msg.senderId,
      text: msg.text,
      timestamp: msg.timestamp,
      isRead: msg.isRead,
      isMe: isMe,
    );
  })
      .toList();
}

// Get last message for a chat (for preview)
MessageModel? getLastMessageForChat(String chatId) {
  final messages = getMessagesForChat(chatId);
  if (messages.isEmpty) return null;
  return messages.last;
}

// ==================== MESSAGE OPERATIONS ====================

// Send a new message
void sendMessage({
  required String chatId,
  required String text,
}) {
  final currentUserId = _getCurrentUserId();
  final timestamp = _getFormattedTime();

  final newMessage = MessageModel(
    id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
    chatId: chatId,
    senderId: currentUserId,
    text: text,
    timestamp: timestamp,
    isRead: false,
    isMe: true,
  );

  dummyMessages.add(newMessage);

  // Update last message in chat
  updateLastMessage(chatId, text, timestamp);

  // Increment unread count for the other user
  _incrementUnreadForOtherUser(chatId);
}

// Mark all messages in a chat as read
void markMessagesAsRead(String chatId) {
  final currentUserId = _getCurrentUserId();

  for (int i = 0; i < dummyMessages.length; i++) {
    if (dummyMessages[i].chatId == chatId &&
        dummyMessages[i].senderId != currentUserId &&
        !dummyMessages[i].isRead) {
      dummyMessages[i].isRead = true;
    }
  }

  // Reset unread count in chat
  resetUnreadCount(chatId);
}

// Mark a single message as read
void markMessageAsRead(String messageId) {
  final index = dummyMessages.indexWhere((msg) => msg.id == messageId);
  if (index != -1 && !dummyMessages[index].isRead) {
    dummyMessages[index].isRead = true;
  }
}

// Get unread count for a chat
int getUnreadCountForChat(String chatId) {
  final currentUserId = _getCurrentUserId();
  return dummyMessages.where((msg) =>
  msg.chatId == chatId &&
      msg.senderId != currentUserId &&
      !msg.isRead
  ).length;
}

// Get total unread count across all chats
int getTotalUnreadCount() {
  final currentUserId = _getCurrentUserId();
  return dummyMessages.where((msg) =>
  msg.senderId != currentUserId &&
      !msg.isRead
  ).length;
}

// Helper: Get formatted time
String _getFormattedTime() {
  final now = DateTime.now();
  final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
  final minute = now.minute.toString().padLeft(2, '0');
  final amPm = now.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $amPm';
}

// Helper: Increment unread for other user in chat
void _incrementUnreadForOtherUser(String chatId) {
  final currentUserId = _getCurrentUserId();
  final chatIndex = dummyChats.indexWhere((chat) => chat.id == chatId);

  if (chatIndex != -1 && dummyChats[chatIndex].userId != currentUserId) {
    final newUnread = dummyChats[chatIndex].unread + 1;
    final updatedChat = dummyChats[chatIndex].copyWith(unread: newUnread);
    dummyChats[chatIndex] = updatedChat;
  }
}