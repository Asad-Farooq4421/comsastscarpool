class ChatModel {
  final String id;
  final List<String> participants;  // [user1_email, user2_email]
  final String rideId;
  final String lastMessage;
  final String lastMessageTime;
  final Map<String, int> unreadCounts;  // ✅ CHANGED: Per-user unread counts
  final bool isActive;

  ChatModel({
    required this.id,
    required this.participants,
    required this.rideId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCounts,  // ✅ CHANGED: Required now
    this.isActive = true,
  });

  // ✅ NEW: Get unread count for specific user
  int getUnreadCount(String userId) {
    return unreadCounts[userId] ?? 0;
  }

  // ✅ NEW: Increment unread count for specific user
  ChatModel incrementUnreadCount(String userId) {
    final newCount = (unreadCounts[userId] ?? 0) + 1;
    final newUnreadCounts = Map<String, int>.from(unreadCounts);
    newUnreadCounts[userId] = newCount;
    return copyWith(unreadCounts: newUnreadCounts);
  }

  // ✅ NEW: Reset unread count for specific user
  ChatModel resetUnreadCount(String userId) {
    final newUnreadCounts = Map<String, int>.from(unreadCounts);
    newUnreadCounts[userId] = 0;
    return copyWith(unreadCounts: newUnreadCounts);
  }

  // Helper: Get other participant (not current user)
  String getOtherParticipant(String currentUserId) {
    return participants.firstWhere(
          (p) => p != currentUserId,
      orElse: () => participants.first,
    );
  }

  // Helper: Check if user is in this chat
  bool hasUser(String userId) {
    return participants.contains(userId);
  }

  ChatModel copyWith({
    String? id,
    List<String>? participants,
    String? rideId,
    String? lastMessage,
    String? lastMessageTime,
    Map<String, int>? unreadCounts,
    bool? isActive,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      rideId: rideId ?? this.rideId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'rideId': rideId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCounts': unreadCounts,
      'isActive': isActive,
    };
  }
}