class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final String timestamp;
  bool isRead;  // Changed to non-final so we can update
  final bool isMe;

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isRead,
    required this.isMe,
  });

  // Copy with method to update read status
  MessageModel copyWith({bool? isRead}) {
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      text: text,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      isMe: isMe,
    );
  }
}