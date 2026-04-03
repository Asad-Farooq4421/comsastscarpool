import '../models/message_model.dart';
import 'dummy_users.dart';
import 'dummy_chats.dart';

// Get current user ID
String _getCurrentUserId() {
  return getCurrentUserId();
}

// ALL MESSAGES STORAGE - Mutable list for internal use
List<MessageModel> _dummyMessages = [
  // ========== CHAT 1: Ahmed <-> Ali ==========
  MessageModel(
    id: 'msg_1',
    chatId: 'chat_1',
    senderId: 'ali@isbstudent.comsats.edu.pk',
    receiverId: 'ahmed@isbstudent.comsats.edu.pk',
    text: 'Hey! Are you coming for the ride?',
    timestamp: '9:00 AM',
    isRead: true,
  ),
  MessageModel(
    id: 'msg_2',
    chatId: 'chat_1',
    senderId: 'ahmed@isbstudent.comsats.edu.pk',
    receiverId: 'ali@isbstudent.comsats.edu.pk',
    text: 'Yes, I\'ll be there in 10 minutes',
    timestamp: '9:05 AM',
    isRead: true,
  ),
  MessageModel(
    id: 'msg_3',
    chatId: 'chat_1',
    senderId: 'ali@isbstudent.comsats.edu.pk',
    receiverId: 'ahmed@isbstudent.comsats.edu.pk',
    text: 'Great! I\'m waiting at the main gate',
    timestamp: '9:10 AM',
    isRead: true,
  ),
  MessageModel(
    id: 'msg_4',
    chatId: 'chat_1',
    senderId: 'ahmed@isbstudent.comsats.edu.pk',
    receiverId: 'ali@isbstudent.comsats.edu.pk',
    text: 'Okay, see you at 5pm',
    timestamp: '10:30 AM',
    isRead: false,
  ),

  // ========== CHAT 2: Ahmed <-> Sara ==========
  MessageModel(
    id: 'msg_5',
    chatId: 'chat_2',
    senderId: 'sara@isbstudent.comsats.edu.pk',
    receiverId: 'ahmed@isbstudent.comsats.edu.pk',
    text: 'Hi! Is the ride still available?',
    timestamp: '9:00 AM',
    isRead: true,
  ),
  MessageModel(
    id: 'msg_6',
    chatId: 'chat_2',
    senderId: 'ahmed@isbstudent.comsats.edu.pk',
    receiverId: 'sara@isbstudent.comsats.edu.pk',
    text: 'Yes, it is available',
    timestamp: '9:15 AM',
    isRead: true,
  ),
  MessageModel(
    id: 'msg_7',
    chatId: 'chat_2',
    senderId: 'sara@isbstudent.comsats.edu.pk',
    receiverId: 'ahmed@isbstudent.comsats.edu.pk',
    text: 'How much for the ride?',
    timestamp: '9:45 AM',
    isRead: true,
  ),

  // ========== CHAT 3: Ahmed <-> Bilal ==========
  MessageModel(
    id: 'msg_8',
    chatId: 'chat_3',
    senderId: 'bilal@isbstudent.comsats.edu.pk',
    receiverId: 'ahmed@isbstudent.comsats.edu.pk',
    text: 'Where are you?',
    timestamp: '8:00 AM',
    isRead: true,
  ),
  MessageModel(
    id: 'msg_9',
    chatId: 'chat_3',
    senderId: 'ahmed@isbstudent.comsats.edu.pk',
    receiverId: 'bilal@isbstudent.comsats.edu.pk',
    text: 'Almost there, 2 minutes',
    timestamp: '8:10 AM',
    isRead: true,
  ),
  MessageModel(
    id: 'msg_10',
    chatId: 'chat_3',
    senderId: 'bilal@isbstudent.comsats.edu.pk',
    receiverId: 'ahmed@isbstudent.comsats.edu.pk',
    text: 'I\'m at the gate',
    timestamp: '8:20 AM',
    isRead: false,
  ),

  // ========== CHAT 4: Ahmed <-> Fatima ==========
  MessageModel(
    id: 'msg_11',
    chatId: 'chat_4',
    senderId: 'ahmed@isbstudent.comsats.edu.pk',
    receiverId: 'fatima@isbstudent.comsats.edu.pk',
    text: 'You\'re welcome!',
    timestamp: 'Yesterday',
    isRead: true,
  ),
  MessageModel(
    id: 'msg_12',
    chatId: 'chat_4',
    senderId: 'fatima@isbstudent.comsats.edu.pk',
    receiverId: 'ahmed@isbstudent.comsats.edu.pk',
    text: 'Thanks for the ride!',
    timestamp: 'Yesterday',
    isRead: true,
  ),

  // ========== CHAT 5: Ali <-> Fatima ==========
  MessageModel(
    id: 'msg_13',
    chatId: 'chat_5',
    senderId: 'ali@isbstudent.comsats.edu.pk',
    receiverId: 'fatima@isbstudent.comsats.edu.pk',
    text: 'Where are you?',
    timestamp: '11:00 AM',
    isRead: false,
  ),
];

// Expose getter for external access (READ-ONLY for UI)
List<MessageModel> get dummyMessages => List.unmodifiable(_dummyMessages);

