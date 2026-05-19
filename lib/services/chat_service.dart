import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new chat
  Future<String> createChat({
    required List<String> participants,
    required String rideId,
  }) async {
    try {
      final String chatId = _databaseRef.child('chats').push().key!;

      // Initialize unread counts for all participants (0 for everyone)
      Map<String, int> unreadCounts = {};
      for (var participant in participants) {
        unreadCounts[participant] = 0;
      }

      final chat = ChatModel(
        id: chatId,
        participants: participants,
        rideId: rideId,
        lastMessage: '',
        lastMessageTime: DateTime.now().toIso8601String(),
        unreadCounts: unreadCounts,
        isActive: true,
      );

      await _databaseRef.child('chats/$chatId').set(chat.toJson());
      return chatId;
    } catch (e) {
      throw Exception('Failed to create chat: $e');
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String text,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      // Create message
      final String messageId = _databaseRef.child('chats/$chatId/messages').push().key!;
      final message = MessageModel(
        id: messageId,
        chatId: chatId,
        senderId: currentUser.uid,
        receiverId: receiverId,
        text: text,
        timestamp: DateTime.now().toIso8601String(),
        isRead: false,
      );

      // Get chat to update unread counts
      final chat = await getChat(chatId);
      if (chat != null) {
        // Increment unread count for receiver only
        Map<String, int> newUnreadCounts = Map.from(chat.unreadCounts);
        newUnreadCounts[receiverId] = (newUnreadCounts[receiverId] ?? 0) + 1;

        // Update chat with last message and new unread counts
        await _databaseRef.child('chats/$chatId').update({
          'lastMessage': text,
          'lastMessageTime': DateTime.now().toIso8601String(),
          'unreadCounts': newUnreadCounts,
        });
      }

      // Save message
      await _databaseRef.child('chats/$chatId/messages/$messageId').set(message.toJson());
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Get all chats for current user
  Future<List<ChatModel>> getUserChats() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return [];

      DatabaseEvent event = await _databaseRef.child('chats').once();
      DataSnapshot snapshot = event.snapshot;

      List<ChatModel> userChats = [];

      if (snapshot.value != null) {
        Map<dynamic, dynamic> chatsMap = snapshot.value as Map;
        chatsMap.forEach((key, value) {
          Map<String, dynamic> chatData = Map<String, dynamic>.from(value);
          ChatModel chat = ChatModel.fromJson(chatData, key.toString());

          // Only include chats where current user is a participant
          if (chat.hasUser(currentUser.uid)) {
            userChats.add(chat);
          }
        });
      }

      // Sort by last message time (most recent first)
      userChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

      return userChats;
    } catch (e) {
      print('Error getting user chats: $e');
      return [];
    }
  }

  // Get a specific chat by ID
  Future<ChatModel?> getChat(String chatId) async {
    try {
      DatabaseEvent event = await _databaseRef.child('chats/$chatId').once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<String, dynamic> chatData = Map<String, dynamic>.from(snapshot.value as Map);
        return ChatModel.fromJson(chatData, chatId);
      }
    } catch (e) {
      print('Error getting chat: $e');
    }
    return null;
  }

  // Get or create a chat between two users for a specific ride
  Future<String> getOrCreateChat(String rideId, String otherUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      // Check if chat already exists
      final userChats = await getUserChats();
      for (var chat in userChats) {
        if (chat.rideId == rideId && chat.hasUser(otherUserId)) {
          return chat.id;
        }
      }

      // Create new chat
      return await createChat(
        participants: [currentUser.uid, otherUserId],
        rideId: rideId,
      );
    } catch (e) {
      throw Exception('Failed to get or create chat: $e');
    }
  }

  // Get messages for a chat
  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      DatabaseEvent event = await _databaseRef
          .child('chats/$chatId/messages')
          .orderByChild('timestamp')
          .once();
      DataSnapshot snapshot = event.snapshot;

      List<MessageModel> messages = [];

      if (snapshot.value != null) {
        Map<dynamic, dynamic> messagesMap = snapshot.value as Map;
        List<MapEntry<dynamic, dynamic>> entries = messagesMap.entries.toList();

        // Sort by timestamp
        entries.sort((a, b) {
          var aData = Map<String, dynamic>.from(a.value);
          var bData = Map<String, dynamic>.from(b.value);
          return aData['timestamp'].compareTo(bData['timestamp']);
        });

        for (var entry in entries) {
          Map<String, dynamic> messageData = Map<String, dynamic>.from(entry.value);
          messages.add(MessageModel.fromJson(messageData, entry.key.toString()));
        }
      }

      return messages;
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Mark messages as read for a specific chat and receiver
  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final chat = await getChat(chatId);
      if (chat != null) {
        // Reset unread count for current user (receiver)
        final updatedChat = chat.resetUnreadCount(currentUser.uid);
        await _databaseRef.child('chats/$chatId/unreadCounts').set(updatedChat.unreadCounts);
      }

      // Also mark individual messages as read
      final messages = await getMessages(chatId);
      for (var message in messages) {
        if (message.receiverId == currentUser.uid && !message.isRead) {
          await _databaseRef
              .child('chats/$chatId/messages/${message.id}/isRead')
              .set(true);
        }
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Get unread count for current user
  Future<int> getTotalUnreadCount() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      final chats = await getUserChats();
      int totalUnread = 0;

      for (var chat in chats) {
        totalUnread += chat.getUnreadCount(currentUser.uid);
      }

      return totalUnread;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  // Stream of chats (real-time updates)
  Stream<List<ChatModel>> streamUserChats() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _databaseRef.child('chats').onValue.map((event) {
      List<ChatModel> userChats = [];

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> chatsMap = event.snapshot.value as Map;
        chatsMap.forEach((key, value) {
          Map<String, dynamic> chatData = Map<String, dynamic>.from(value);
          ChatModel chat = ChatModel.fromJson(chatData, key.toString());

          if (chat.hasUser(currentUser.uid)) {
            userChats.add(chat);
          }
        });
      }

      userChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      return userChats;
    });
  }

  // Stream of messages for a specific chat (real-time)
  Stream<List<MessageModel>> streamMessages(String chatId) {
    return _databaseRef
        .child('chats/$chatId/messages')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
      List<MessageModel> messages = [];

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> messagesMap = event.snapshot.value as Map;
        List<MapEntry<dynamic, dynamic>> entries = messagesMap.entries.toList();

        entries.sort((a, b) {
          var aData = Map<String, dynamic>.from(a.value);
          var bData = Map<String, dynamic>.from(b.value);
          return aData['timestamp'].compareTo(bData['timestamp']);
        });

        for (var entry in entries) {
          Map<String, dynamic> messageData = Map<String, dynamic>.from(entry.value);
          messages.add(MessageModel.fromJson(messageData, entry.key.toString()));
        }
      }

      return messages;
    });
  }

  // Stream unread count for current user
  Stream<int> streamUnreadCount() {
    return streamUserChats().map((chats) {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return 0;

      int totalUnread = 0;
      for (var chat in chats) {
        totalUnread += chat.getUnreadCount(currentUser.uid);
      }
      return totalUnread;
    });
  }

  // Delete a chat
  Future<void> deleteChat(String chatId) async {
    try {
      await _databaseRef.child('chats/$chatId').remove();
    } catch (e) {
      throw Exception('Failed to delete chat: $e');
    }
  }

  // Delete a specific message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _databaseRef.child('chats/$chatId/messages/$messageId').remove();
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }
}