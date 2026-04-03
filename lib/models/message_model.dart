class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final String timestamp;
  bool isRead;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  // DYNAMIC isMe - calculated when needed, not stored!
  bool isMe(String currentUserId) {
    return senderId == currentUserId;
  }

  // Check if message is for current user
  bool isForMe(String currentUserId) {
    return receiverId == currentUserId;
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? text,
    String? timestamp,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }
}