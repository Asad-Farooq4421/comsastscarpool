import '../models/chat_model.dart';
import 'dummy_users.dart';

// Get current user ID dynamically
String _getCurrentUserId() {
  return getCurrentUserId();
}

// All chats data
List<ChatModel> dummyChats = [
  ChatModel(
    id: 'chat1',
    userId: 'ali@isbstudent.comsats.edu.pk',
    userName: 'Ali Khan',
    userPhoto: 'https://i.pravatar.cc/150?img=1',
    lastMessage: 'Okay, see you at 5pm',
    timestamp: '10:30 AM',
    unread: 2,
    rideId: 'ride1',
  ),
  ChatModel(
    id: 'chat2',
    userId: 'sara@isbstudent.comsats.edu.pk',
    userName: 'Sara Ahmed',
    userPhoto: 'https://i.pravatar.cc/150?img=2',
    lastMessage: 'How much for the ride?',
    timestamp: '9:45 AM',
    unread: 0,
    rideId: 'ride2',
  ),
  ChatModel(
    id: 'chat3',
    userId: 'bilal@isbstudent.comsats.edu.pk',
    userName: 'Bilal Ahmed',
    userPhoto: 'https://i.pravatar.cc/150?img=3',
    lastMessage: 'I\'m at the gate',
    timestamp: '8:20 AM',
    unread: 1,
    rideId: 'ride3',
  ),
  ChatModel(
    id: 'chat4',
    userId: 'fatima@isbstudent.comsats.edu.pk',
    userName: 'Fatima Ali',
    userPhoto: 'https://i.pravatar.cc/150?img=4',
    lastMessage: 'Thanks for the ride!',
    timestamp: 'Yesterday',
    unread: 0,
    rideId: 'ride1',
  ),
];

// ==================== CHAT QUERIES ====================

// Get all chats for current user
List<ChatModel> getCurrentUserChats() {
  final currentUserId = _getCurrentUserId();
  return dummyChats.where((chat) => chat.userId == currentUserId).toList();
}

// Get chat by ID
ChatModel? getChatById(String chatId) {
  try {
    return dummyChats.firstWhere((chat) => chat.id == chatId);
  } catch (e) {
    return null;
  }
}

// Get chat between current user and another user for a specific ride
ChatModel? getChatByRideId(String rideId) {
  final currentUserId = _getCurrentUserId();
  try {
    return dummyChats.firstWhere(
          (chat) => chat.rideId == rideId && chat.userId == currentUserId,
    );
  } catch (e) {
    return null;
  }
}

// ==================== CHAT OPERATIONS ====================

// Reset unread count when user opens chat
void resetUnreadCount(String chatId) {
  final index = dummyChats.indexWhere((chat) => chat.id == chatId);
  if (index != -1 && dummyChats[index].unread > 0) {
    final updatedChat = dummyChats[index].copyWith(unread: 0);
    dummyChats[index] = updatedChat;
  }
}

// Update last message in chat
void updateLastMessage(String chatId, String message, String timestamp) {
  final index = dummyChats.indexWhere((chat) => chat.id == chatId);
  if (index != -1) {
    final updatedChat = dummyChats[index].copyWith(
      lastMessage: message,
      timestamp: timestamp,
    );
    dummyChats[index] = updatedChat;
  }
}

// Increment unread count for a chat (when receiving new message)
void incrementUnreadCount(String chatId) {
  final currentUserId = _getCurrentUserId();
  final index = dummyChats.indexWhere((chat) => chat.id == chatId);

  // Only increment if the message is not from current user
  if (index != -1 && dummyChats[index].userId != currentUserId) {
    final newUnread = dummyChats[index].unread + 1;
    final updatedChat = dummyChats[index].copyWith(unread: newUnread);
    dummyChats[index] = updatedChat;
  }
}

// Create a new chat
void createNewChat({
  required String userId,
  required String userName,
  required String userPhoto,
  required String rideId,
}) {
  // Check if chat already exists
  final existingChat = getChatByRideId(rideId);
  if (existingChat != null) return;

  final newChat = ChatModel(
    id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
    userId: userId,
    userName: userName,
    userPhoto: userPhoto,
    lastMessage: '',
    timestamp: '',
    unread: 0,
    rideId: rideId,
  );

  dummyChats.add(newChat);
}