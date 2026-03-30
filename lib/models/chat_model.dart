class ChatModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhoto;
  final String lastMessage;
  final String timestamp;
  final int unread;
  final String rideId; // Optional - for ride context

  ChatModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhoto,
    required this.lastMessage,
    required this.timestamp,
    required this.unread,
    required this.rideId,
  });
}