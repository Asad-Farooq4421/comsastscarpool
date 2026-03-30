class MessageModel {
  final String id;
  final String chatId;
  final String senderId; // 'me' ya actual user id
  final String text;
  final String timestamp;
  final bool isRead;
  final bool isMe; // true if sent by current user

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isRead,
    required this.isMe,
  });
}