// ==================== MESSAGE QUERIES ====================

List<MessageModel> getMessagesForChat(String chatId) {
  final messages = _dummyMessages
      .where((msg) => msg.chatId == chatId)
      .toList();

  messages.sort((a, b) {
    final aTime = _parseTimeToDateTime(a.timestamp);
    final bTime = _parseTimeToDateTime(b.timestamp);
    return aTime.compareTo(bTime);
  });

  return messages;
}

DateTime _parseTimeToDateTime(String timestamp) {
  if (timestamp.contains('-')) {
    final parts = timestamp.split(' ');
    final dateParts = parts[0].split('-');
    final timeParts = parts[1].split(':');
    return DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  } else {
    final now = DateTime.now();
    final isPM = timestamp.contains('PM');
    var hour = int.parse(timestamp.split(':')[0]);
    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;
    return DateTime(now.year, now.month, now.day, hour,
        int.parse(timestamp.split(':')[1].split(' ')[0]));
  }
}

MessageModel? getLastMessageForChat(String chatId) {
  final messages = getMessagesForChat(chatId);
  if (messages.isEmpty) return null;
  return messages.last;
}

// ✅ FIXED: Get unread count from chat model, not from messages
int getUnreadCountForChat(String chatId) {
  final currentUserId = _getCurrentUserId();
  if (currentUserId.isEmpty) return 0;

  final chat = getChatById(chatId);
  if (chat == null) return 0;

  return chat.getUnreadCount(currentUserId);
}

int getTotalUnreadCount() {
  final currentUserId = _getCurrentUserId();
  if (currentUserId.isEmpty) return 0;

  int total = 0;
  for (var chat in dummyChats) {
    if (chat.hasUser(currentUserId)) {
      total += chat.getUnreadCount(currentUserId);
    }
  }
  return total;
}

// ==================== MESSAGE OPERATIONS ====================

void sendMessage({
  required String chatId,
  required String text,
}) {
  final currentUserId = _getCurrentUserId();
  if (currentUserId.isEmpty) {
    print('❌ Cannot send: No user logged in');
    return;
  }

  final chat = getChatById(chatId);
  if (chat == null) {
    print('❌ Cannot send: Chat not found');
    return;
  }

  final otherUserId = chat.getOtherParticipant(currentUserId);
  final now = DateTime.now();
  final timestamp = _getFormattedTime(now);

  print('📤 SENDING: From $currentUserId to $otherUserId in chat $chatId');

  final newMessage = MessageModel(
    id: 'msg_${now.millisecondsSinceEpoch}',
    chatId: chatId,
    senderId: currentUserId,
    receiverId: otherUserId,
    text: text,
    timestamp: timestamp,
    isRead: false,
  );

  _dummyMessages.add(newMessage);
  print('✅ Message sent: "$text" at $timestamp');

  updateLastMessage(chatId, text, timestamp);

  // ✅ Only increment unread count for RECEIVER, not sender
  incrementUnreadCountForUser(chatId, otherUserId);
}

void markMessagesAsRead(String chatId) {
  final currentUserId = _getCurrentUserId();
  if (currentUserId.isEmpty) return;

  bool updated = false;
  for (int i = 0; i < _dummyMessages.length; i++) {
    if (_dummyMessages[i].chatId == chatId &&
        _dummyMessages[i].receiverId == currentUserId &&
        !_dummyMessages[i].isRead) {
      _dummyMessages[i] = _dummyMessages[i].copyWith(isRead: true);
      updated = true;
    }
  }

  if (updated) {
    resetUnreadCount(chatId);
    print('✅ Messages marked as read for chat: $chatId');
  }
}

void markMessageAsRead(String messageId) {
  final currentUserId = _getCurrentUserId();
  final index = _dummyMessages.indexWhere((msg) => msg.id == messageId);

  if (index != -1 &&
      _dummyMessages[index].receiverId == currentUserId &&
      !_dummyMessages[index].isRead) {
    _dummyMessages[index] = _dummyMessages[index].copyWith(isRead: true);

    final chat = getChatById(_dummyMessages[index].chatId);
    if (chat != null) {
      final newUnreadCount = getUnreadCountForChat(chat.id);
      final chatIndex = dummyChats.indexWhere((c) => c.id == chat.id);
      if (chatIndex != -1) {
        dummyChats[chatIndex] = dummyChats[chatIndex].copyWith(
          unreadCounts: {
            ...dummyChats[chatIndex].unreadCounts,
            currentUserId: newUnreadCount,
          },
        );
      }
    }
    print('✅ Message marked as read: $messageId');
  }
}

String _getFormattedTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final amPm = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $amPm';
}

Map<String, String> getOtherUserInfoForChat(String chatId) {
  final currentUserId = _getCurrentUserId();
  final chat = getChatById(chatId);

  if (chat == null || currentUserId.isEmpty) {
    return {'name': 'Unknown', 'photo': '', 'email': ''};
  }

  final otherUserId = chat.getOtherParticipant(currentUserId);
  final user = getUserByEmail(otherUserId);

  return {
    'name': user?['name'] ?? otherUserId.split('@').first,
    'photo': user?['photo'] ?? '',
    'email': otherUserId,
  };
}