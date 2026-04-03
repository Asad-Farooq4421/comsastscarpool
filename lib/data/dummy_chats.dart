import '../models/chat_model.dart';
import 'dummy_users.dart';

// Get current user ID dynamically
String _getCurrentUserId() {
  return getCurrentUserId();
}

// ALL CHATS STORAGE - Mutable list for internal use
List<ChatModel> _dummyChats = [
  ChatModel(
    id: 'chat_1',
    participants: ['ahmed@isbstudent.comsats.edu.pk', 'ali@isbstudent.comsats.edu.pk'],
    rideId: 'ride_101',
    lastMessage: 'Okay, see you at 5pm',
    lastMessageTime: '10:30 AM',
    unreadCounts: {
      'ahmed@isbstudent.comsats.edu.pk': 0,
      'ali@isbstudent.comsats.edu.pk': 2,
    },
  ),
  ChatModel(
    id: 'chat_2',
    participants: ['ahmed@isbstudent.comsats.edu.pk', 'sara@isbstudent.comsats.edu.pk'],
    rideId: 'ride_102',
    lastMessage: 'How much for the ride?',
    lastMessageTime: '9:45 AM',
    unreadCounts: {
      'ahmed@isbstudent.comsats.edu.pk': 0,
      'sara@isbstudent.comsats.edu.pk': 0,
    },
  ),
  ChatModel(
    id: 'chat_3',
    participants: ['ahmed@isbstudent.comsats.edu.pk', 'bilal@isbstudent.comsats.edu.pk'],
    rideId: 'ride_103',
    lastMessage: "I'm at the gate",
    lastMessageTime: '8:20 AM',
    unreadCounts: {
      'ahmed@isbstudent.comsats.edu.pk': 0,
      'bilal@isbstudent.comsats.edu.pk': 1,
    },
  ),
  ChatModel(
    id: 'chat_4',
    participants: ['ahmed@isbstudent.comsats.edu.pk', 'fatima@isbstudent.comsats.edu.pk'],
    rideId: 'ride_104',
    lastMessage: 'Thanks for the ride!',
    lastMessageTime: 'Yesterday',
    unreadCounts: {
      'ahmed@isbstudent.comsats.edu.pk': 0,
      'fatima@isbstudent.comsats.edu.pk': 0,
    },
  ),
  ChatModel(
    id: 'chat_5',
    participants: ['ali@isbstudent.comsats.edu.pk', 'fatima@isbstudent.comsats.edu.pk'],
    rideId: 'ride_105',
    lastMessage: 'Where are you?',
    lastMessageTime: '11:00 AM',
    unreadCounts: {
      'ali@isbstudent.comsats.edu.pk': 0,
      'fatima@isbstudent.comsats.edu.pk': 1,
    },
  ),
];

// Expose getter for external access (READ-ONLY for UI)
List<ChatModel> get dummyChats => List.unmodifiable(_dummyChats);

// ==================== CHAT QUERIES ====================

List<ChatModel> getCurrentUserChats() {
  final currentUserId = _getCurrentUserId();
  if (currentUserId.isEmpty) return [];

  print('🔍 Getting chats for user: $currentUserId');

  final userChats = _dummyChats
      .where((chat) => chat.hasUser(currentUserId))
      .toList();

  print('📋 Found ${userChats.length} chats');
  return userChats;
}

ChatModel? getChatById(String chatId) {
  try {
    return _dummyChats.firstWhere((chat) => chat.id == chatId);
  } catch (e) {
    return null;
  }
}

ChatModel? getChatByRideId(String rideId) {
  final currentUserId = _getCurrentUserId();
  if (currentUserId.isEmpty) return null;

  try {
    return _dummyChats.firstWhere(
          (chat) => chat.rideId == rideId && chat.hasUser(currentUserId),
    );
  } catch (e) {
    return null;
  }
}

ChatModel? getChatBetweenUsers(String user1Id, String user2Id, {String? rideId}) {
  try {
    return _dummyChats.firstWhere(
          (chat) =>
      chat.participants.contains(user1Id) &&
          chat.participants.contains(user2Id) &&
          (rideId == null || chat.rideId == rideId),
    );
  } catch (e) {
    return null;
  }
}

// ==================== CHAT OPERATIONS ====================

// ✅ FIXED: Reset unread count for CURRENT USER only
void resetUnreadCount(String chatId) {
  final currentUserId = _getCurrentUserId();
  if (currentUserId.isEmpty) return;

  final index = _dummyChats.indexWhere((chat) => chat.id == chatId);
  if (index != -1) {
    final currentUnread = _dummyChats[index].getUnreadCount(currentUserId);
    if (currentUnread > 0) {
      _dummyChats[index] = _dummyChats[index].resetUnreadCount(currentUserId);
      print('✅ Unread count reset for user: $currentUserId in chat: $chatId');
    }
  }
}

void updateLastMessage(String chatId, String message, String time) {
  final index = _dummyChats.indexWhere((chat) => chat.id == chatId);
  if (index != -1) {
    _dummyChats[index] = _dummyChats[index].copyWith(
      lastMessage: message,
      lastMessageTime: time,
    );
    print('✅ Last message updated for chat: $chatId -> "$message"');
  }
}

// ✅ FIXED: Increment unread count for SPECIFIC USER only
void incrementUnreadCountForUser(String chatId, String userId) {
  final index = _dummyChats.indexWhere((chat) => chat.id == chatId);
  if (index != -1 && _dummyChats[index].hasUser(userId)) {
    _dummyChats[index] = _dummyChats[index].incrementUnreadCount(userId);
    final newCount = _dummyChats[index].getUnreadCount(userId);
    print('✅ Unread count incremented for user: $userId (now: $newCount)');
  }
}

void createNewChat({
  required String otherUserId,
  required String rideId,
}) {
  final currentUserId = _getCurrentUserId();
  if (currentUserId.isEmpty) return;

  final existingChat = getChatBetweenUsers(currentUserId, otherUserId, rideId: rideId);
  if (existingChat != null) {
    print('⚠️ Chat already exists: ${existingChat.id}');
    return;
  }

  final newChat = ChatModel(
    id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
    participants: [currentUserId, otherUserId],
    rideId: rideId,
    lastMessage: '',
    lastMessageTime: '',
    unreadCounts: {
      currentUserId: 0,
      otherUserId: 0,
    },
  );

  _dummyChats.insert(0, newChat);
  print('✅ New chat created: ${newChat.id}');
}

void addNewChat(ChatModel chat) {
  final exists = _dummyChats.any((c) =>
  c.participants.contains(chat.participants[0]) &&
      c.participants.contains(chat.participants[1]) &&
      c.rideId == chat.rideId
  );

  if (!exists) {
    _dummyChats.insert(0, chat);
    print('✅ New chat added: ${chat.id}');
  } else {
    print('⚠️ Chat already exists, not adding duplicate');
  }
}

Map<String, String> getOtherParticipantInfo(String chatId) {
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